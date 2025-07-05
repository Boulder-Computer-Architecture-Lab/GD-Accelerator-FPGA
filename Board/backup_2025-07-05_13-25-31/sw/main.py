#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pynq import allocate, MMIO

import numpy as np
import subprocess
import struct
import ctypes
import time

DEBUG = 1

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base
DMA0_BASE = 0x40400000 # DMA_0 base (send A, receive result)
DMA1_BASE = 0x40440000 # DMA_1 base (send B from BRAM)

N = 16384 # Size of input arrays (fixed in hardware)
ITER = 1  # Send N elements this many times

if __name__ == "__main__":
    if DEBUG: print(f"N={N}, ITER={ITER}")

    # Open matrix file
    a_file = open(MTRX_PATH, "rb")

    # Dummy `b` vector
    b = np.arange(1, N+1, dtype=np.float64) / 1000.0

    if DEBUG > 1: 
        print("Input A:", a)
        print("Input B:", b)

    # Write vector `b` to BRAM 
    bram_mmio = MMIO(BRAM_BASE, N*ITER*8)
    b_bits = b.view(np.uint64)
    for i in range(N):
        val64 = int(b_bits[i])
        bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
        bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)
        time.sleep(0.001)
    if DEBUG > 1: print("Wrote vector B to BRAM.")

    # Allocate buffers
    if DEBUG > 1: print("Allocating buffers.")
    a = allocate(shape=(N,), dtype=np.float64)
    result = allocate(shape=(1,), dtype=np.float64)

    if DEBUG: print("Initialization complete.")

    try:
        for i in range(ITER):
            # Load next N elements of matrix 
            data = a_file.read(N*8)
            if len(data) < N * 8:
                print(f"Not enough data left for iteration {i+1}")
                break
            a[:] = np.frombuffer(data, dtype=np.float64).copy()

            # Start `a` buffer -> accelerator via DMA0 MM2S
            dma0_proc = subprocess.Popen([
                "./dma_transfer", "mm2s",
                hex(a.physical_address), str(N * 8), hex(DMA0_BASE) 
            ])
            if DEBUG > 1: print("Matrix transfer (DMA0 MM2S) launched.")

            # Receive results via DMA0 S2MM
            rslt_proc = subprocess.Popen([
                "./dma_transfer", "s2mm",
                hex(result.physical_address), str(8), hex(DMA0_BASE)
            ])
            if DEBUG > 1: print("DMA0 S2MM result transfer launched.")

            # Start BRAM -> accelerator via DMA1 MM2S
            dma1_proc = subprocess.Popen([
                "./dma_transfer", "mm2s",
                hex(BRAM_BASE), str(N * 8), hex(DMA1_BASE)
            ])
            if DEBUG > 1: print("BRAM transfer (DMA1 MM2S) launched.")

            # Wait to finish
            dma0_proc.wait()
            dma1_proc.wait()
            rslt_proc.wait()

            # Print results 
            if DEBUG:
                actual = float(result[0])
                expected = np.dot(a, b)
                print(f"Actual ({i+1}): {actual}")
                print(f"Xpectd ({i+1}): {expected}")

    finally: 
        # Cleanup
        a_file.close()
        a.freebuffer()
        result.freebuffer()

