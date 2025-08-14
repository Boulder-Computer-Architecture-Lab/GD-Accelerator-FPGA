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
I = 128  # number of rows (fixed in hardware)

NUM_CHANNELS = 4 

assert N % NUM_CHANNELS == 0
assert I % NUM_CHANNELS == 0

WORDS_PER_PARTITION = N // NUM_CHANNELS
BYTES_PER_PARTITION = WORDS_PER_PARTITION * 8
ROWS_PER_CHANNEL = I // NUM_CHANNELS

# ==============================================================================
#  HELPERS 
# ==============================================================================

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

def write_vec(overlay, b):
    cdma = CDMA(overlay.ip_dict['axi_cdma_0'])
    for i in range(NUM_CHANNELS):
        b[i, :] = np.arange( # Dummy `b` vector
            i * WORDS_PER_PARTITION + 1,
            (i + 1) * WORDS_PER_PARTITION + 1,
            dtype=np.float64) / 100.0

        if DEBUG: print(f"    Writing b[{i}] to addr 0x{BRAM_BASE + i * BYTES_PER_PARTITION:8x}")
        cdma.transfer(b[i], BRAM_BASE + i * BYTES_PER_PARTITION)

def worker(ch, dma, row_indices, matrix, result_buf, out_array, b_flat, start_barrier):

    start_barrier.wait()
    if DEBUG: print(f"[WORKER {ch}] Starting up...")

    for row_idx in row_indices:
        row = matrix[row_idx]
        dma.recvchannel.transfer(result_buf)
        dma.sendchannel.transfer(row)

        dma.sendchannel.wait()
        dma.recvchannel.wait()

        out_array[row_idx] = float(result_buf[0])

        if DEBUG > 1:
            actual = out_array[row_idx]
            expected = float(np.dot(row, b_flat))
            print(f"[WORKER {ch}] Completed row {row_idx}: actual={actual:.32f} | expected={expected:.32f}")

    print(f"[WORKER {ch}] Done.")

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":
    if DEBUG: print(f"Parameters: N={N}, I={I}, NUM_CHANNELS={NUM_CHANNELS}")

    matrix = b = results = None
    results_out = np.empty(I, dtype=np.float64)

    try:
        # Load overlay
        overlay = Overlay(BIT)
        overlay.download()
        if not overlay.is_loaded():
            raise RuntimeError("Overlay download failed.")

        # Get all DMAs 
        dmas = get_dmas(overlay)

        # Allocate buffers
        if DEBUG: print("Allocating buffers")
        matrix  = allocate(shape=(I, N), dtype=np.float64, cacheable=False)
        b       = allocate(shape=(NUM_CHANNELS, WORDS_PER_PARTITION), dtype=np.float64, cacheable=False)
        results = [allocate(shape=(1,), dtype=np.float64, cacheable=False) for _ in range(NUM_CHANNELS)]

        # Read matrix
        if DEBUG: print("Reading matrix file")
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(I):
                view = memoryview(matrix[i]).cast("B")
                if a_file.readinto(view) != N * 8:
                    raise RuntimeError(f"Failed to read full row {i}")

        # Write vector to BRAM with CDMA
        if DEBUG: print("Writing vector to BRAM")
        write_vec(overlay, b)

        # Create workers
        if DEBUG: print("Creating threads")
        rows_per_channel = [
            list(range(start, start + ROWS_PER_CHANNEL))
            for start in range(0, I, ROWS_PER_CHANNEL)
        ]
        threads = []
        start_barrier = threading.Barrier(NUM_CHANNELS)
        for ch in range(NUM_CHANNELS):
            t = threading.Thread(
                target=worker,
                args=(ch, dmas[ch], rows_per_channel[ch], matrix, results[ch], results_out, b.flatten(), start_barrier),
                daemon=True
            )
            threads.append(t)

        print("Initialization complete")

        # Execute and time
        t0 = time.perf_counter()
        for t in threads: t.start()
        for t in threads: t.join()
        t1 = time.perf_counter()

        print(f"Finished. Total time: {t1 - t0:.6f}s")

    finally:
        for buf in [matrix, b, results]:
            try:
                if buf is not None: buf.freebuffer()
            except: pass

