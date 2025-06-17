
`timescale 1 ns / 1 ps

	module bram_stream_writer_v1_0_S00_AXIS #
	(
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
        output wire [31:0] bram_addr,
        output wire [31:0] bram_din,
        output wire        bram_en,
        output wire [3:0]  bram_we,
        output wire        bram_rst,
        output wire        WRITE_DONE,

		input wire  S_AXIS_ACLK,
		input wire  S_AXIS_ARESETN,
		output wire  S_AXIS_TREADY,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		input wire  S_AXIS_TLAST,
		input wire  S_AXIS_TVALID,
		
		output wire [2:0] write_pointer_debug
	);

	localparam NUMBER_OF_INPUT_WORDS  = 8;
	localparam ADDR_WIDTH  = 3; // clogb2(NUMBER_OF_INPUT_WORDS-1)
	
	// states
	localparam [1:0] IDLE  = 1'b0;
	localparam [1:0] WRITE = 1'b1;
	
	wire axis_tready;
	reg mst_exec_state;     
	wire fifo_wren;
	reg [ADDR_WIDTH-1:0] write_pointer;
	reg writes_done;
	  
    assign bram_addr = {29'b0, write_pointer};
    assign bram_din  = S_AXIS_TDATA;
    assign bram_en   = fifo_wren;
    assign bram_we   = fifo_wren ? 4'b1111 : 4'b0000;
    assign bram_rst  = 1'b0;
    assign WRITE_DONE = writes_done;
	
	assign S_AXIS_TREADY	= axis_tready;
	assign axis_tready = ((mst_exec_state == WRITE) && (write_pointer < NUMBER_OF_INPUT_WORDS));
    assign fifo_wren = S_AXIS_TVALID && axis_tready;
    
    assign write_pointer_debug = write_pointer;
	
	always @(posedge S_AXIS_ACLK) 
	begin
	  if (!S_AXIS_ARESETN) begin
	    mst_exec_state <= IDLE;
	  end else
	    case (mst_exec_state)
	      IDLE: 
	          if (S_AXIS_TVALID) begin
	            mst_exec_state <= WRITE;
	          end else begin
	            mst_exec_state <= IDLE;
	          end
	      WRITE:
	        if (writes_done) begin
	          mst_exec_state <= IDLE;
	        end else begin
	          mst_exec_state <= WRITE;
	        end
	    endcase
	end

	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN) begin
	    write_pointer <= 0;
	    writes_done <= 1'b0;
	  end else if (!writes_done && fifo_wren) begin
	    write_pointer <= write_pointer + 1;
	    if (write_pointer == NUMBER_OF_INPUT_WORDS-1) begin
	      writes_done <= 1'b1;
	    end else if (write_pointer == NUMBER_OF_INPUT_WORDS) begin
	      write_pointer <= 0;
	    end
	  end
	end

	endmodule
