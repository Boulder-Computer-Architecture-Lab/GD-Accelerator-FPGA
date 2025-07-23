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

DEBUG = 2

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"

BRAM_BASE = 0x80000000 

N = 8000 # Row size (fixed in hardware)
I = 1000 # Number of rows to process

ROWS_PER_BATCH = 100  # Number of rows in each ping-pong buffer

ACCEL_INST = 3        # Number of mvm_accelerator instances
CHANNELS_PER_INST = 2 # Number of input channels per mvm_accelerator instance
NUM_WORKERS = ACCEL_INST * CHANNELS_PER_INST # Number of worker threads

# ==============================================================================
#  GLOBALS
# ==============================================================================

# Buffers (declared globally for cleanup)
a_chunks = []; result_bufs = []

# Track loader status
buffer_in_use = [False, False]
buffer_lock = threading.Lock()
buffer_ready = threading.Condition(buffer_lock)
rows_done = [0, 0]

# Asynchronous row processing
work_queue = queue.Queue(maxsize=8 * ROWS_PER_BATCH)
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

def process_row(row_num, chunk_idx, local_row, total_rows_in_chunk, a, b, result, dma):
    if stop_requested: return

    dma.recvchannel.transfer(result)
    chunk = a[local_row]
    dma.sendchannel.transfer(chunk)
    dma.sendchannel.wait()
    dma.recvchannel.wait()

    if DEBUG > 1:
        actual = float(result[0])
        expected = np.dot(a[local_row], b)
        print(f"({row_num}) Actual: {actual:.24f} | Expected: {expected:.24f}")

    with buffer_ready:
        rows_done[chunk_idx] += 1
        if rows_done[chunk_idx] >= ROWS_PER_BATCH:
            buffer_in_use[chunk_idx] = False
            rows_done[chunk_idx] = 0
            if DEBUG: print(f"[WORKER] Notifying loader for chunk {chunk_idx}")
            buffer_ready.notify()

def worker(worker_id, b, dma):
    if DEBUG: print(f"[WORKER {worker_id}] Starting up...")
        
    while not stop_requested:
        try: chunk_idx, local_row, global_row, total_rows = work_queue.get(timeout=1)
        except queue.Empty: return

        if DEBUG > 1: print(f"[WORKER {worker_id}] Processing row {global_row}")
        process_row(global_row, chunk_idx, local_row, total_rows, a_chunks[chunk_idx], b, result_bufs[worker_id], dma)
        work_queue.task_done()
        if DEBUG > 1: print(f"[WORKER {worker_id}] Completed row {global_row}, Queue size: {work_queue.qsize()}")

def loader_thread(f):
    chunk_index = 0
    row_idx = 0

    while row_idx < I and not stop_requested:
        with buffer_ready:
            while buffer_in_use[chunk_index]: 
                buffer_ready.wait()
            buffer_in_use[chunk_index] = True

        buf = a_chunks[chunk_index]
        rows_to_load = min(ROWS_PER_BATCH, I - row_idx)

        for i in range(rows_to_load):
            view = memoryview(buf[i]).cast("B")
            if f.readinto(view) != N * 8: 
                print(f"[LOADER] Incomplete row{i}, read {bytes_read} bytes - aborting")
                return

        for i in range(rows_to_load):
            global_row = row_idx + i
            work_queue.put((chunk_index, i, global_row, rows_to_load))

        if DEBUG: 
            print(f"[LOADER] Loaded chunk {chunk_index}, rows {row_idx} to {row_idx + rows_to_load - 1}")
            print(f"[LOADER] Queue size after chunk {chunk_index}: {work_queue.qsize()}")

        row_idx += rows_to_load
        chunk_index ^= 1 # switch to the other buffer

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":
    if DEBUG: print(f"Parameters: N={N}, I={I}, NUM_WORKERS={NUM_WORKERS}, ROWS_PER_BATCH={ROWS_PER_BATCH}")

    try:
        # Load bitstream
        overlay = Overlay(PROJ_DIR + "design_1.bit")
        overlay.download()

        # Get all DMAs listed in overlay ip_dict
        dmas = [
            getattr(overlay, name)
            for name in sorted(overlay.ip_dict, key=lambda n: int(re.search(r"\d+$", n).group()))
            if name.startswith("axi_dma_")
        ]

        # Write vector `b` to BRAM(s)
        b = np.arange(1, N+1, dtype=np.float64) / 100.0 # Dummy `b` vector
        b_bits = b.view(np.uint64)

        bram = [MMIO(BRAM_BASE + 0x10000000 * inst, N * 8) for inst in range(ACCEL_INST)]

        for i in range(N):
            val64 = int(b_bits[i])
            for bm in bram:
                bm.write(i * 8, val64 & 0xFFFFFFFF)
                bm.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)

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

