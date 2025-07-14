module mvm_accelerator_wrapper #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH / 8,
    parameter ID_WIDTH = 4,
    parameter WORDS_PER_TRANSFER = 17048,
    parameter NUM_CHANNELS = 4
)(
    input  wire clk,
    input  wire rstn,

    // AXIS stream inputs (flattened)
    input  wire [DATA_WIDTH-1:0] s_axis_a_0_tdata,
    input  wire                  s_axis_a_0_tvalid,
    output wire                  s_axis_a_0_tready,

    input  wire [DATA_WIDTH-1:0] s_axis_a_1_tdata,
    input  wire                  s_axis_a_1_tvalid,
    output wire                  s_axis_a_1_tready,

    input  wire [DATA_WIDTH-1:0] s_axis_a_2_tdata,
    input  wire                  s_axis_a_2_tvalid,
    output wire                  s_axis_a_2_tready,

    input  wire [DATA_WIDTH-1:0] s_axis_a_3_tdata,
    input  wire                  s_axis_a_3_tvalid,
    output wire                  s_axis_a_3_tready,

    // AXIS stream outputs (flattened)
    output wire [DATA_WIDTH-1:0] m_axis_0_tdata,
    output wire                  m_axis_0_tvalid,
    input  wire                  m_axis_0_tready,
    output wire                  m_axis_0_tlast,

    output wire [DATA_WIDTH-1:0] m_axis_1_tdata,
    output wire                  m_axis_1_tvalid,
    input  wire                  m_axis_1_tready,
    output wire                  m_axis_1_tlast,

    output wire [DATA_WIDTH-1:0] m_axis_2_tdata,
    output wire                  m_axis_2_tvalid,
    input  wire                  m_axis_2_tready,
    output wire                  m_axis_2_tlast,

    output wire [DATA_WIDTH-1:0] m_axis_3_tdata,
    output wire                  m_axis_3_tvalid,
    input  wire                  m_axis_3_tready,
    output wire                  m_axis_3_tlast,

    // AXI full (unchanged)
    input  wire [7:0]             s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_b_awaddr,
    input  wire [7:0]             s_axi_b_awlen,
    input  wire [2:0]             s_axi_b_awsize,
    input  wire [1:0]             s_axi_b_awburst,
    input  wire                   s_axi_b_awlock,
    input  wire [3:0]             s_axi_b_awcache,
    input  wire [2:0]             s_axi_b_awprot,
    input  wire                   s_axi_b_awvalid,
    output wire                   s_axi_b_awready,
    input  wire [DATA_WIDTH-1:0]  s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axi_b_wstrb,
    input  wire                   s_axi_b_wlast,
    input  wire                   s_axi_b_wvalid,
    output wire                   s_axi_b_wready,
    output wire [7:0]             s_axi_b_bid,
    output wire [1:0]             s_axi_b_bresp,
    output wire                   s_axi_b_bvalid,
    input  wire                   s_axi_b_bready,
    input  wire [ID_WIDTH-1:0]    s_axi_b_arid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_b_araddr,
    input  wire [7:0]             s_axi_b_arlen,
    input  wire [2:0]             s_axi_b_arsize,
    input  wire [1:0]             s_axi_b_arburst,
    input  wire                   s_axi_b_arlock,
    input  wire [3:0]             s_axi_b_arcache,
    input  wire [2:0]             s_axi_b_arprot,
    input  wire                   s_axi_b_arvalid,
    output wire                   s_axi_b_arready,
    output wire [ID_WIDTH-1:0]    s_axi_b_rid,
    output wire [DATA_WIDTH-1:0]  s_axi_b_rdata,
    output wire [1:0]             s_axi_b_rresp,
    output wire                   s_axi_b_rlast,
    output wire                   s_axi_b_rvalid,
    input  wire                   s_axi_b_rready
);

    // ================================================
    // Pack scalar signals into arrays
    // ================================================
    wire [DATA_WIDTH-1:0] s_axis_a_tdata_arr [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tvalid_arr[NUM_CHANNELS-1:0];
    wire                  s_axis_a_tready_arr[NUM_CHANNELS-1:0];
    wire [DATA_WIDTH-1:0] m_axis_tdata_arr   [NUM_CHANNELS-1:0];
    wire                  m_axis_tvalid_arr  [NUM_CHANNELS-1:0];
    wire                  m_axis_tready_arr  [NUM_CHANNELS-1:0];
    wire                  m_axis_tlast_arr   [NUM_CHANNELS-1:0];

    // Assign flattened inputs to array
    assign s_axis_a_tdata_arr[0]  = s_axis_a_0_tdata;
    assign s_axis_a_tvalid_arr[0] = s_axis_a_0_tvalid;
    assign s_axis_a_tready       = s_axis_a_tready_arr[0];

    assign s_axis_a_tdata_arr[1]  = s_axis_a_1_tdata;
    assign s_axis_a_tvalid_arr[1] = s_axis_a_1_tvalid;
    assign s_axis_a_tready       = s_axis_a_tready_arr[1];

    assign s_axis_a_tdata_arr[2]  = s_axis_a_2_tdata;
    assign s_axis_a_tvalid_arr[2] = s_axis_a_2_tvalid;
    assign s_axis_a_tready       = s_axis_a_tready_arr[2];

    assign s_axis_a_tdata_arr[3]  = s_axis_a_3_tdata;
    assign s_axis_a_tvalid_arr[3] = s_axis_a_3_tvalid;
    assign s_axis_a_tready       = s_axis_a_tready_arr[3];

    // Assign array outputs to flattened wires
    assign m_axis_0_tdata  = m_axis_tdata_arr[0];
    assign m_axis_0_tvalid = m_axis_tvalid_arr[0];
    assign m_axis_tready_arr[0] = m_axis_0_tready;
    assign m_axis_0_tlast  = m_axis_tlast_arr[0];

    assign m_axis_1_tdata  = m_axis_tdata_arr[1];
    assign m_axis_1_tvalid = m_axis_tvalid_arr[1];
    assign m_axis_tready_arr[1] = m_axis_1_tready;
    assign m_axis_1_tlast  = m_axis_tlast_arr[1];

    assign m_axis_2_tdata  = m_axis_tdata_arr[2];
    assign m_axis_2_tvalid = m_axis_tvalid_arr[2];
    assign m_axis_tready_arr[2] = m_axis_2_tready;
    assign m_axis_2_tlast  = m_axis_tlast_arr[2];

    assign m_axis_3_tdata  = m_axis_tdata_arr[3];
    assign m_axis_3_tvalid = m_axis_tvalid_arr[3];
    assign m_axis_tready_arr[3] = m_axis_3_tready;
    assign m_axis_3_tlast  = m_axis_tlast_arr[3];

    // ================================================
    // Instantiate accelerator
    // ================================================
    mvm_accelerator #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .STRB_WIDTH(STRB_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
        .NUM_CHANNELS(NUM_CHANNELS)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .s_axis_a_tdata_arr(s_axis_a_tdata_arr),
        .s_axis_a_tvalid_arr(s_axis_a_tvalid_arr),
        .s_axis_a_tready_arr(s_axis_a_tready_arr),
        .m_axis_tdata_arr(m_axis_tdata_arr),
        .m_axis_tvalid_arr(m_axis_tvalid_arr),
        .m_axis_tready_arr(m_axis_tready_arr),
        .m_axis_tlast_arr(m_axis_tlast_arr),
        .s_axi_b_awid(s_axi_b_awid),
        .s_axi_b_awaddr(s_axi_b_awaddr),
        .s_axi_b_awlen(s_axi_b_awlen),
        .s_axi_b_awsize(s_axi_b_awsize),
        .s_axi_b_awburst(s_axi_b_awburst),
        .s_axi_b_awlock(s_axi_b_awlock),
        .s_axi_b_awcache(s_axi_b_awcache),
        .s_axi_b_awprot(s_axi_b_awprot),
        .s_axi_b_awvalid(s_axi_b_awvalid),
        .s_axi_b_awready(s_axi_b_awready),
        .s_axi_b_wdata(s_axi_b_wdata),
        .s_axi_b_wstrb(s_axi_b_wstrb),
        .s_axi_b_wlast(s_axi_b_wlast),
        .s_axi_b_wvalid(s_axi_b_wvalid),
        .s_axi_b_wready(s_axi_b_wready),
        .s_axi_b_bid(s_axi_b_bid),
        .s_axi_b_bresp(s_axi_b_bresp),
        .s_axi_b_bvalid(s_axi_b_bvalid),
        .s_axi_b_bready(s_axi_b_bready),
        .s_axi_b_arid(s_axi_b_arid),
        .s_axi_b_araddr(s_axi_b_araddr),
        .s_axi_b_arlen(s_axi_b_arlen),
        .s_axi_b_arsize(s_axi_b_arsize),
        .s_axi_b_arburst(s_axi_b_arburst),
        .s_axi_b_arlock(s_axi_b_arlock),
        .s_axi_b_arcache(s_axi_b_arcache),
        .s_axi_b_arprot(s_axi_b_arprot),
        .s_axi_b_arvalid(s_axi_b_arvalid),
        .s_axi_b_arready(s_axi_b_arready),
        .s_axi_b_rid(s_axi_b_rid),
        .s_axi_b_rdata(s_axi_b_rdata),
        .s_axi_b_rresp(s_axi_b_rresp),
        .s_axi_b_rlast(s_axi_b_rlast),
        .s_axi_b_rvalid(s_axi_b_rvalid),
        .s_axi_b_rready(s_axi_b_rready)
    );

endmodule
