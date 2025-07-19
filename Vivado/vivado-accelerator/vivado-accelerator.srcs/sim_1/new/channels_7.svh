.s_axis_a_7_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 7]),
.s_axis_a_7_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 7]),
.s_axis_a_7_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 7]),

.m_axis_7_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 7]),
.m_axis_7_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 7]),
.m_axis_7_tready(m_axis_tready[inst*CHANNELS_PER_INST + 7]),
.m_axis_7_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 7]),