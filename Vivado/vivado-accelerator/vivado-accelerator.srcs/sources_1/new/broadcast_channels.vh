    .m_axis_tdata  ({s_axis_b_tdata[7], s_axis_b_tdata[6], s_axis_b_tdata[5], s_axis_b_tdata[4], s_axis_b_tdata[3], s_axis_b_tdata[2], s_axis_b_tdata[1], s_axis_b_tdata[0]}),
    .m_axis_tvalid ({s_axis_b_tvalid[7], s_axis_b_tvalid[6], s_axis_b_tvalid[5], s_axis_b_tvalid[4], s_axis_b_tvalid[3], s_axis_b_tvalid[2], s_axis_b_tvalid[1], s_axis_b_tvalid[0]}),
    .m_axis_tready ({1'b1, 1'b1, 1'b1, 1'b1, s_axis_b_tready[3], s_axis_b_tready[2], s_axis_b_tready[1], s_axis_b_tready[0]})
