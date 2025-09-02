#!/usr/bin/env python3

import os

CWD = os.getcwd()
SOURCES_PATH = os.path.join(CWD, "../z2-accelerator/z2-accelerator.srcs/sources_1/new")
BIND_CHANNELS_PATH = os.path.join(SOURCES_PATH, "bind_channels.vh")
SPLIT_INTERCONNECT_CHANNELS_PATH = os.path.join(SOURCES_PATH, "split_interconnect_channels.vh")

def generate_bind_channels(num_channels):
    lines = []
    for i in range(num_channels):
        lines.append(f"""\
assign s_axis_a_tdata[{i}]  = s_axis_a_{i}_tdata;
assign s_axis_a_tvalid[{i}] = s_axis_a_{i}_tvalid;
assign s_axis_a_{i}_tready  = s_axis_a_tready[{i}];
assign s_axis_a_tlast[{i}]  = s_axis_a_{i}_tlast;

assign m_axis_{i}_tdata   = m_axis_tdata[{i}];
assign m_axis_{i}_tvalid  = m_axis_tvalid[{i}];
assign m_axis_tready[{i}] = m_axis_{i}_tready;
assign m_axis_{i}_tlast   = m_axis_tlast[{i}];

""")
    return ''.join(lines)

def generate_split_ic_channels(num_channels):
    s_axi_signals = [
        "arid", "araddr", "arlen", "arsize", "arburst", "arlock",
        "arcache", "arprot", "arvalid", "arready",
        "rid", "rdata", "rresp", "rlast", "rvalid", "rready"
    ]
    m_axi_signals = [
        "arid", "araddr", "arlen", "arsize", "arburst", "arlock",
        "arcache", "arprot", "arvalid", "arready",
        "rid", "rdata", "rresp", "rlast", "rvalid", "rready"
    ]
    lines = []
    for sig in s_axi_signals:
        ports = ", ".join([f"m_axi_{sig}[{i}]" for i in reversed(range(num_channels))])
        lines.append(f".s_axi_{sig:<8} ({{{ports}}}),")
    lines.append("")  # spacer
    for sig in m_axi_signals:
        ports = ", ".join([f"ram_m_axi_{sig}[{i}]" for i in reversed(range(num_channels))])
        lines.append(f".m_axi_{sig:<8} ({{{ports}}}),")
    return "\n".join(lines)

if __name__ == "__main__":
    try:
        num_channels = int(input("Enter the number of channels 1-8 to generate bindings for: "))

        content = generate_bind_channels(num_channels)
        with open(BIND_CHANNELS_PATH, "w") as f:
            f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{BIND_CHANNELS_PATH}")

        content = generate_split_ic_channels(num_channels)
        with open(SPLIT_INTERCONNECT_CHANNELS_PATH, "w") as f:
            f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{SPLIT_INTERCONNECT_CHANNELS_PATH}")

    except ValueError:
        print("Error: please enter a valid integer for NUM_CHANNELS.")
    except Exception as e:
        print(f"Unexpected error: {e}")
