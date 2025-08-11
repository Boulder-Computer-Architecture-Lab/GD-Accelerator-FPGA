#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO, PL
import numpy as np
import time, re

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

N = 8192 # Row size (fixed in hardware)
I = 1024 # Number of rows to process

NUM_CHANNELS = 4 

assert N % NUM_CHANNELS == 0
assert I % NUM_CHANNELS == 0

# ==============================================================================
#  HELPERS 
# ==============================================================================

def get_dmas(overlay):
    dmas = [
        getattr(overlay, name)
        for name in sorted(overlay.ip_dict, key=lambda n: int(re.search(r"\d+$", n).group()))
        if name.startswith("axi_dma_")
    ]

    if len(dmas) != NUM_CHANNELS:
        raise RuntimeError(f"Check overlay. Found {len(dmas)} DMAs with NUM_CHANNELS={NUM_CHANNELS}")

    if DEBUG: print("DMAs:", [d.description['fullpath'] for d in dmas])

    return dmas

def write_vec(overlay, b):
    cdma = CDMA(overlay.ip_dict['axi_cdma_0'])
    bytes_per_partition = (N * 8) // NUM_CHANNELS
    for i in range(NUM_CHANNELS):
        b[i, :] = np.arange( # Dummy `b` vector
            i * (N // NUM_CHANNELS) + 1,
            (i + 1) * (N // NUM_CHANNELS) + 1,
            dtype=np.float64
        ) / 100.0
        cdma.transfer(b[i], BRAM_BASE + i * bytes_per_partition)

def prerotate_matrix(matrix):
    """
    ch0: ram0 -> ram1 -> ram2 -> ram3
    ch1: ram1 -> ram2 -> ram3 -> ram0
    ch2: ram2 -> ram3 -> ram0 -> ram1
    ch3: ram3 -> ram0 -> ram1 -> ram2
    """
    rows, cols = matrix.shape
    part = cols // NUM_CHANNELS
    rotated_matrix = np.empty_like(matrix)
    for row_idx in range(rows):
        ch = row_idx % NUM_CHANNELS
        rotated_matrix[row_idx] = np.roll(matrix[row_idx], -ch * part)
    return rotated_matrix

def compute(batch_rows, batch_idx, dmas, results, matrix, b):
    if DEBUG: print(f"\n[Batch {batch_idx}] Starting computation for rows {batch_rows}")

    # 1. Arm all S2MM first 
    for ch in range(NUM_CHANNELS):
        if DEBUG > 1: print(f"[Batch {batch_idx}] Arming S2MM ch{ch} for row {batch_rows[ch]}")
        dmas[ch].recvchannel.transfer(results[ch])

    # 2. Start all MM2S transfers
    for ch in range(NUM_CHANNELS):
        if DEBUG > 1: print(f"[Batch {batch_idx}] MM2S ch{ch} sending rotated row {batch_rows[ch]}")
        dmas[ch].sendchannel.transfer(matrix[batch_rows[ch]])

    # 3. Wait for all MM2S to complete
    for ch in range(NUM_CHANNELS):
        if DEBUG > 1: print(f"[Batch {batch_idx}] Waiting MM2S ch{ch}")
        dmas[ch].sendchannel.wait()

    # 4. Wait for all S2MM to complete 
    for ch in range(NUM_CHANNELS):
        if DEBUG > 1: print(f"[Batch {batch_idx}] Waiting S2MM ch{ch}")
        dmas[ch].recvchannel.wait()

        if DEBUG:
            actual = float(results[ch][0])
            expected = np.dot(matrix[batch_rows[ch]], np.roll(b.flatten(), ch * (N // NUM_CHANNELS)))
            print(f"[Batch {batch_idx}] ch{ch} -> "
                  f"Actual: {actual:.16f} | Expected: {expected:.16f}")

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":

    if DEBUG: print(f"Parameters: N={N}, I={I}, NUM_CHANNELS={NUM_CHANNELS}")

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
        matrix = allocate(shape=(I, N), dtype=np.float64)
        b = allocate(shape=(NUM_CHANNELS, N // NUM_CHANNELS), dtype=np.float64)
        results = [allocate(shape=(1,), dtype=np.float64) for _ in range(NUM_CHANNELS)]

        # Read and rotate matrix
        if DEBUG: print("Reading matrix file")
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(I):
                view = memoryview(matrix[i]).cast("B")
                if a_file.readinto(view) != N * 8:
                    raise RuntimeError(f"Failed to read full row {i}")
        matrix[:] = prerotate_matrix(matrix)

        # Write vector to BRAM with CDMA
        if DEBUG: print("Writing vector to BRAM")
        write_vec(overlay, b)

        print("Initialization complete")

        # Execute and time
        t0 = time.perf_counter()

        for batch_idx in range(0, I, NUM_CHANNELS):
            batch_rows = list(range(batch_idx, batch_idx + NUM_CHANNELS))
            compute(batch_rows, batch_idx // NUM_CHANNELS, dmas, results, matrix, b)

        t1 = time.perf_counter()
        print(f"Done. Total time: {t1 - t0:.6f}s")

    finally:
        for buf in [matrix, b] + results:
            try:
                buf.freebuffer()
            except: pass

