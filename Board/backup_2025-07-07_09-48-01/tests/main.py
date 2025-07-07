#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

"""
This is a variation of main.py which doesn't use the custom bram logic and instead
writes directly to the DMAs for both streaming inputs to the accelerator. This
requires an additional connection from PS/S_AXI_HP* -> AXI_DMA_1/M_AXI_MM2S in Vivado.
"""

from pynq import allocate, MMIO

import numpy as np
import subprocess
import struct
import ctypes
import time

DEBUG = 1

PROJ_DIR = "/home/xilinx/mvm-project/hw/"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base
DMA0_BASE = 0x40400000 # DMA0 base (send A, receive result)
DMA1_BASE = 0x40440000 # DMA1 base (send B from BRAM)

N = 16384 # Size of input arrays (fixed in hardware)
ITER = 2  # Send N elements this many times

if __name__ == "__main__":
    if DEBUG: print(f"N={N}, ITER={ITER}")

    # Inputs
    a = np.arange(1, N+1, dtype=np.float64) / 100.0
    b = np.arange(1, N+1, dtype=np.float64) / 1000.0

    if DEBUG > 1: 
        print("Input A:", a)
        print("Input B:", b)

    # Allocate buffers
    a_buf = allocate(shape=(N,), dtype=np.float64)
    b_buf = allocate(shape=(N,), dtype=np.float64)
    result_buf = allocate(shape=(1,), dtype=np.float64)

    if DEBUG: print("Initialization complete.")

    try:
        for i in range(ITER):

            # Load next chunk into buffer
            a_buf[:] = a
            b_buf[:] = b

            # Start A buffer -> accelerator via DMA0 MM2S
            dma0_proc = subprocess.Popen([
                "./dma_transfer", "mm2s",
                hex(a_buf.physical_address), str(N * 8), hex(DMA0_BASE) 
            ])
            if DEBUG > 1: print("Matrix transfer (DMA0 MM2S) launched.")

            # Receive results into result_buf via DMA0 S2MM
            rslt_proc = subprocess.Popen([
                "./dma_transfer", "s2mm",
                hex(result_buf.physical_address), str(8), hex(DMA0_BASE)
            ])
            if DEBUG > 1: print("DMA0 S2MM result transfer launched.")

            # Start BRAM -> accelerator via DMA1 MM2S
            dma1_proc = subprocess.Popen([
                "./dma_transfer", "mm2s",
                hex(b_buf.physical_address), str(N * 8), hex(DMA1_BASE)
            ])
            if DEBUG > 1: print("BRAM transfer (DMA1 MM2S) launched.")

            # Wait to finish
            dma0_proc.wait()
            dma1_proc.wait()
            rslt_proc.wait()

            # Print results
            if DEBUG:
                actual = float(result_buf[0])
                expected = np.dot(a, b)
                print(f"Actual ({i+1}): {actual}")
                print(f"Xpectd ({i+1}): {expected}")

    finally:
        # Cleanup
        a_buf.freebuffer()
        b_buf.freebuffer()
        result_buf.freebuffer()

