#!/usr/bin/python3

import numpy as np
import argparse
import os

MTRX_FILE = "../../Board/kria/matrix.npy"

def main():
    parser = argparse.ArgumentParser(description="Generate a random matrix and save to .npy")
    parser.add_argument("num_channels", type=int, help="Number of channels")
    parser.add_argument("rows_per_channel", type=int, help="Number of rows per channel")
    parser.add_argument("num_cols", type=int, help="Number of columns")
    args = parser.parse_args()

    num_channels     = args.num_channels
    rows_per_channel = args.rows_per_channel
    num_cols         = args.num_cols

    matrix_data = np.random.rand(num_channels, rows_per_channel, num_cols).astype(np.float16)
    np.save(MTRX_FILE, matrix_data)
    print(f"Matrix saved to {os.path.abspath(MTRX_FILE)}")

if __name__ == "__main__":
    main()

