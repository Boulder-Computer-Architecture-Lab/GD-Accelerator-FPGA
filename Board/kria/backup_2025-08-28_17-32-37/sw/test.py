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

DEBUG = 1

PROJ_DIR  = "/home/ubuntu/mvm-accelerator/hw/"
BIT       = PROJ_DIR + "design_1.bit"
MTRX_PATH = "../trmult_reduced.bin"

# The following values are fixed in hardware:

CDMA_BASE = 0xA0000000 
BRAM_BASE = 0x80000000 

NUM_ROWS = 1024
NUM_CHANNELS = 1 
ROWS_PER_CHANNEL = NUM_ROWS // NUM_CHANNELS

WORD_WIDTH = 64
ELEMENT_WIDTH = 64
ELEMENTS_PER_WORD = WORD_WIDTH // ELEMENT_WIDTH
BYTES_PER_WORD = WORD_WIDTH // 8

ELEMENTS_PER_ROW = 8192
WORDS_PER_ROW = ELEMENTS_PER_ROW // ELEMENTS_PER_WORD
BYTES_PER_ROW = WORDS_PER_ROW * BYTES_PER_WORD

NUM_PARTITIONS = NUM_CHANNELS

ELEMENTS_PER_PARTITION = ELEMENTS_PER_ROW // NUM_PARTITIONS
WORDS_PER_PARTITION = WORDS_PER_ROW // NUM_PARTITIONS
BYTES_PER_PARTITION = WORDS_PER_PARTITION * BYTES_PER_WORD

# ==============================================================================
#  ASSERTIONS 
# ==============================================================================

assert WORD_WIDTH % ELEMENT_WIDTH == 0
assert ELEMENTS_PER_ROW % NUM_CHANNELS == 0
assert NUM_ROWS % NUM_CHANNELS == 0

# ==============================================================================
#  HELPERS 
# ==============================================================================

def allocate_buf(dim1, dim2=None):
    if dim2 is not None:
        return allocate(shape=(dim1, dim2), dtype=np.float64, cacheable=False)
    else:
        return allocate(shape=(dim1,), dtype=np.float64, cacheable=False)

def write_vec(overlay, vector):
    if DEBUG: print("Writing vector to BRAM.")
    cdma = CDMA(overlay.ip_dict['axi_cdma_0'])

    # Dummy vector
    for i in range(NUM_PARTITIONS):
        vector[i, :] = np.arange(
            i * ELEMENTS_PER_PARTITION + 1,
            (i + 1) * ELEMENTS_PER_PARTITION + 1,
            dtype=np.float64) / 10000.0

    for i in range(NUM_PARTITIONS):
        dest = BRAM_BASE + i * BYTES_PER_PARTITION
        if DEBUG: print(f"    vec[{i}]: src_addr=0x{vector[i].physical_address:8x}, dest_addr=0x{dest:8x}")
        cdma.transfer(vector[i], dest)

def get_dmas(overlay):
    dmas = [
        getattr(overlay, name)
        for name in sorted(overlay.ip_dict, key=lambda n: int(re.search(r"\d+$", n).group()))
        if name.startswith("axi_dma_")
    ]
    if DEBUG: print("DMAs:", [d.description['fullpath'] for d in dmas])
    if len(dmas) != NUM_CHANNELS:
        raise RuntimeError(f"Check overlay. Found {len(dmas)} DMAs with NUM_CHANNELS={NUM_CHANNELS}.")
    return dmas

def create_workers(dmas, matrix):
    if DEBUG: print("Creating threads.")

    rows_per_channel = [
        list(range(start, start + ROWS_PER_CHANNEL))
        for start in range(0, NUM_ROWS, ROWS_PER_CHANNEL)
    ]

    threads = []
    for ch in range(NUM_CHANNELS):
        t = threading.Thread(
            target=worker,
            args=(ch, dmas[ch], rows_per_channel[ch], matrix),
            daemon=True
        )
        threads.append(t)
    return threads

