
`timescale 1 ns / 1 ps

	module bram_stream_writer_v1_0_S00_AXIS #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// AXI4Stream sink: Data Width
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
        output wire [31:0] bram_addr,
        output wire [31:0] bram_din,
        output wire        bram_en,
        output wire [3:0]  bram_we,
        output wire        bram_rst,
		// User ports ends
		// Do not modify the ports beyond this line

		// AXI4Stream sink: Clock
		input wire  S_AXIS_ACLK,
		// AXI4Stream sink: Reset
		input wire  S_AXIS_ARESETN,
		// Ready to accept data in
		output wire  S_AXIS_TREADY,
		// Data in
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		// Byte qualifier
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		// Indicates boundary of last packet
		input wire  S_AXIS_TLAST,
		// Data is in valid
		input wire  S_AXIS_TVALID
	);

	// Total number of input data.
	localparam NUMBER_OF_INPUT_WORDS  = 8;
	// ADDR_WIDTH gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size.
	localparam ADDR_WIDTH  = 3; // clogb2(NUMBER_OF_INPUT_WORDS-1)
	// Define the states of state machine
	// The control state machine oversees the writing of input streaming data to the FIFO,
	// and outputs the streaming data from the FIFO
	localparam [1:0] IDLE  = 1'b0; // This is the initial/idle state 
	localparam [1:0] WRITE = 1'b1; // In this state BRAM is written with the
	                               // input stream data S_AXIS_TDATA 
	wire axis_tready;
	// State variable
	reg mst_exec_state;     
	// FIFO write enable
	wire fifo_wren;
	// Write pointer
	reg [ADDR_WIDTH-1:0] write_pointer;
	// sink has accepted all the streaming data and written to BRAM
	reg writes_done;
	  
	// Begin User Assignments
    assign bram_addr = {29'b0, write_pointer};
    assign bram_din  = S_AXIS_TDATA;
    assign bram_en   = fifo_wren;
    assign bram_we   = fifo_wren ? 4'b1111 : 4'b0000;
    assign bram_rst  = 1'b0;
	// End User Assignments
	
	// I/O Connections assignments

	assign S_AXIS_TREADY	= axis_tready;
	// Control state machine implementation
	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	  // Synchronous reset (active low)
	    begin
	      mst_exec_state <= IDLE;
	    end  
	  else
	    case (mst_exec_state)
	      IDLE: 
	        // The sink starts accepting tdata when 
	        // there tvalid is asserted to mark the
	        // presence of valid streaming data 
	          if (S_AXIS_TVALID)
	            begin
	              mst_exec_state <= WRITE;
	            end
	          else
	            begin
	              mst_exec_state <= IDLE;
	            end
	      WRITE: 
	        if (writes_done)
	          begin
	            mst_exec_state <= IDLE;
	          end
	        else
	          begin
	            // The sink accepts and stores tdata in BRAM
	            mst_exec_state <= WRITE;
	          end

	    endcase
	end
	
	// AXI Streaming Sink 
	assign axis_tready = ((mst_exec_state == WRITE) && (write_pointer < NUMBER_OF_INPUT_WORDS));
    assign fifo_wren = S_AXIS_TVALID && axis_tready;

	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	    begin
	      write_pointer <= 0;
	      writes_done <= 1'b0;
	    end  
	  else if (!writes_done && fifo_wren)
	    begin
	    	write_pointer <= write_pointer + 1;
	        if (write_pointer == NUMBER_OF_INPUT_WORDS-1)
	          begin
	            writes_done <= 1'b1;
	          end
	    end
	  else if (writes_done)
	    begin
	      write_pointer <= 0;
	    end
	end

	// Add user logic here

	// User logic ends

	endmodule
