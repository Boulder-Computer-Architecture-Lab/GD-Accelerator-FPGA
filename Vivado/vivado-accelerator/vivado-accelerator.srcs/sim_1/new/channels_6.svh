.s_axis_a_6_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 6]),
.s_axis_a_6_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 6]),
.s_axis_a_6_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 6]),

.m_axis_6_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 6]),
.m_axis_6_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 6]),
.m_axis_6_tready(m_axis_tready[inst*CHANNELS_PER_INST + 6]),
.m_axis_6_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 6]),