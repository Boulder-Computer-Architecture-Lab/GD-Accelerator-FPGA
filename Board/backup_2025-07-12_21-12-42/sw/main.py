#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO
import subprocess, threading
import numpy as np
import time

# ==============================================================================
#  MACROS
# ==============================================================================

DEBUG = 0

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base
DMA0_BASE = 0x40400000 # DMA_0 base (send A_0, receive rslt_0)
DMA2_BASE = 0x40440000 # DMA_2 base (send A_1, receive rslt_1)

N = 17048 # Row size (fixed in hardware)
P = 4     # Number of partitions per row
I = 17048 # Number of rows to process

assert N % P == 0

CHUNK_WORDS = N // P

# ==============================================================================
#  GLOBALS
# ==============================================================================

# Buffers (declared globally for cleanup)
a0 = None; a1 = None; result0 = None; result1 = None

# Track subprocesses
dma_processes = []

# ==============================================================================
#  TERMINATION HANDLING
# ==============================================================================

def cleanup():
    global a0, a1, result0, result1

    if DEBUG: print("\nCleaning up...")
        
    for proc in dma_processes:
        if proc.poll() is None: # still running
            proc.terminate()
            proc.wait()

    for buf in [a0, a1, result0, result1]:
        if buf is not None:
            buf.freebuffer()

# ==============================================================================
#  HELPERS
# ==============================================================================

def init():
    global a0, a1, result0, result1

    a0 = allocate(shape=(N,), dtype=np.float64)
    a1 = allocate(shape=(N,), dtype=np.float64)
    result0 = allocate(shape=(1,), dtype=np.float64)
    result1 = allocate(shape=(1,), dtype=np.float64)

    overlay = Overlay(PROJ_DIR + "design_1.bit")
    overlay.download()
    return overlay.axi_dma_0, overlay.axi_dma_2

def process_row(row_num, a, b, result, dma):

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

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":

    dma0, dma2 = init()

    if DEBUG: print(f"N={N}, P={P}, I={I}, WORDS_PER_CHUNK={CHUNK_WORDS}")

    try:
        b = np.arange(1, N+1, dtype=np.float64) / 100.0 # Dummy `b` vector

        # Write vector `b` to BRAM 
        bram_mmio = MMIO(BRAM_BASE, N*8)
        b_bits = b.view(np.uint64)
        for i in range(N):
            val64 = int(b_bits[i])
            bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
            bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)

        print("Initialization complete.")

        with open(MTRX_PATH, "rb") as a_file:
            start_time = time.perf_counter()

            for i in range(0, I, 2):
                a_row0 = a_file.read(N*8)
                a_row1 = a_file.read(N*8)

                a0[:] = np.frombuffer(a_row0, dtype=np.float64)
                a1[:] = np.frombuffer(a_row1, dtype=np.float64)

                t0 = threading.Thread(target=process_row, args=(i, a0, b, result0, dma0))
                t1 = threading.Thread(target=process_row, args=(i+1, a1, b, result1, dma2))


                t0.start()
                t1.start()

                t0.join()
                t1.join()

        end_time = time.perf_counter()
        elapsed = end_time - start_time
        print(f"Done. Compute time: {elapsed:.6f} seconds")

    finally: cleanup()

