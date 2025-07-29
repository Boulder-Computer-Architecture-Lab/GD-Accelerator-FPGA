`timescale 1ns / 1ps

module mvm_channel_split #(
    parameter DATA_WIDTH          = 64,
    parameter ADDR_WIDTH          = 32,
    parameter STRB_WIDTH          = DATA_WIDTH / 8,
    parameter ID_WIDTH            = 4,
    
    parameter WORDS_PER_TRANSFER  = 17048,
    parameter AXI_RAM_BASE_ADDR   = 32'h8000_0000,
    parameter NUM_RAM_PARTITIONS = 4,
    parameter NUM_CHANNELS = NUM_RAM_PARTITIONS,
    parameter TAG = 0
)(
    input  wire clk,
    input  wire rstn,
    
    input wire start,

    // Input stream A
    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire                  s_axis_a_tvalid,
    output wire                  s_axis_a_tready,
    
    // Output result stream
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast,
    
    // AXI master read interface (to interconnect)
    output wire [ID_WIDTH-1:0]   m_axi_arid,
    output wire [ADDR_WIDTH-1:0] m_axi_araddr,
    output wire [7:0]            m_axi_arlen,
    output wire [2:0]            m_axi_arsize,
    output wire [1:0]            m_axi_arburst,
    output wire                  m_axi_arlock,
    output wire [3:0]            m_axi_arcache,
    output wire [2:0]            m_axi_arprot,
    output wire                  m_axi_arvalid,
    input  wire                  m_axi_arready,
    input  wire [ID_WIDTH-1:0]   m_axi_rid,
    input  wire [DATA_WIDTH-1:0] m_axi_rdata,
    input  wire [1:0]            m_axi_rresp,
    input  wire                  m_axi_rlast,
    input  wire                  m_axi_rvalid,
    output wire                  m_axi_rready,
    
    // Partition arbitration
    input  wire [$clog2(NUM_RAM_PARTITIONS)-1:0] partition_index,
    input  wire grant_next_partition,
    output wire partition_done
);

    // ========================================
    //                FIFO A
    // ========================================
    
    wire fifo_a_s_axis_tready;
    assign s_axis_a_tready = fifo_a_s_axis_tready && start;

    wire [DATA_WIDTH-1:0] fifo_a_m_axis_tdata;
    wire                  fifo_a_m_axis_tvalid;
    wire                  fifo_a_m_axis_tready;
    
    axis_data_fifo_bram axis_data_fifo_in (
        .s_axis_aclk(clk),
        .s_axis_aresetn(rstn),
        
        .s_axis_tdata (s_axis_a_tdata),    
        .s_axis_tvalid(s_axis_a_tvalid),
        .s_axis_tready(fifo_a_s_axis_tready),

        .m_axis_tdata (fifo_a_m_axis_tdata),    
        .m_axis_tvalid(fifo_a_m_axis_tvalid),
        .m_axis_tready(fifo_a_m_axis_tready)
    );
    
    // ========================================
    //                FIFO B
    // ========================================
    
    wire [DATA_WIDTH-1:0] fifo_b_s_axis_tdata;
    wire                  fifo_b_s_axis_tvalid;
    wire                  fifo_b_s_axis_tready;
    
    wire [DATA_WIDTH-1:0] fifo_b_m_axis_tdata;
    wire                  fifo_b_m_axis_tvalid;
    wire                  fifo_b_m_axis_tready;
    
    axis_data_fifo_bram axis_data_fifo_b (
        .s_axis_aclk(clk),        
        .s_axis_aresetn(rstn),
        
        .s_axis_tdata (fifo_b_s_axis_tdata),
        .s_axis_tvalid(fifo_b_s_axis_tvalid),
        .s_axis_tready(fifo_b_s_axis_tready),
    
        .m_axis_tdata (fifo_b_m_axis_tdata),
        .m_axis_tvalid(fifo_b_m_axis_tvalid),
        .m_axis_tready(fifo_b_m_axis_tready)
    );
    
    // ========================================
    //  MM2S DMA FROM INTERCONNECT -> S_AXIS_B
    // ========================================

    localparam DMA_BURST_LEN = 256;
    localparam DMA_LEN_WIDTH = 20;
    localparam BYTES_PER_RAM_INST = (WORDS_PER_TRANSFER * STRB_WIDTH) / NUM_RAM_PARTITIONS;
    localparam [DMA_LEN_WIDTH-1:0] dma_desc_len = (WORDS_PER_TRANSFER * STRB_WIDTH) / NUM_RAM_PARTITIONS;
        
    wire [ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR + (partition_index * BYTES_PER_RAM_INST);

    reg  dma_desc_valid;
    wire dma_desc_ready;
    
    wire [7:0] dma_desc_tag  = TAG;
    wire [7:0] dma_desc_id   = 8'd0;
    wire [7:0] dma_desc_dest = 8'd0;
    wire       dma_desc_user = 1'b0;
        
    wire [7:0] dma_status_tag;
    wire [3:0] dma_status_error;
    wire       dma_status_valid;
    
    reg desc_sent;
    
    assign partition_done = dma_status_valid && (dma_status_tag == TAG);
        
    integer p;
    always @(posedge clk) begin
        if (!rstn) begin
            desc_sent <= 1'b0;
            dma_desc_valid <= 1'b0;
        end else if (start) begin 
            if (!desc_sent && grant_next_partition) begin
                dma_desc_valid <= 1'b1;
                if (dma_desc_ready) begin
                    desc_sent <= 1'b1;
                end
            end else if (dma_status_valid) begin
                desc_sent <= 1'b0;
            end else begin
                dma_desc_valid <= 1'b0;
            end
        end
    end
        
    axi_dma_rd #(
        .AXI_DATA_WIDTH(DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH),
        .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
        .AXIS_DATA_WIDTH(DATA_WIDTH),
        .AXIS_KEEP_ENABLE(1),
        .AXIS_LAST_ENABLE(0),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(DMA_LEN_WIDTH),
        .TAG_WIDTH(8),
        .ENABLE_SG(0),
        .ENABLE_UNALIGNED(1)
    ) dma (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_read_desc_addr(dma_desc_addr),
        .s_axis_read_desc_len(dma_desc_len),
        .s_axis_read_desc_tag(dma_desc_tag),
        .s_axis_read_desc_id(dma_desc_id),
        .s_axis_read_desc_dest(dma_desc_dest),
        .s_axis_read_desc_user(dma_desc_user),
        .s_axis_read_desc_valid(dma_desc_valid),
        .s_axis_read_desc_ready(dma_desc_ready),
    
        .m_axis_read_desc_status_tag(dma_status_tag),
        .m_axis_read_desc_status_error(dma_status_error),
        .m_axis_read_desc_status_valid(dma_status_valid),
    
        .m_axis_read_data_tdata(fifo_b_s_axis_tdata),
        .m_axis_read_data_tkeep(),
        .m_axis_read_data_tvalid(fifo_b_s_axis_tvalid),
        .m_axis_read_data_tready(fifo_b_s_axis_tready),
        .m_axis_read_data_tlast(),
        .m_axis_read_data_tid(),
        .m_axis_read_data_tdest(),
        .m_axis_read_data_tuser(),
    
        .m_axi_arid(m_axi_arid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_rid(m_axi_rid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
    
        .enable(1'b1)
    );
    
    // ========================================
    //          Dot product logic
    // ========================================

    dot_product #(
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) dp (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(fifo_a_m_axis_tdata),
        .s_axis_a_tvalid(fifo_a_m_axis_tvalid),
        .s_axis_a_tready(fifo_a_m_axis_tready),

        .s_axis_b_tdata(fifo_b_m_axis_tdata),
        .s_axis_b_tvalid(fifo_b_m_axis_tvalid),
        .s_axis_b_tready(fifo_b_m_axis_tready),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

endmodule