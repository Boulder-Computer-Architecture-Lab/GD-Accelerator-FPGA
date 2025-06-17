
`timescale 1 ns / 1 ps

	module bram_stream_reader_v1_0 #
	(
		// Users to add parameters here
        //parameter NUMBER_OF_OUTPUT_WORDS = 8,
        //parameter ADDR_WIDTH = 3,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH = 32
	)
	(
		// Users to add ports here
		output wire [31:0] bram_addr,
        input  wire [31:0] bram_dout,
        output wire        bram_en,
        output wire        bram_rst,
        output wire [3:0]  bram_we,
        input  wire        write_done,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXIS
		input  wire  m00_axis_aclk,
		input  wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input  wire  m00_axis_tready,
		
		output wire [2:0] read_pointer_debug
	); 
	
    // Instantiation of Axi Bus Interface M00_AXIS
	bram_stream_reader_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
		
	) bram_stream_reader_v1_0_M00_AXIS_inst (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready),
		
		.bram_addr(bram_addr),
        .bram_dout(bram_dout),
        .bram_en(bram_en),
        .bram_rst(bram_rst),
        .bram_we(bram_we),
        .write_done(write_done),
        .read_pointer_debug(read_pointer_debug)
	);

	// Add user logic here

	// User logic ends

	endmodule
