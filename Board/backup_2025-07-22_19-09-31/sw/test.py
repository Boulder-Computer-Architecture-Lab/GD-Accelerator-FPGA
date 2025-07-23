#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO, PL
import subprocess, threading, queue
import time, sys, signal, re
import numpy as np

# ==============================================================================
#  MACROS
# ==============================================================================

DEBUG = 0

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"

TEST_DIR  = "/home/xilinx/mvm-project/tests/"

ASYNC_1x1 = TEST_DIR + "async_1x1/"
ASYNC_1x2 = TEST_DIR + "async_1x2/"
ASYNC_1x4 = TEST_DIR + "async_1x4/"
ASYNC_2x1 = TEST_DIR + "async_2x1/"
ASYNC_2x2 = TEST_DIR + "async_2x2/"
ASYNC_2x3 = TEST_DIR + "async_2x3/"
ASYNC_3x1 = TEST_DIR + "async_3x1/"

SYNC_1x1 = TEST_DIR + "sync_1x1/"
SYNC_1x2 = TEST_DIR + "sync_1x2/"
SYNC_1x4 = TEST_DIR + "sync_1x4/"
SYNC_1x8 = TEST_DIR + "sync_1x8/"
SYNC_2x1 = TEST_DIR + "sync_2x1/"
SYNC_2x2 = TEST_DIR + "sync_2x2/"
SYNC_2x4 = TEST_DIR + "sync_2x4/"

BRAM_BASE = 0x80000000 

N = 8000 # Row size (fixed in hardware)
I = 1000 # Number of rows to process

#DMA_BATCH_SIZE = 4 # Number of rows per MM2S DMA transfer

ACCEL_INST = 2        # Number of mvm_accelerator instances
CHANNELS_PER_INST = 3 # Number of input channels per mvm_accelerator instance

NUM_WORKERS = ACCEL_INST * CHANNELS_PER_INST # Number of worker threads

# ==============================================================================
#  GLOBALS
# ==============================================================================

# Buffers
matrix = None; result_bufs = []

# Asynchronous row processing
work_queue = queue.Queue()
threads = []

# Gracefully exit on interrupt
stop_requested = False

# ==============================================================================
#  TERMINATION HANDLING
# ==============================================================================

def cleanup():
    print("\nCleaning up...")
        
    for t in threads:
        t.join(timeout=1)

    for buf in [matrix] + result_bufs:
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
#  WORKER 
# ==============================================================================

def process_row(row_num, b, result, dma):
    if stop_requested: return

    dma.recvchannel.transfer(result)
    dma.sendchannel.transfer(matrix[row_num])
    dma.sendchannel.wait()
    dma.recvchannel.wait()

    if DEBUG > 1:
        actual = float(result[0])
        expected = np.dot(matrix[row_num], b)
        print(f"({row_num}) Actual: {actual:.24f} | Expected: {expected:.24f}")

def worker(worker_id, b, dma):
    if DEBUG: print(f"[WORKER {worker_id}] Starting up...")

    while not stop_requested:
        try: (row_num,) = work_queue.get(timeout=1)
        except queue.Empty: return

        if DEBUG > 1: print(f"[WORKER {worker_id}] Processing row {row_num}")
        process_row(row_num, b, result_bufs[worker_id], dma)
        work_queue.task_done()
        if DEBUG > 1: print(f"[WORKER {worker_id}] Completed row {row_num}, Queue size: {work_queue.qsize()}")

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":
    if DEBUG: print(f"Parameters: N={N}, I={I}, NUM_WORKERS={NUM_WORKERS}")

    try:
        # Load bitstream
        overlay = Overlay(PROJ_DIR + "design_1.bit")
        overlay.download()
        if not overlay.is_loaded():
            raise RuntimeError("Overlay download failed.")

        # Get all DMAs listed in overlay ip_dict
        dmas = [
            getattr(overlay, name)
            for name in sorted(overlay.ip_dict, key=lambda n: int(re.search(r"\d+$", n).group()))
            if name.startswith("axi_dma_")
        ]
        if DEBUG:
            print("Found DMAs:")
            for dma in dmas: print(dma.description['fullpath'])

        if (len(dmas) != NUM_WORKERS):
            print(overlay.ip_dict.keys())
            raise RuntimeError(f"Check overlay. Found {len(dmas)} DMAs with NUM_WORKERS={NUM_WORKERS}")

        # Write vector `b` to BRAM(s)
        if DEBUG: print("Writing vector to BRAM")
        b = np.arange(1, N+1, dtype=np.float64) / 100.0 # Dummy `b` vector
        b_bits = b.view(np.uint64)

        bram = [MMIO(BRAM_BASE + 0x10000000 * inst, N * 8) for inst in range(ACCEL_INST)]

        for i in range(N):
            val64 = int(b_bits[i])
            for bm in bram:
                bm.write(i * 8, val64 & 0xFFFFFFFF)
                bm.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)

        # Allocate buffers
        if DEBUG: print("Allocating buffers")
        matrix = allocate(shape=(I, N), dtype=np.float64)
        result_bufs = [allocate(shape=(1,), dtype=np.float64) for _ in range(NUM_WORKERS)]

        # Read in matrix
        if DEBUG: print("Reading matrix file")
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(I):
                view = memoryview(matrix[i]).cast("B")
                if a_file.readinto(view) != N * 8:
                    raise RuntimeError(f"Failed to read full row {i}")

        # Put rows in work queue
        if DEBUG: print("Filling work queue")
        for i in range(I):
            work_queue.put((i,))

        # Create worker threads
        if DEBUG: print("Creating worker threads")
        threads = [
            threading.Thread(target=worker, args=(i, b, dmas[i]))
            for i in range(NUM_WORKERS)
        ]

        print("Initialization complete")

        # Execute and time
        t0 = time.perf_counter()
        for t in threads: t.start()
        work_queue.join()
        for t in threads: t.join()
        t1 = time.perf_counter()

        # Finished
        print(f"Done. Total time: {t1 - t0:.6f} seconds")

    finally: cleanup()

