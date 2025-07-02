#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

from pynq import Overlay, allocate, MMIO

import numpy as np
import subprocess
import struct
import ctypes
import time

DEBUG = 1

PROJ_DIR = "/home/xilinx/mvm-project/hw/"
BRAM_BASE = 0x80000000
DMA0_BASE = 0x40400000  # DMA0 base (send A, receive result)
DMA1_BASE = 0x40440000  # DMA1 base (send B from BRAM)

N = 64   # Size of input arrays (stalls for N > ~85)
ITER = 1 # Send N elements this many times

if __name__ == "__main__":
    overlay = Overlay(PROJ_DIR + "design_1.bit")
    if DEBUG: print("Overlay loaded.")

    dma0 = overlay.axi_dma_0
    if DEBUG: print("DMA0 instantiated.")

    # Inputs
    a = [np.arange(i*N+1, (i+1)*N+1, dtype=np.float64) / 10.0 for i in range(ITER)]
    b = np.concatenate([
        np.arange(i*N+1, (i+1)*N+1, dtype=np.float64) / 100.0
        for i in range(ITER)
    ])
    print("Input A:", a)
    print("Input B:", b)

    # Write vector `b` to BRAM 
    bram_mmio = MMIO(BRAM_BASE, N*ITER*8)
    b_bits = b.view(np.uint64)
    for i in range(N*ITER):
        val64 = int(b_bits[i])
        bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
        bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)
        time.sleep(0.001)
    if DEBUG: print("Wrote vector B to BRAM.")

    # Allocate memory for buffers
    a_buf = allocate(shape=(N,), dtype=np.float64)
    result_buf = allocate(shape=(1,), dtype=np.float64)

    for i in range(ITER):

        # Load next chunk into buffer
        a_buf[:] = a[i]

        # Start A buffer -> accelerator via DMA0 MM2S
        dma0_proc = subprocess.Popen([
            "./dma_transfer", "mm2s",
            hex(a_buf.physical_address), str((N+1) * 8), hex(DMA0_BASE) # N+1 temp fix
        ])
        if DEBUG: print("Matrix transfer (DMA0 MM2S) launched.")

        # Receive results into result_buf via DMA0 S2MM
        rslt_proc = subprocess.Popen([
            "./dma_transfer", "s2mm",
            hex(result_buf.physical_address), str(8), hex(DMA0_BASE)
        ])
        if DEBUG: print("DMA0 S2MM result transfer launched.")

        # Start BRAM -> accelerator via DMA1 MM2S
        dma1_proc = subprocess.Popen([
            "./dma_transfer", "mm2s",
            hex(BRAM_BASE + i*N*8), str((N+1) * 8), hex(DMA1_BASE) # N+1 temp fix
        ])
        if DEBUG: print("BRAM transfer (DMA1 MM2S) launched.")

        # Wait to finish
        dma0_proc.wait()
        dma1_proc.wait()
        rslt_proc.wait()

        # Print intermediate result
        print(f"Output on iteration {i}: {result_buf}")
        time.sleep(1)

    # Print results
    print("Final output A . B: ", result_buf) 
    print("Expected: ", np.dot(a, b))

    # Cleanup
    a_buf.freebuffer()
    result_buf.freebuffer()

