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

N = 16 # Size of input arrays (currently only works for N <= 85)

def float_to_bits(f):
    return struct.unpack('<Q', struct.pack('<d', f))[0]

if __name__ == "__main__":
    overlay = Overlay(PROJ_DIR + "design_1.bit")
    if DEBUG: print("Overlay loaded.")

    dma0 = overlay.axi_dma_0
    if DEBUG: print("DMA0 instantiated.")

    # Inputs
    a = np.arange(N, dtype=np.float64)
    b = np.arange(N, dtype=np.float64) * 10.0
    print("Input A (matrix from DRAM):", a)
    print("Input B (vector from BRAM):", b)

    # Write vector `b` to BRAM (split into low/high 32-bit writes)
    bram_mmio = MMIO(BRAM_BASE, N * 8)
    bram_buf = (ctypes.c_uint64 * N).from_buffer_copy(b)
    for i in range(N):
        val64 = bram_buf[i]
        bram_mmio.write(i * 8, val64 & 0xFFFFFFFF)
        bram_mmio.write(i * 8 + 4, (val64 >> 32) & 0xFFFFFFFF)
        time.sleep(0.001)
    if DEBUG: print("Wrote vector B to BRAM.")

    if DEBUG > 1:
        read_back = []
        for i in range(N):
            low = bram_mmio.read(i * 8)
            high = bram_mmio.read(i * 8 + 4)
            val64 = (high << 32) | low
            val = ctypes.c_double.from_buffer(ctypes.c_uint64(val64)).value
            read_back.append(val)
        print("Reading back BRAM contents:", np.array(read_back))

    # Allocate memory for input and output
    a_buf = allocate(shape=(N,), dtype=np.float64)
    result_buf = allocate(shape=(1,), dtype=np.float64)
    a_buf[:] = a
    if DEBUG: print("Buffers prepared.")

    # Start A buffer -> accelerator via DMA0 MM2S
    dma0_proc = subprocess.Popen([
        "./dma_transfer", "mm2s",
        hex(a_buf.physical_address), str(N * 8), hex(DMA0_BASE)
    ])
    if DEBUG: print("Matrix transfer (DMA0 MM2S) launched.")

    # Receive results into result_buf via DMA0 S2MM
    rslt_proc = subprocess.Popen([
        "./dma_transfer", "s2mm",
        hex(result_buf.physical_address), str(N * 8), hex(DMA0_BASE)
    ])
    if DEBUG: print("DMA0 S2MM result transfer launched.")

    # Start BRAM -> accelerator via DMA1 MM2S
    dma1_proc = subprocess.Popen([
        "./dma_transfer", "mm2s",
        hex(BRAM_BASE), str(N * 8), hex(DMA1_BASE)
    ])
    if DEBUG: print("BRAM transfer (DMA1 MM2S) launched.")

    # Wait to finish
    dma0_proc.wait()
    dma1_proc.wait()
    rslt_proc.wait()

    # Print results
    print("Output A . B: ", result_buf) # should be A + B
    if DEBUG > 1:
        print("Bit-level verification:")
        for i in range(len(result_buf)):
            a_bits = float_to_bits(a[i])
            b_bits = float_to_bits(b[i])
            res_bits = float_to_bits(result_buf[i])
            print(f"[{i}]: 0x{a_bits:016X} + 0x{b_bits:016X} = 0x{res_bits:016X}")

    # Cleanup
    a_buf.freebuffer()
    result_buf.freebuffer()

