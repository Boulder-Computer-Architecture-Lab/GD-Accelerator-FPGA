#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pynq import allocate, MMIO
from time import sleep
import numpy as np
import subprocess

DEBUG = 1

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base
DMA0_BASE = 0x40400000 # DMA_0 base (send A_0, receive rslt_0)
DMA1_BASE = 0x40440000 # DMA_1 base (send B from BRAM)
DMA2_BASE = 0x40480000 # DMA_2 base (send A_1, receive rslt_1)

N = 17048 # Row size (fixed in hardware)
P = 8     # Number of partitions per row
I = 17048 # Number of rows to process

assert N % P == 0

CHUNK_WORDS = N // P
CHUNK_BYTES = CHUNK_WORDS * 8

if __name__ == "__main__":
    if DEBUG: print(f"N={N}, P={P}, I={I}, WORDS_PER_CHUNK={CHUNK_WORDS}")

    # Open matrix file
    a_file = open(MTRX_PATH, "rb")

    # Dummy `b` vector
    b = np.arange(1, N+1, dtype=np.float64) / 1000.0

    # Write vector `b` to BRAM 
    bram_mmio = MMIO(BRAM_BASE, N*8)
    b_bits = b.view(np.uint64)
    for i in range(N):
        val64 = int(b_bits[i])
        bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
        bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)
    sleep(0.001)

    # Allocate buffers
    a0 = allocate(shape=(N,), dtype=np.float64)
    a1 = allocate(shape=(N,), dtype=np.float64)
    result0 = allocate(shape=(1,), dtype=np.float64)
    result1 = allocate(shape=(1,), dtype=np.float64)

    if DEBUG: print("Initialization complete.")

    try:
        for i in range(0, I, 2):
            # Load next two rows of matrix
            a_row0 = a_file.read(N*8)
            a_row1 = a_file.read(N*8)
            a0[:] = np.frombuffer(a_row0, dtype=np.float64).copy()
            a1[:] = np.frombuffer(a_row1, dtype=np.float64).copy()
    
            # Initiate DMA transfers
            for p in range(P):
                offset = p * CHUNK_BYTES

                dma0_proc = subprocess.Popen([
                    "./dma_transfer", "mm2s",
                    hex(a0.physical_address + offset), str(CHUNK_BYTES), hex(DMA0_BASE) 
                ])
                dma2_proc = subprocess.Popen([
                    "./dma_transfer", "mm2s",
                    hex(a1.physical_address + offset), str(CHUNK_BYTES), hex(DMA2_BASE) 
                ])
                if (p == P-1): # Result transfer will stall if not positioned exactly here
                    rslt0_proc = subprocess.Popen([
                        "./dma_transfer", "s2mm",
                        hex(result0.physical_address), str(8), hex(DMA0_BASE)
                    ])
                    rslt1_proc = subprocess.Popen([
                        "./dma_transfer", "s2mm",
                        hex(result1.physical_address), str(8), hex(DMA2_BASE)
                    ])
                dma1_proc = subprocess.Popen([
                    "./dma_transfer", "mm2s",
                    hex(BRAM_BASE + offset), str(CHUNK_BYTES), hex(DMA1_BASE)
                ])
                dma0_proc.wait()
                dma2_proc.wait()
                dma1_proc.wait()

                if (p == P-1): 
                    rslt0_proc.wait()
                    rslt1_proc.wait()

            # Print results 
            if DEBUG: 
                actual0 = float(result0[0])
                expected0 = np.dot(a0, b)

                actual1 = float(result1[0])
                expected1 = np.dot(a1, b)

                print(f"Row {i+1} -> Actual: {actual0:.16f} | Expected: {expected0:.16f}")
                print(f"Row {i+2} -> Actual: {actual1:.16f} | Expected: {expected1:.16f}")

            sleep(0.1) # temp

    finally: 
        # Cleanup
        a_file.close()
        a0.freebuffer()
        a1.freebuffer()
        result0.freebuffer()
        result1.freebuffer()

