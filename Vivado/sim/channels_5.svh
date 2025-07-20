.s_axis_a_5_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 5]),
.s_axis_a_5_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 5]),
.s_axis_a_5_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 5]),

.m_axis_5_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 5]),
.m_axis_5_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 5]),
.m_axis_5_tready(m_axis_tready[inst*CHANNELS_PER_INST + 5]),
.m_axis_5_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 5]),