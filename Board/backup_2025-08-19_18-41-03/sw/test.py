#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO, PL
import time, re, threading
import numpy as np

from cdma_driver import CDMA

# ==============================================================================
#  CONFIG
# ==============================================================================

DEBUG = 2

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
BIT       = PROJ_DIR + "design_1.bit"
MTRX_PATH = "../trmult_reduced.bin"

CDMA_BASE = 0xA0000000 
BRAM_BASE = 0x80000000 

N = 8192 # elements per row (fixed in hardware)
I = 1024 # number of rows (fixed in hardware)

NUM_CHANNELS = 4 

assert N % NUM_CHANNELS == 0
assert I % NUM_CHANNELS == 0

N_BYTES = N * 8

WORDS_PER_PARTITION = N // NUM_CHANNELS
BYTES_PER_PARTITION = WORDS_PER_PARTITION * 8
ROWS_PER_CHANNEL = I // NUM_CHANNELS

# ==============================================================================
#  HELPERS 
# ==============================================================================

def write_vec(overlay, b):
    if DEBUG: print("Writing vector to BRAM")

    cdma = CDMA(overlay.ip_dict['axi_cdma_0'])
    for i in range(NUM_CHANNELS): # Dummy `b` vector
        b[i, :] = np.arange(
            i * WORDS_PER_PARTITION + 1,
            (i + 1) * WORDS_PER_PARTITION + 1,
            dtype=np.float64) / 100.0

    for i in range(NUM_CHANNELS):
        if DEBUG: print(f"    Writing b[{i}] to addr 0x{BRAM_BASE + i * BYTES_PER_PARTITION:8x}")
        cdma.transfer(b[i], BRAM_BASE + i * BYTES_PER_PARTITION)

def get_dmas(overlay):
    dmas = [
        getattr(overlay, name)
        for name in sorted(overlay.ip_dict, key=lambda n: int(re.search(r"\d+$", n).group()))
        if name.startswith("axi_dma_")
    ]
    if DEBUG: print("DMAs:", [d.description['fullpath'] for d in dmas])
    if len(dmas) != NUM_CHANNELS:
        raise RuntimeError(f"Check overlay. Found {len(dmas)} DMAs with NUM_CHANNELS={NUM_CHANNELS}")
    return dmas

def create_workers(overlay, matrix, results):
    if DEBUG: print("Creating threads")

    dmas = get_dmas(overlay)
    rows_per_channel = [
        list(range(start, start + ROWS_PER_CHANNEL))
        for start in range(0, I, ROWS_PER_CHANNEL)
    ]

    threads = []
    for ch in range(NUM_CHANNELS):
        t = threading.Thread(
            target=worker,
            args=(ch, dmas[ch], rows_per_channel[ch], matrix, results[ch]),
            daemon=True
        )
        threads.append(t)
    return threads

def worker(ch, dma, row_indices, matrix, result_buf):
    if DEBUG: print(f"[WORKER {ch}] Starting up...")

    dma.recvchannel.transfer(result_buf)
    for count,row_idx in enumerate(row_indices):
        dma.sendchannel.transfer(matrix[row_idx])
        dma.sendchannel.wait()
        if DEBUG > 1: print(f"[WORKER {ch}] Sent row {row_idx} (count={count})")
    dma.recvchannel.wait()

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":
    if DEBUG: print(f"Parameters: N={N}, I={I}, NUM_CHANNELS={NUM_CHANNELS}")
    matrix = b = results = None

    try:
        # Load overlay
        overlay = Overlay(BIT)
        overlay.download()
        if not overlay.is_loaded():
            raise RuntimeError("Overlay download failed.")

        # Allocate buffers
        if DEBUG: print("Allocating buffers")
        matrix  = allocate(shape=(I, N), dtype=np.float64, cacheable=False)
        b       = allocate(shape=(NUM_CHANNELS, WORDS_PER_PARTITION), dtype=np.float64, cacheable=False)
        results = [allocate(shape=(ROWS_PER_CHANNEL,), dtype=np.float64, cacheable=False) for _ in range(NUM_CHANNELS)]

        # Read matrix into DRAM
        if DEBUG: print("Reading matrix file")
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(I):
                view = memoryview(matrix[i]).cast("B")
                if a_file.readinto(view) != N * 8:
                    raise RuntimeError(f"Failed to read full row {i}")

        threads = create_workers(overlay, matrix, results) # Create worker threads
        write_vec(overlay, b) # Write vector to BRAM with CDMA

        # Execute
        print("Starting computation...")
        t0 = time.perf_counter()
        for t in threads: t.start()
        for t in threads: t.join()
        t1 = time.perf_counter()
        print(f"Finished. Total time: {t1 - t0:.6f}s")

        # Print results
        if DEBUG > 1:
            for i in range(NUM_CHANNELS):
                for j in range(ROWS_PER_CHANNEL):
                    row_idx = i * ROWS_PER_CHANNEL + j
                    actual = results[i][j]
                    expected = float(np.dot(matrix[row_idx], b.flatten()))
                    print(f"Row {row_idx}: actual={actual:.32f} | expected={expected:.32f}")

    finally:
        for buf in [matrix, b] + (results or []):
            try:
                if buf is not None: buf.freebuffer()
            except: pass

