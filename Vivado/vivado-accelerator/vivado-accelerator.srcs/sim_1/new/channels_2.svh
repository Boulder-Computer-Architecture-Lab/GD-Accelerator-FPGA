.s_axis_a_2_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST + 2]),
.s_axis_a_2_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST + 2]),
.s_axis_a_2_tready(s_axis_a_tready[inst*CHANNELS_PER_INST + 2]),

.m_axis_2_tdata(m_axis_tdata[inst*CHANNELS_PER_INST + 2]),
.m_axis_2_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST + 2]),
.m_axis_2_tready(m_axis_tready[inst*CHANNELS_PER_INST + 2]),
.m_axis_2_tlast(m_axis_tlast[inst*CHANNELS_PER_INST + 2]),