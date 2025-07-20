.s_axis_a_1_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 1]),
.s_axis_a_1_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 1]),
.s_axis_a_1_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 1]),

.m_axis_1_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 1]),
.m_axis_1_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 1]),
.m_axis_1_tready(m_axis_tready[inst*CHANNELS_PER_INST + 1]),
.m_axis_1_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 1]),