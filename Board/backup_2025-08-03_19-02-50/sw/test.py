#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO, PL
import subprocess, threading, queue
import time, sys, signal, re
import numpy as np

from cdma_driver import CDMA

# ==============================================================================
#  MACROS
# ==============================================================================

DEBUG = 2

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"

CDMA_BASE = 0xA0000000 
BRAM_BASE = 0x80000000 

N = 8192 # Row size (fixed in hardware)
I = 1024 # Number of rows to process

NUM_CHANNELS = 4 
BYTES_PER_PARTITION = (N * 8) // NUM_CHANNELS

# ==============================================================================
#  GLOBALS
# ==============================================================================

# Buffers
matrix = None; b = None; result_bufs = []

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

    for buf in [matrix, b] + result_bufs:
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
        expected = np.dot(matrix[row_num], b.flatten())
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
    if DEBUG: print(f"Parameters: N={N}, I={I}, NUM_CHANNELS={NUM_CHANNELS}")

    try:
        # Load HW
        overlay = Overlay(PROJ_DIR + "design_1.bit")
        overlay.download()
        if not overlay.is_loaded():
            raise RuntimeError("Overlay download failed.")
        if DEBUG:
            for name, desc in PL.ip_dict.items():
                    if 'phys_addr' in desc:
                        print(f"{name}: 0x{desc['phys_addr']:08X}")
                    else:
                        print(f"{name}")
            print()

        # Get all DMAs listed in ip_dict
        dmas = [
            getattr(overlay, name)
            for name in sorted(overlay.ip_dict, key=lambda n: int(re.search(r"\d+$", n).group()))
            if name.startswith("axi_dma_")
        ]
        if (len(dmas) != NUM_CHANNELS):
            raise RuntimeError(f"Check overlay. Found {len(dmas)} DMAs with NUM_CHANNELS={NUM_CHANNELS}")

        # Write vector `b` to BRAM
        if DEBUG: print("Writing vector to BRAM")
        b = allocate(shape=(NUM_CHANNELS, N // NUM_CHANNELS), dtype=np.float64)
        cdma = CDMA(overlay.ip_dict['axi_cdma_0'])
        for i in range(NUM_CHANNELS):
            b[i, :] = np.arange(
                i * (N // NUM_CHANNELS) + 1,
                (i + 1) * (N // NUM_CHANNELS) + 1,
                dtype=np.float64
            ) / 10.0
            cdma.transfer(b[i], BRAM_BASE + i * BYTES_PER_PARTITION)

        # Allocate buffers
        if DEBUG: print("Allocating buffers")
        matrix = allocate(shape=(I, N), dtype=np.float64)
        result_bufs = [allocate(shape=(1,), dtype=np.float64) for _ in range(NUM_CHANNELS)]

        # Read in matrix
        if DEBUG: print("Reading matrix file")
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(I):
                view = memoryview(matrix[i]).cast("B")
                if a_file.readinto(view) != N * 8:
                    raise RuntimeError(f"Failed to read full row {i}")

        # Put rows in work queue
        if DEBUG: print("Filling work queue")
        [work_queue.put((i,)) for i in range(I)]

        # Create worker threads
        if DEBUG: print("Creating worker threads")
        threads = [
            threading.Thread(target=worker, args=(i, b, dmas[i]))
            for i in range(NUM_CHANNELS)
        ]

        print("Initialization complete")

        # Execute and time
        t0 = time.perf_counter()
        for t in threads: t.start()
        work_queue.join()
        for t in threads: t.join()
        t1 = time.perf_counter()

        print(f"Done. Total time: {t1 - t0:.6f} seconds")

    finally: cleanup()

