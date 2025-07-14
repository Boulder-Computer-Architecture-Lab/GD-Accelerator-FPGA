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

DEBUG = 1

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"

BRAM_BASE = 0x80000000 

N = 17048 # Row size (fixed in hardware)
P = 1     # Number of partitions per row
I = 17048 # Number of rows to process
CHUNK_WORDS = N // P

assert N % P == 0

ROWS_PER_BATCH = 100 # Rows in each ping-pong buffer
NUM_WORKERS = 4      # Parallel DMA engines (capped by hardware)

# ==============================================================================
#  GLOBALS
# ==============================================================================

# Buffers (declared globally for cleanup)
a_chunks = []; result_bufs = []

# Asynchronous row processing
work_queue = queue.Queue(maxsize=8 * ROWS_PER_BATCH)
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

    for buf in a_chunks + result_bufs:
        try: 
            if buf is not None:
                buf.freebuffer()
        except Exception as e:
            print(f"[WARNING] Failed to free buffer: {e}")

def handle_interrupt(sig, frame):
    global stop_requested
    print("Interrupt received.")
    stop_requested = True
    sys.exit(0)

signal.signal(signal.SIGINT, handle_interrupt)

# ==============================================================================
#  WORKER + LOADER 
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

    if DEBUG > 1:
        actual = float(result[0])
        expected = np.dot(a, b)
        print(f"({row_num}) Actual: {actual:.24f} | Expected: {expected:.24f}")

def worker(worker_id, b, dma):
    if DEBUG: print(f"[WORKER {worker_id}] Starting up...")
        
    while not stop_requested:
        try: chunk_idx, local_row, global_row = work_queue.get(timeout=1)
        except queue.Empty: return

        process_row(global_row, a_chunks[chunk_idx][local_row], b, result_bufs[worker_id], dma)
        work_queue.task_done()

        if DEBUG > 1: print(f"[WORKER {worker_id}] Completed row {global_row}")

def loader_thread(f):
    chunk_index = 0
    row_idx = 0

    while row_idx < I and not stop_requested:
        buf = a_chunks[chunk_index]
        rows_to_load = min(ROWS_PER_BATCH, I - row_idx)

        for i in range(rows_to_load):
            view = memoryview(buf[i]).cast("B")
            if f.readinto(view) != N * 8: return # End of file

        for i in range(rows_to_load):
            global_row = row_idx + i
            work_queue.put((chunk_index, i, global_row))

        if DEBUG:
            print(f"[LOADER] Loaded chunk {chunk_index}, rows {row_idx} to {row_idx + rows_to_load - 1}")
            print(f"[DEBUG] Queue size: {work_queue.qsize()}")

        chunk_index ^= 1  # switch to the other buffer
        row_idx += rows_to_load

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":
    if DEBUG: 
        print(f"Parameters:")
        print(f"    N={N}, P={P}, I={I}, CHUNK_WORDS={CHUNK_WORDS},")
        print(f"    NUM_WORKERS={NUM_WORKERS}, ROWS_PER_BATCH={ROWS_PER_BATCH}")

    try:
        # Load bitstream
        overlay = Overlay(PROJ_DIR + "design_1.bit")
        overlay.download()

        # Get all DMAs listed in overlay ip_dict
        dmas = []
        for i in range(NUM_WORKERS):
            name = f"axi_dma_{i}"
            if name in overlay.ip_dict:
                dmas.append(getattr(overlay, name))

        # Write vector `b` to BRAM 
        b = np.arange(1, N+1, dtype=np.float64) / 100.0 # Dummy `b` vector
        bram_mmio = MMIO(BRAM_BASE, N*8)
        b_bits = b.view(np.uint64)
        for i in range(N):
            val64 = int(b_bits[i])
            bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
            bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)

        # Allocate buffers
        a_chunks = [
            allocate(shape=(ROWS_PER_BATCH, N), dtype=np.float64),
            allocate(shape=(ROWS_PER_BATCH, N), dtype=np.float64),
        ]
        result_bufs = [allocate(shape=(1,), dtype=np.float64) for _ in range(NUM_WORKERS)]

        # Create worker threads
        threads = [
            threading.Thread(target=worker, args=(i, b, dmas[i]))
            for i in range(NUM_WORKERS)
        ]

        with open(MTRX_PATH, "rb") as a_file:
            # Create loader thread
            loader = threading.Thread(target=loader_thread, args=(a_file,))

            print("Initialization complete.")

            # Execute and time
            t0 = time.perf_counter()
            loader.start()

            for t in threads: t.start()
            t1 = time.perf_counter()

            loader.join()
            t2 = time.perf_counter()

            work_queue.join()
            for t in threads: t.join() 
            t3 = time.perf_counter()

        # Finished
        print(f"Done.")
        print(f"Loader time:  {t2 - t0:.6f} seconds")
        print(f"Compute time: {t3 - t1:.6f} seconds")
        print(f"Total time:   {t3 - t0:.6f} seconds")

    finally: cleanup()

