#!/usr/bin/env -S sudo -E /usr/local/share/pynq-venv/bin/python3

# ==============================================================================
#  IMPORTS
# ==============================================================================

from pynq import Overlay, allocate, MMIO
import subprocess, threading
from time import sleep
import numpy as np

# ==============================================================================
#  MACROS
# ==============================================================================

DEBUG = 1

PROJ_DIR  = "/home/xilinx/mvm-project/hw/"
MTRX_PATH = "../trmult_reduced.bin"
BRAM_BASE = 0x80000000 # AXI_RAM_0 base
DMA0_BASE = 0x40400000 # DMA_0 base (send A_0, receive rslt_0)
DMA2_BASE = 0x40440000 # DMA_2 base (send A_1, receive rslt_1)

N = 17048 # Row size (fixed in hardware)
P = 8     # Number of partitions per row
I = 17048 # Number of rows to process

assert N % P == 0

CHUNK_WORDS = N // P
CHUNK_BYTES = CHUNK_WORDS * 8

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

def launch_dma_transfer(mode, addr, size, base):
    cmd = ["./dma_transfer", mode, hex(addr), str(size), hex(base)]
    proc = subprocess.Popen(cmd)
    dma_processes.append(proc)
    proc.wait()

def process_row(row_num, a, b, result, dma_base):
    rslt_thread = None
    for p in range(P):
        if (p == P-1):
            rslt_thread = threading.Thread(
                target=launch_dma_transfer,
                args=("s2mm", result.physical_address, 8, dma_base)
            )
            rslt_thread.start()

        offset = p * CHUNK_BYTES
        launch_dma_transfer("mm2s", a.physical_address + offset, CHUNK_BYTES, dma_base)

    if DEBUG: dump_dma_status(dma_base)
    if rslt_thread: rslt_thread.join()

    if DEBUG:
        actual = float(result[0])
        expected = np.dot(a, b)
        print(f"({row_num}) Result -> Actual: {actual:.24f} | Expected: {expected:.24f}")

# ==============================================================================
#  DEBUG HELPERS
# ==============================================================================

def dump_dma_status(base):
    status = MMIO(base + 0x34, 4).read(0)  # S2MM_DMASR or MM2S_DMASR
    print(f"DMA at 0x{base:X} status: 0x{status:08X}")

# ==============================================================================
#  MAIN
# ==============================================================================

if __name__ == "__main__":

    init()

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

        if DEBUG: print("Initialization complete.")

        with open(MTRX_PATH, "rb") as a_file:
            for i in range(0, I, 2):
                a_row0 = a_file.read(N*8)
                a_row1 = a_file.read(N*8)

                a0[:] = np.frombuffer(a_row0, dtype=np.float64)
                a1[:] = np.frombuffer(a_row1, dtype=np.float64)

                t0 = threading.Thread(target=process_row, args=(i, a0, b, result0, DMA0_BASE))
                t1 = threading.Thread(target=process_row, args=(i+1, a1, b, result1, DMA2_BASE))

                t0.start()
                t1.start()

                t0.join()
                t1.join()

    finally: cleanup()


