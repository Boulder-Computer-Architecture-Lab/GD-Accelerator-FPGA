.s_axis_a_3_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 3]),
.s_axis_a_3_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 3]),
.s_axis_a_3_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 3]),

.m_axis_3_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 3]),
.m_axis_3_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 3]),
.m_axis_3_tready(m_axis_tready[inst*CHANNELS_PER_INST + 3]),
.m_axis_3_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 3]),