assign s_axis_a_tdata[0]  = s_axis_a_0_tdata;
assign s_axis_a_tvalid[0] = s_axis_a_0_tvalid;
assign s_axis_a_0_tready  = s_axis_a_tready[0];
assign s_axis_a_tlast[0]  = s_axis_a_0_tlast;

assign m_axis_0_tdata   = m_axis_tdata[0];
assign m_axis_0_tvalid  = m_axis_tvalid[0];
assign m_axis_tready[0] = m_axis_0_tready;
assign m_axis_0_tlast   = m_axis_tlast[0];

assign s_axis_a_tdata[1]  = s_axis_a_1_tdata;
assign s_axis_a_tvalid[1] = s_axis_a_1_tvalid;
assign s_axis_a_1_tready  = s_axis_a_tready[1];
assign s_axis_a_tlast[1]  = s_axis_a_1_tlast;

assign m_axis_1_tdata   = m_axis_tdata[1];
assign m_axis_1_tvalid  = m_axis_tvalid[1];
assign m_axis_tready[1] = m_axis_1_tready;
assign m_axis_1_tlast   = m_axis_tlast[1];

