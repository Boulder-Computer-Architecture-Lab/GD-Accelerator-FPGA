.s_axis_a_4_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 4]),
.s_axis_a_4_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 4]),
.s_axis_a_4_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 4]),

.m_axis_4_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 4]),
.m_axis_4_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 4]),
.m_axis_4_tready(m_axis_tready[inst*CHANNELS_PER_INST + 4]),
.m_axis_4_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 4]),