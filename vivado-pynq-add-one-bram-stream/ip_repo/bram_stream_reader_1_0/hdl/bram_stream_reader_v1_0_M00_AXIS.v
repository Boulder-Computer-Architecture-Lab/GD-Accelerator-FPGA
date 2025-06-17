
`timescale 1 ns / 1 ps

	module bram_stream_reader_v1_0_M00_AXIS #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32
	)
	(
        output wire [31:0] bram_addr, 
        input  wire [31:0] bram_dout,
        output wire        bram_en,
        output wire        bram_rst,
        output wire [3:0]  bram_we,
        input  wire        write_done, // comes directly from writer module

		input  wire M_AXIS_ACLK,
		input  wire M_AXIS_ARESETN,
		output wire M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire M_AXIS_TLAST,
		input  wire M_AXIS_TREADY,
		
		output wire [2:0] read_pointer_debug
	);

    localparam NUMBER_OF_OUTPUT_WORDS = 8;
    localparam ADDR_WIDTH = 3;

	// states
	localparam [1:0] IDLE        = 2'b00;
	localparam [1:0] READ_WAIT   = 2'b01;
	localparam [1:0] SEND_STREAM = 2'b10;

	reg [1:0] mst_exec_state;
	reg [2:0] read_pointer; // [ADDR_WIDTH-1:0]
	wire  	  axis_tvalid;
	wire  	  axis_tlast;
	wire  	  ren; // read enable

	reg [C_M_AXIS_TDATA_WIDTH-1 : 0] stream_data_out;

    assign bram_addr = {29'b0, read_pointer};
    assign bram_en = (mst_exec_state == READ_WAIT);
    assign bram_rst = 1'b0;
    assign bram_we = 4'b0000; // read only

	assign M_AXIS_TDATA	= stream_data_out;
	assign M_AXIS_TVALID = axis_tvalid;
    assign M_AXIS_TLAST  = axis_tlast;
    assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};
	
	assign axis_tvalid = ((mst_exec_state != IDLE) && (read_pointer < NUMBER_OF_OUTPUT_WORDS));               
	assign axis_tlast = (read_pointer == NUMBER_OF_OUTPUT_WORDS - 1);
	assign ren = M_AXIS_TREADY && axis_tvalid;
	
	assign read_pointer_debug = read_pointer;

    // FSM
	always @(posedge M_AXIS_ACLK) begin
	  if (!M_AXIS_ARESETN)
	    mst_exec_state <= IDLE;
	  else
	    case (mst_exec_state)
	      IDLE:
	        if (write_done)
	          mst_exec_state  <= SEND_STREAM;
	        else
	          mst_exec_state  <= IDLE;

	      READ_WAIT:
	        mst_exec_state  <= SEND_STREAM; // delay 1 clk

	      SEND_STREAM:
	        if (ren && axis_tlast)
	          mst_exec_state <= IDLE;
	        else if (ren)
	          mst_exec_state <= READ_WAIT;
	        else
	          mst_exec_state <= SEND_STREAM; 
	    endcase
	end

    // Update pointer
	always@(posedge M_AXIS_ACLK) begin
	  if(!M_AXIS_ARESETN || (mst_exec_state == IDLE && write_done)) begin
	    read_pointer <= 0;
	  end else if (ren) begin
	    if (read_pointer < NUMBER_OF_OUTPUT_WORDS) begin
	      read_pointer <= read_pointer + 1;
	    end
	  end
	end

    // Capture output
    always @( posedge M_AXIS_ACLK ) begin
      if(!M_AXIS_ARESETN) begin
          stream_data_out <= 32'b0;
      end else if (bram_en) begin
          stream_data_out <= bram_dout;
      end 
    end
      
	endmodule
