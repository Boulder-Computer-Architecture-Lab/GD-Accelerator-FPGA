`timescale 1ns / 1ps

module mvm_channel #(
    parameter DATA_WIDTH         = 64,
    parameter ADDR_WIDTH         = 32,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 4,
    parameter WORDS_PER_TRANSFER = 17048,
    parameter TAG                = 0,
    parameter BASE_ADDR          = 32'h80000000,
    parameter LEN_WIDTH          = 20
)(
    input  wire clk,
    input  wire rstn,

    // Input stream A
    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire                  s_axis_a_tvalid,
    output wire                  s_axis_a_tready,

    // Output result stream
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast,

    // AXI master read interface (connect to interconnect)
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
    output wire                  m_axi_rready
);
    // ========================================
    //  FIFO A (absorbs burst inputs on axis_a)
    // ========================================

    wire [DATA_WIDTH-1:0] fifo_a_tdata;
    wire                  fifo_a_tvalid;
    wire                  fifo_a_tready;
    
    axis_data_fifo_bram axis_data_fifo_in (
        .s_axis_aresetn(rstn),
        .s_axis_aclk(clk),
    
        .s_axis_tvalid(s_axis_a_tvalid),
        .s_axis_tready(s_axis_a_tready),
        .s_axis_tdata (s_axis_a_tdata),
    
        .m_axis_tvalid(fifo_a_tvalid),
        .m_axis_tready(fifo_a_tready),
        .m_axis_tdata (fifo_a_tdata)
    );
    
    // ========================================
    //          DMA (BRAM -> axis_b)
    // ========================================
    
    localparam [19:0] DESC_LEN = WORDS_PER_TRANSFER * STRB_WIDTH;
    
    // Descriptor logic
    reg dma_triggered = 0;
    reg dma_desc_valid = 0;

    wire [DATA_WIDTH-1:0] dma_axis_tdata;
    wire                  dma_axis_tvalid;
    wire                  dma_axis_tready;

    wire [7:0] dma_status_tag;
    wire [3:0] dma_status_error;
    wire       dma_status_valid;
    wire       dma_desc_ready;
        
    always @(posedge clk) begin
        if (!rstn) begin
            dma_desc_valid <= 1'b0;
            dma_triggered <= 1'b0;
        end else begin
            if (!dma_triggered && fifo_a_tvalid && fifo_a_tready) begin
                dma_desc_valid <= 1'b1;
                dma_triggered <= 1'b1;
            end else if (dma_desc_valid && dma_desc_ready) begin
                dma_desc_valid <= 1'b0;
            end
            
            if (dma_triggered && m_axis_tvalid && m_axis_tready && m_axis_tlast) begin
                dma_triggered <= 1'b0;
            end
        end
    end

    axi_dma_rd #(
        .AXI_DATA_WIDTH(DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH),
        .AXI_MAX_BURST_LEN(256),
        .AXIS_DATA_WIDTH(DATA_WIDTH),
        .AXIS_KEEP_ENABLE(1),
        .AXIS_LAST_ENABLE(0),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(LEN_WIDTH),
        .TAG_WIDTH(8),
        .ENABLE_SG(0),
        .ENABLE_UNALIGNED(1)
    ) dma (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_read_desc_addr(BASE_ADDR),
        .s_axis_read_desc_len(DESC_LEN),
        .s_axis_read_desc_tag(TAG[7:0]),
        .s_axis_read_desc_id(8'd0),
        .s_axis_read_desc_dest(8'd0),
        .s_axis_read_desc_user(1'b0),
        .s_axis_read_desc_valid(dma_desc_valid),
        .s_axis_read_desc_ready(dma_desc_ready),
    
        .m_axis_read_desc_status_tag(dma_status_tag),
        .m_axis_read_desc_status_error(dma_status_error),
        .m_axis_read_desc_status_valid(dma_status_valid),
    
        .m_axis_read_data_tdata(dma_axis_tdata),
        .m_axis_read_data_tkeep(),
        .m_axis_read_data_tvalid(dma_axis_tvalid),
        .m_axis_read_data_tready(dma_axis_tready),
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
    //      FIFO B (between DMA and FMA)
    // ========================================
    
    wire [DATA_WIDTH-1:0] fifo_b_axis_tdata;
    wire                  fifo_b_axis_tvalid;
    wire                  fifo_b_axis_tready;
    
    axis_pipeline_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .LENGTH(8)
    ) fifo (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_tdata(dma_axis_tdata),
        .s_axis_tvalid(dma_axis_tvalid),
        .s_axis_tready(dma_axis_tready),

        .m_axis_tdata(fifo_b_axis_tdata),
        .m_axis_tvalid(fifo_b_axis_tvalid),
        .m_axis_tready(fifo_b_axis_tready)
    );
    
    // ========================================
    //      FMA (dot product logic)
    // ========================================

    fma_wrapper #(
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) fma (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_a_tdata(fifo_a_tdata),
        .s_axis_a_tvalid(fifo_a_tvalid),
        .s_axis_a_tready(fifo_a_tready),
    
        .s_axis_b_tdata(fifo_b_axis_tdata),
        .s_axis_b_tvalid(fifo_b_axis_tvalid),
        .s_axis_b_tready(fifo_b_axis_tready),
    
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );
endmodule
