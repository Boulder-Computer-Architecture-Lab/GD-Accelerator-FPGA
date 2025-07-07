#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pynq import allocate, MMIO
from time import sleep
import numpy as np
import subprocess

DEBUG = 1

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base
DMA0_BASE = 0x40400000 # DMA_0 base (send A, receive result)
DMA1_BASE = 0x40440000 # DMA_1 base (send B from BRAM)

N = 17048 # Row size (fixed in hardware)
P = 4     # Number of partitions per row
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
    a = allocate(shape=(N,), dtype=np.float64)
    result = allocate(shape=(1,), dtype=np.float64)

    if DEBUG: print("Initialization complete.")

    try:
        for i in range(I):
            # Load next N elements of matrix 
            data = a_file.read(N*8)
            a[:] = np.frombuffer(data, dtype=np.float64).copy()
    
            # Initiate DMA transfers
            for p in range(P):
                dma0_proc = subprocess.Popen([
                    "./dma_transfer", "mm2s",
                    hex(a.physical_address + p*CHUNK_BYTES), str(CHUNK_BYTES), hex(DMA0_BASE) 
                ])
                if (p == P-1): # Result transfer will stall if not positioned exactly here
                    rslt_proc = subprocess.Popen([
                        "./dma_transfer", "s2mm",
                        hex(result.physical_address), str(8), hex(DMA0_BASE)
                    ])
                dma1_proc = subprocess.Popen([
                    "./dma_transfer", "mm2s",
                    hex(BRAM_BASE + p*CHUNK_BYTES), str(CHUNK_BYTES), hex(DMA1_BASE)
                ])
                dma0_proc.wait()
                dma1_proc.wait()
                if (p == P-1): rslt_proc.wait()

            # Print results 
            if DEBUG: 
                actual = float(result[0])
                expected = np.dot(a, b)
                print(f"Actual ({i+1}): {actual}")
                print(f"Xpectd ({i+1}): {expected}")

            sleep(0.1) # temp

    finally: 
        # Cleanup
        a_file.close()
        a.freebuffer()
        result.freebuffer()

