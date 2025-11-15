#!/usr/bin/env python3

import os

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))
SOURCES_PATH = os.path.join(SCRIPT_DIR, "../hdl")
XBAR_WR_CHANNELS_PATH = os.path.join(SOURCES_PATH, "xbar_wr_channels.vh")
XBAR_RD_CHANNELS_PATH = os.path.join(SOURCES_PATH, "xbar_rd_channels.vh")

axi_wr_signals = [
    # WRITE-ADDRESS
    "awid", "awaddr", "awlen", "awsize", "awburst", "awlock",
    "awcache", "awprot", "awvalid", "awready",
    # WRITE-DATA
    "wdata", "wstrb", "wlast", "wvalid", "wready",
    # WRITE-RESPONSE
    "bid", "bresp", "bvalid", "bready"
]

axi_rd_signals = [
    # READ-ADDRESS
    "arid", "araddr", "arlen", "arsize", "arburst", "arlock",
    "arcache", "arprot", "arvalid", "arready",
    # READ-DATA
    "rid", "rdata", "rresp", "rlast", "rvalid", "rready"
]

def _vec_concat(base, n):
    return "{%s}" % ", ".join(f"{base}[{i}]" for i in reversed(range(n)))

def generate_xbar_wr_channels(num_partitions):
    lines = []
    for sig in axi_wr_signals:
        lines.append(f".s_axi_{sig:<8} (s_axi_b_{sig}),")
    lines.append("")

    for sig in axi_wr_signals:
        base = f"ram_m_axi_{sig}"
        lines.append(f".m_axi_{sig:<8} ({_vec_concat(base, num_partitions)}),")
    lines.append("")

    return "\n".join(lines)

def generate_xbar_rd_channels(num_channels):
    lines = []

    for sig in axi_rd_signals:
        base = f"m_axi_{sig}"
        lines.append(f".s_axi_{sig:<8} ({_vec_concat(base, num_channels)}),")
    lines.append("")

    for sig in axi_rd_signals:
        base = f"ram_m_axi_{sig}"
        lines.append(f".m_axi_{sig:<8} ({_vec_concat(base, num_channels)}),")
    lines.append("")

    return "\n".join(lines)

if __name__ == "__main__":
    try:
        num_channels = 0
        while not 1 < num_channels < 5:
            num_channels = int(input("Enter the number of channels 2-4 to generate bindings for: "))

        content = generate_xbar_wr_channels(num_channels)
        with open(XBAR_WR_CHANNELS_PATH, "w") as f: f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{XBAR_WR_CHANNELS_PATH}")

        content = generate_xbar_rd_channels(num_channels)
        with open(XBAR_RD_CHANNELS_PATH, "w") as f: f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{XBAR_RD_CHANNELS_PATH}")

    except ValueError:
        print("Error: please enter a valid integer for NUM_CHANNELS.")
    except Exception as e:
        print(f"Unexpected error: {e}")
