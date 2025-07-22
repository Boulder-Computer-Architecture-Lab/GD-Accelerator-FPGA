#!/usr/bin/env python3

import os

CWD = os.getcwd()
SOURCES_PATH = os.path.join(CWD, "../vivado-accelerator/vivado-accelerator.srcs/sources_1/new")
BIND_CHANNELS_PATH = os.path.join(SOURCES_PATH, "bind_channels.vh")
INTERCONNECT_CHANNELS_PATH = os.path.join(SOURCES_PATH, "interconnect_channels.vh")
BROADCAST_CHANNELS_PATH = os.path.join(SOURCES_PATH, "broadcast_channels.vh")

def generate_bind_channels(num_channels):
    lines = []
    for i in range(num_channels):
        lines.append(f"""\
assign s_axis_a_tdata[{i}]  = s_axis_a_{i}_tdata;
assign s_axis_a_tvalid[{i}] = s_axis_a_{i}_tvalid;
assign s_axis_a_{i}_tready  = s_axis_a_tready[{i}];

assign m_axis_{i}_tdata   = m_axis_tdata[{i}];
assign m_axis_{i}_tvalid  = m_axis_tvalid[{i}];
assign m_axis_tready[{i}] = m_axis_{i}_tready;
assign m_axis_{i}_tlast   = m_axis_tlast[{i}];

""")
    return ''.join(lines)

def generate_ic_channels(num_channels):
    lines = []
    for i in range(num_channels):
        lines.append(f"""\
        .S0{i}_AXI_ACLK(clk), .S0{i}_AXI_ARESET_OUT_N(),
        .S0{i}_AXI_ARID     (m_axi_arid[{i}]),
        .S0{i}_AXI_ARADDR   (m_axi_araddr[{i}]),
        .S0{i}_AXI_ARLEN    (m_axi_arlen[{i}]),
        .S0{i}_AXI_ARSIZE   (m_axi_arsize[{i}]),
        .S0{i}_AXI_ARBURST  (m_axi_arburst[{i}]),
        .S0{i}_AXI_ARLOCK   (m_axi_arlock[{i}]),
        .S0{i}_AXI_ARCACHE  (m_axi_arcache[{i}]),
        .S0{i}_AXI_ARPROT   (m_axi_arprot[{i}]),
        .S0{i}_AXI_ARQOS    (ARQOS),
        .S0{i}_AXI_ARVALID  (m_axi_arvalid[{i}]),
        .S0{i}_AXI_ARREADY  (m_axi_arready[{i}]),
        .S0{i}_AXI_RID      (m_axi_rid[{i}]),
        .S0{i}_AXI_RDATA    (m_axi_rdata[{i}]),
        .S0{i}_AXI_RRESP    (m_axi_rresp[{i}]),
        .S0{i}_AXI_RLAST    (m_axi_rlast[{i}]),
        .S0{i}_AXI_RVALID   (m_axi_rvalid[{i}]),
        .S0{i}_AXI_RREADY   (m_axi_rready[{i}]),

""")
    return ''.join(lines)

def generate_bcast_channels(num_channels):
    lines = []

    lines.append("    .m_axis_tdata  ({")
    lines.append(", ".join([f"s_axis_b_tdata[{i}]" for i in reversed(range(8))]))
    lines.append("}),\n")

    lines.append("    .m_axis_tvalid ({")
    lines.append(", ".join([f"s_axis_b_tvalid[{i}]" for i in reversed(range(8))]))
    lines.append("}),\n")

    lines.append("    .m_axis_tready ({")
    lines.append(", ".join([
        f"s_axis_b_tready[{i}]" if i < num_channels else "1'b1"
        for i in reversed(range(8))
    ]))
    lines.append("})\n")

    return ''.join(lines)

if __name__ == "__main__":
    try:
        num_channels = int(input("Enter the number of channels 1-8 to generate bindings for: "))

        content = generate_bind_channels(num_channels)
        with open(BIND_CHANNELS_PATH, "w") as f:
            f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{BIND_CHANNELS_PATH}")

        content = generate_ic_channels(num_channels)
        with open(INTERCONNECT_CHANNELS_PATH, "w") as f:
            f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{INTERCONNECT_CHANNELS_PATH}")

        content = generate_bcast_channels(num_channels)
        with open(BROADCAST_CHANNELS_PATH, "w") as f:
            f.write(content)
        print(f"Generated bindings for {num_channels} channels at:\n{BROADCAST_CHANNELS_PATH}")

    except ValueError:
        print("Error: please enter a valid integer for NUM_CHANNELS.")
    except Exception as e:
        print(f"Unexpected error: {e}")
