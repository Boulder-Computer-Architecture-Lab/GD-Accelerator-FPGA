`timescale 1 ns / 1 ps

	module add_one_stream_v1_0_S00_AXIS #
	(
		// Do not modify the parameters beyond this line
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32 // AXI4Stream: Data Width
	)
	(
		// Do not modify the ports beyond this line
        
		// AXI4Stream sink: Slave output interface
		input  wire S_AXIS_ACLK,    // AXI4Stream sink: Clock
		input  wire S_AXIS_ARESETN, // AXI4Stream sink: Reset
		output wire S_AXIS_TREADY,  // Ready to accept data in
		input  wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,     // Data in
		input  wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB, // Byte qualifier
		input  wire S_AXIS_TLAST,  // Indicates boundary of last packet
		input  wire S_AXIS_TVALID, // Data is in valid
		
		// AXI4Stream source: Master output interface
        input  wire M_AXIS_TREADY,
        output wire [C_S_AXIS_TDATA_WIDTH-1:0] M_AXIS_TDATA,
        output wire [(C_S_AXIS_TDATA_WIDTH/8)-1:0] M_AXIS_TSTRB,
        output wire M_AXIS_TLAST,
        output wire M_AXIS_TVALID
	);

	// Ceiling of the log base 2
	function integer clogb2 (input integer bit_depth);
	  begin
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
	      bit_depth = bit_depth >> 1;
	  end
	endfunction

    // Local parameters
	localparam NUMBER_OF_INPUT_WORDS  = 8; // Total number of input data
	localparam bit_num  = clogb2(NUMBER_OF_INPUT_WORDS-1); // min bits needed to address NUMBER_OF_INPUT_WORDS
	// Define the states for FSM
	localparam [1:0] IDLE       = 2'd0;
	localparam [1:0] WRITE_FIFO = 2'd1;
	localparam [1:0] READ_FIFO  = 2'd2;
	                
	reg [1:0] state;  // State variable   
	wire axis_tready; // Ready to receive
	wire fifo_wren;   // FIFO write enable
	reg fifo_data_valid;
	
	reg [bit_num-1:0] write_pointer; // FIFO write pointer
    reg [bit_num-1:0] read_pointer;  // FIFO read pointer
    
	reg writes_done; // Sink has accepted all the streaming data and stored in FIFO
	reg reads_done;  // Source has sent all streaming data
	
	// Buffers
    reg [C_S_AXIS_TDATA_WIDTH-1:0] stream_data_fifo [0 : NUMBER_OF_INPUT_WORDS-1];
	reg [C_S_AXIS_TDATA_WIDTH-1:0] m_axis_tdata_reg;

    // Assignments
    assign M_AXIS_TDATA  = m_axis_tdata_reg;
    assign M_AXIS_TVALID = fifo_data_valid; // Only assert valid when data is staged
    assign M_AXIS_TSTRB  = {(C_S_AXIS_TDATA_WIDTH/8){1'b1}};
    assign M_AXIS_TLAST  = (read_pointer == NUMBER_OF_INPUT_WORDS - 1);
    
	assign S_AXIS_TREADY = axis_tready;
	
	assign axis_tready = ((state == WRITE_FIFO) && (write_pointer < NUMBER_OF_INPUT_WORDS));
	assign fifo_wren = S_AXIS_TVALID && axis_tready;

	// Control state machine implementation
	always @(posedge S_AXIS_ACLK) begin  
	  if (!S_AXIS_ARESETN) // Synchronous reset (active low)
	    state <= IDLE;
	  else
	    case (state)
	      IDLE: 
	          if (S_AXIS_TVALID) begin
	            state <= WRITE_FIFO;
	          end else
	            state <= IDLE;
	      WRITE_FIFO: 
	        if (writes_done)
	          state <= READ_FIFO;
	        else
	          state <= WRITE_FIFO;
	      READ_FIFO:
	        if (reads_done)
              state <= IDLE;
	        else
	          state <= READ_FIFO;
	      default:
	          state <= IDLE;
	    endcase
	end

	// AXI Streaming Sink: Write logic
	always@(posedge S_AXIS_ACLK) begin
	  if (!S_AXIS_ARESETN) begin
	    write_pointer <= 0;
	    writes_done   <= 1'b0;
	  end else if (state == WRITE_FIFO) begin
	    if (fifo_wren) begin
	      stream_data_fifo[write_pointer] <= S_AXIS_TDATA;
	      
	      if ((write_pointer == NUMBER_OF_INPUT_WORDS - 1) || S_AXIS_TLAST)
            writes_done <= 1'b1;
          else
            write_pointer <= write_pointer + 1;
        end
      end else begin
        writes_done <= 1'b0; // Clear writes_done if not actively writing
      end
	end
	
	// AXI Streaming Source: Read logic
	always @(posedge S_AXIS_ACLK) begin
	  if (!S_AXIS_ARESETN) begin
	    read_pointer <= 0;
	    reads_done   <= 1'b0;
        m_axis_tdata_reg <= 0;
        fifo_data_valid <= 1'b0;
      end else if (state == READ_FIFO) begin
        if (!reads_done) begin
          if (!fifo_data_valid) begin
            m_axis_tdata_reg <= stream_data_fifo[read_pointer] + 1; // Calculate output (increment)
            fifo_data_valid <= 1'b1;
          end else if (M_AXIS_TREADY) begin
            if (read_pointer == NUMBER_OF_INPUT_WORDS - 1) begin
              reads_done <= 1'b1;
              fifo_data_valid <= 1'b0;
            end else begin
              read_pointer <= read_pointer + 1;
              m_axis_tdata_reg <= stream_data_fifo[read_pointer + 1] + 1;
            end
          end
        end
      end else begin
        reads_done <= 1'b0;
        fifo_data_valid <= 1'b0;
      end
	end

	endmodule
