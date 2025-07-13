#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO
import subprocess, threading, queue
import time, sys, signal
import numpy as np

# ==============================================================================
#  MACROS
# ==============================================================================

DEBUG = 0

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base

N = 17048 # Row size (fixed in hardware)
P = 4     # Number of partitions per row
I = 1000  # Number of rows to process
CHUNK_WORDS = N // P

assert N % P == 0

NUM_WORKERS = 2 # Number of `a` channels in block design

# ==============================================================================
#  GLOBALS
# ==============================================================================

# Buffers (declared globally for cleanup)
dma_bufs = [allocate(shape=(N,), dtype=np.float64) for _ in range(NUM_WORKERS)]
result_bufs = [allocate(shape=(1,), dtype=np.float64) for _ in range(NUM_WORKERS)]

# Asynchronous row processing
work_queue = queue.Queue()
threads = []

# Gracefully exit on interrupt
stop_requested = False

# ==============================================================================
#  TERMINATION HANDLING
# ==============================================================================

def cleanup():
    if DEBUG: print("\nCleaning up...")
        
    for t in threads:
        t.join(timeout=1)

    for buf in dma_bufs + result_bufs:
        if buf is not None:
            buf.freebuffer()

def handle_interrupt(sig, frame):
    global stop_requested
    print("Interrupt received.")
    stop_requested = True
    cleanup()
    sys.exit(0)

signal.signal(signal.SIGINT, handle_interrupt)

# ==============================================================================
#  HELPERS
# ==============================================================================

def process_row(row_num, a, b, result, dma):
    if stop_requested: return

    # Initiate transfer and wait for result
    dma.recvchannel.transfer(result)
    for p in range(P):
        offset = p * CHUNK_WORDS
        chunk = a[offset : offset + CHUNK_WORDS]
        dma.sendchannel.transfer(chunk)
        dma.sendchannel.wait()
    dma.recvchannel.wait()

    if DEBUG:
        actual = float(result[0])
        expected = np.dot(a, b)
        print(f"({row_num}) Result -> Actual: {actual:.24f} | Expected: {expected:.24f}")

def worker(worker_id, b, dma):
    while not stop_requested:
        try: row_num, a_buf, result_buf = work_queue.get(timeout=1)
        except queue.Empty: break
        process_row(row_num, a_buf, b, result_buf, dma)
        work_queue.task_done()

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":

    if DEBUG: print(f"N={N}, P={P}, I={I}, WORDS_PER_CHUNK={CHUNK_WORDS}")

    try:
        # Load bitstream and initialize DMAs
        overlay = Overlay(PROJ_DIR + "design_1.bit")
        overlay.download()
        dmas = [overlay.axi_dma_0, overlay.axi_dma_2]

        # Write vector `b` to BRAM 
        b = np.arange(1, N+1, dtype=np.float64) / 100.0 # Dummy `b` vector
        bram_mmio = MMIO(BRAM_BASE, N*8)
        b_bits = b.view(np.uint64)
        for i in range(N):
            val64 = int(b_bits[i])
            bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
            bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)

        print("Initialization complete.")

        # Fill work queue
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(I):
                buf_idx = i % NUM_WORKERS
                a_buf = dma_bufs[buf_idx]
                result_buf = result_bufs[buf_idx]

                view = memoryview(a_buf).cast("B")
                if a_file.readinto(view) != N * 8: break
                work_queue.put((i, a_buf, result_buf))

        # Initialize threads
        threads = [
            threading.Thread(target=worker, args=(i, b, dmas[i]))
            for i in range(NUM_WORKERS)
        ]

        # Execute computation
        start_time = time.perf_counter()

        for t in threads: t.start() # start threads
        work_queue.join()           # wait for rows to process
        for t in threads: t.join()  # wait for threads to exit

        end_time = time.perf_counter()

        print(f"Done. Compute time: {end_time - start_time:.6f} seconds")

    finally: cleanup()

