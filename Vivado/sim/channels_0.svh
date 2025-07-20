.s_axis_a_0_tdata(s_axis_a_tdata[inst*CHANNELS_PER_INST]),
.s_axis_a_0_tvalid(s_axis_a_tvalid[inst*CHANNELS_PER_INST]),
.s_axis_a_0_tready(s_axis_a_tready[inst*CHANNELS_PER_INST]),

.m_axis_0_tdata(m_axis_tdata[inst*CHANNELS_PER_INST]),
.m_axis_0_tvalid(m_axis_tvalid[inst*CHANNELS_PER_INST]),
.m_axis_0_tready(m_axis_tready[inst*CHANNELS_PER_INST]),
.m_axis_0_tlast(m_axis_tlast[inst*CHANNELS_PER_INST]),
