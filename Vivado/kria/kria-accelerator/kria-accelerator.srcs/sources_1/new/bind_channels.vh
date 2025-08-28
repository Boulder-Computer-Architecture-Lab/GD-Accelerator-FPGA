assign s_axis_a_tdata[0]  = s_axis_a_0_tdata;
assign s_axis_a_tvalid[0] = s_axis_a_0_tvalid;
assign s_axis_a_0_tready  = s_axis_a_tready[0];
assign s_axis_a_tlast[0]  = s_axis_a_0_tlast;

assign m_axis_0_tdata   = m_axis_tdata[0];
assign m_axis_0_tvalid  = m_axis_tvalid[0];
assign m_axis_tready[0] = m_axis_0_tready;
assign m_axis_0_tlast   = m_axis_tlast[0];

