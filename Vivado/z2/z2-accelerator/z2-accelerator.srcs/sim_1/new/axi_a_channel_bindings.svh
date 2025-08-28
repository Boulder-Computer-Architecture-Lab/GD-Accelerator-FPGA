`define CHANNEL_0 \
    .s_axis_a_0_tdata(s_axis_a_tdata[base_idx + 0]), \
    .s_axis_a_0_tvalid(s_axis_a_tvalid[base_idx + 0]), \
    .s_axis_a_0_tready(s_axis_a_tready[base_idx + 0]), \
    .s_axis_a_0_tlast(s_axis_a_tlast[base_idx + 0]), \
    .m_axis_0_tdata(m_axis_tdata[base_idx + 0]), \
    .m_axis_0_tvalid(m_axis_tvalid[base_idx + 0]), \
    .m_axis_0_tready(m_axis_tready[base_idx + 0]), \
    .m_axis_0_tlast(m_axis_tlast[base_idx + 0]),

`define CHANNEL_1 \
    .s_axis_a_1_tdata(s_axis_a_tdata[base_idx + 1]), \
    .s_axis_a_1_tvalid(s_axis_a_tvalid[base_idx + 1]), \
    .s_axis_a_1_tready(s_axis_a_tready[base_idx + 1]), \
    .s_axis_a_1_tlast(s_axis_a_tlast[base_idx + 1]), \
    .m_axis_1_tdata(m_axis_tdata[base_idx + 1]), \
    .m_axis_1_tvalid(m_axis_tvalid[base_idx + 1]), \
    .m_axis_1_tready(m_axis_tready[base_idx + 1]), \
    .m_axis_1_tlast(m_axis_tlast[base_idx + 1]),

`define CHANNEL_2 \
    .s_axis_a_2_tdata(s_axis_a_tdata[base_idx + 2]), \
    .s_axis_a_2_tvalid(s_axis_a_tvalid[base_idx + 2]), \
    .s_axis_a_2_tready(s_axis_a_tready[base_idx + 2]), \
    .s_axis_a_2_tlast(s_axis_a_tlast[base_idx + 2]), \
    .m_axis_2_tdata(m_axis_tdata[base_idx + 2]), \
    .m_axis_2_tvalid(m_axis_tvalid[base_idx + 2]), \
    .m_axis_2_tready(m_axis_tready[base_idx + 2]), \
    .m_axis_2_tlast(m_axis_tlast[base_idx + 2]),

`define CHANNEL_3 \
    .s_axis_a_3_tdata(s_axis_a_tdata[base_idx + 3]), \
    .s_axis_a_3_tvalid(s_axis_a_tvalid[base_idx + 3]), \
    .s_axis_a_3_tready(s_axis_a_tready[base_idx + 3]), \
    .s_axis_a_3_tlast(s_axis_a_tlast[base_idx + 3]), \
    .m_axis_3_tdata(m_axis_tdata[base_idx + 3]), \
    .m_axis_3_tvalid(m_axis_tvalid[base_idx + 3]), \
    .m_axis_3_tready(m_axis_tready[base_idx + 3]), \
    .m_axis_3_tlast(m_axis_tlast[base_idx + 3]),

`define CHANNEL_4 \
    .s_axis_a_4_tdata(s_axis_a_tdata[base_idx + 4]), \
    .s_axis_a_4_tvalid(s_axis_a_tvalid[base_idx + 4]), \
    .s_axis_a_4_tready(s_axis_a_tready[base_idx + 4]), \
    .s_axis_a_4_tlast(s_axis_a_tlast[base_idx + 4]), \
    .m_axis_4_tdata(m_axis_tdata[base_idx + 4]), \
    .m_axis_4_tvalid(m_axis_tvalid[base_idx + 4]), \
    .m_axis_4_tready(m_axis_tready[base_idx + 4]), \
    .m_axis_4_tlast(m_axis_tlast[base_idx + 4]),

`define CHANNEL_5 \
    .s_axis_a_5_tdata(s_axis_a_tdata[base_idx + 5]), \
    .s_axis_a_5_tvalid(s_axis_a_tvalid[base_idx + 5]), \
    .s_axis_a_5_tready(s_axis_a_tready[base_idx + 5]), \
    .s_axis_a_5_tlast(s_axis_a_tlast[base_idx + 5]), \
    .m_axis_5_tdata(m_axis_tdata[base_idx + 5]), \
    .m_axis_5_tvalid(m_axis_tvalid[base_idx + 5]), \
    .m_axis_5_tready(m_axis_tready[base_idx + 5]), \
    .m_axis_5_tlast(m_axis_tlast[base_idx + 5]),

`define CHANNEL_6 \
    .s_axis_a_6_tdata(s_axis_a_tdata[base_idx + 6]), \
    .s_axis_a_6_tvalid(s_axis_a_tvalid[base_idx + 6]), \
    .s_axis_a_6_tready(s_axis_a_tready[base_idx + 6]), \
    .s_axis_a_6_tlast(s_axis_a_tlast[base_idx + 6]), \
    .m_axis_6_tdata(m_axis_tdata[base_idx + 6]), \
    .m_axis_6_tvalid(m_axis_tvalid[base_idx + 6]), \
    .m_axis_6_tready(m_axis_tready[base_idx + 6]), \
    .m_axis_6_tlast(m_axis_tlast[base_idx + 6]),

`define CHANNEL_7 \
    .s_axis_a_7_tdata(s_axis_a_tdata[base_idx + 7]), \
    .s_axis_a_7_tvalid(s_axis_a_tvalid[base_idx + 7]), \
    .s_axis_a_7_tready(s_axis_a_tready[base_idx + 7]), \
    .s_axis_a_7_tlast(s_axis_a_tlast[base_idx + 7]), \
    .m_axis_7_tdata(m_axis_tdata[base_idx + 7]), \
    .m_axis_7_tvalid(m_axis_tvalid[base_idx + 7]), \
    .m_axis_7_tready(m_axis_tready[base_idx + 7]), \
    .m_axis_7_tlast(m_axis_tlast[base_idx + 7]),

`define CHANNELS_1 `CHANNEL_0
`define CHANNELS_2 `CHANNEL_0 `CHANNEL_1
`define CHANNELS_3 `CHANNEL_0 `CHANNEL_1 `CHANNEL_2
`define CHANNELS_4 `CHANNEL_0 `CHANNEL_1 `CHANNEL_2 `CHANNEL_3
`define CHANNELS_5 `CHANNEL_0 `CHANNEL_1 `CHANNEL_2 `CHANNEL_3 `CHANNEL_4
`define CHANNELS_6 `CHANNEL_0 `CHANNEL_1 `CHANNEL_2 `CHANNEL_3 `CHANNEL_4 `CHANNEL_5
`define CHANNELS_7 `CHANNEL_0 `CHANNEL_1 `CHANNEL_2 `CHANNEL_3 `CHANNEL_4 `CHANNEL_5 `CHANNEL_6
`define CHANNELS_8 `CHANNEL_0 `CHANNEL_1 `CHANNEL_2 `CHANNEL_3 `CHANNEL_4 `CHANNEL_5 `CHANNEL_6 `CHANNEL_7