def worker(ch, dma, row_indices, matrix):
    if DEBUG: print(f"[WORKER {ch}] Starting up...")
    for count,row_idx in enumerate(row_indices):
        dma.sendchannel.transfer(matrix[row_idx])
        dma.sendchannel.wait()
        if DEBUG > 1: print(f"[WORKER {ch}] Sent row {row_idx} (count={count})")

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":
    if DEBUG: 
        print(f"Parameters: ", end="")
        print(f"""
    CDMA_BASE = {CDMA_BASE:8X}
    BRAM_BASE = {BRAM_BASE:8X}

    NUM_ROWS         = {NUM_ROWS}
    NUM_CHANNELS     = {NUM_CHANNELS} 
    ROWS_PER_CHANNEL = {ROWS_PER_CHANNEL}

    WORD_WIDTH        = {WORD_WIDTH}
    ELEMENT_WIDTH     = {ELEMENT_WIDTH}
    ELEMENTS_PER_WORD = {ELEMENTS_PER_WORD}
    BYTES_PER_WORD    = {BYTES_PER_WORD}

    ELEMENTS_PER_ROW = {ELEMENTS_PER_ROW}
    WORDS_PER_ROW    = {WORDS_PER_ROW}
    BYTES_PER_ROW    = {BYTES_PER_ROW}

    NUM_PARTITIONS = {NUM_PARTITIONS}

    ELEMENTS_PER_PARTITION = {ELEMENTS_PER_PARTITION}
    WORDS_PER_PARTITION    = {WORDS_PER_PARTITION}
    BYTES_PER_PARTITION    = {BYTES_PER_PARTITION}""")

    PL.reset()
    matrix = vector = result = None 

    try:
        # Load overlay
        overlay = Overlay(BIT)
        overlay.download()
        if not overlay.is_loaded():
            raise RuntimeError("Overlay download failed.")
        dmas = get_dmas(overlay)

        # Allocate buffers
        if DEBUG: print("Allocating buffers.")
        matrix =  allocate_buf(NUM_ROWS, ELEMENTS_PER_ROW)
        vector =  allocate_buf(NUM_PARTITIONS, ELEMENTS_PER_PARTITION)
        result = [allocate_buf(ROWS_PER_CHANNEL) for _ in range(NUM_CHANNELS)]
        if DEBUG:
            print(f"matrix: src_addr={matrix.physical_address:8X}")
            print(f"vector: src_addr={vector.physical_address:8X}")
            print(f"result: src_addr={result.physical_address:8X}")

        # Read matrix into DRAM
        if DEBUG: print("Reading matrix file.")
        with open(MTRX_PATH, "rb") as a_file:
            for i in range(NUM_ROWS):
                view = memoryview(matrix[i]).cast("B")
                if a_file.readinto(view) != BYTES_PER_ROW:
                    raise RuntimeError(f"Failed to read full row {i}.")
                if DEBUG > 1: print(f"matrix[{i}]: {matrix[i]}")

        # Write vector to BRAM
        t0_vec = time.perf_counter()
        write_vec(overlay, vector) 
        t1_vec = time.perf_counter()

        # Execute
        threads = create_workers(dmas, matrix)

        print("Starting computation...")
        t0_comp = time.perf_counter()

        for ch in range(NUM_CHANNELS):
            dmas[ch].recvchannel.transfer(result[ch])

        for t in threads: t.start()
        for t in threads: t.join()

        for ch in range(NUM_CHANNELS):
            dmas[ch].recvchannel.wait()

        t1_comp = time.perf_counter()
        print(f"Finished.")

        # Print results
        if DEBUG:
            for i in range(NUM_CHANNELS):
                for j in range(ROWS_PER_CHANNEL):
                    row_idx = i * ROWS_PER_CHANNEL + j
                    actual = result[i][j]
                    expected = float(np.dot(matrix[row_idx], vector.flatten()))
                    print(f"Row {row_idx}: Actual={actual:.32f} | Expected={expected:.32f}")
        print(f"Overhead time: {t1_vec - t0_vec:.6f}s")
        print(f"Compute time:  {t1_comp - t0_comp:.6f}s")

    finally:
        for buf in [matrix, vector] + (result or []):
            try:
                if buf is not None: buf.freebuffer()
            except: pass

