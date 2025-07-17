`timescale 1ns / 1ps

module axi_splitter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 64,
    parameter ID_WIDTH   = 8
)(
    input  wire                      ACLK,
    input  wire                      ARESETN,

    // Slave AXI interface (input)
    input  wire [ID_WIDTH-1:0]       S_AXI_AWID,
    input  wire [ADDR_WIDTH-1:0]     S_AXI_AWADDR,
    input  wire [7:0]                S_AXI_AWLEN,
    input  wire [2:0]                S_AXI_AWSIZE,
    input  wire [1:0]                S_AXI_AWBURST,
    input  wire                      S_AXI_AWVALID,
    output wire                      S_AXI_AWREADY,

    input  wire [DATA_WIDTH-1:0]     S_AXI_WDATA,
    input  wire [(DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
    input  wire                      S_AXI_WLAST,
    input  wire                      S_AXI_WVALID,
    output wire                      S_AXI_WREADY,

    output wire [ID_WIDTH-1:0]       S_AXI_BID,
    output wire [1:0]                S_AXI_BRESP,
    output wire                      S_AXI_BVALID,
    input  wire                      S_AXI_BREADY,

    // Master 0 AXI interface (output)
    output wire [ID_WIDTH-1:0]       M0_AXI_AWID,
    output wire [ADDR_WIDTH-1:0]     M0_AXI_AWADDR,
    output wire [7:0]                M0_AXI_AWLEN,
    output wire [2:0]                M0_AXI_AWSIZE,
    output wire [1:0]                M0_AXI_AWBURST,
    output wire                      M0_AXI_AWVALID,
    input  wire                      M0_AXI_AWREADY,

    output wire [DATA_WIDTH-1:0]     M0_AXI_WDATA,
    output wire [(DATA_WIDTH/8)-1:0] M0_AXI_WSTRB,
    output wire                      M0_AXI_WLAST,
    output wire                      M0_AXI_WVALID,
    input  wire                      M0_AXI_WREADY,

    input  wire [ID_WIDTH-1:0]       M0_AXI_BID,
    input  wire [1:0]                M0_AXI_BRESP,
    input  wire                      M0_AXI_BVALID,
    output wire                      M0_AXI_BREADY,

    // Master 1 AXI interface (output)
    output wire [ID_WIDTH-1:0]       M1_AXI_AWID,
    output wire [ADDR_WIDTH-1:0]     M1_AXI_AWADDR,
    output wire [7:0]                M1_AXI_AWLEN,
    output wire [2:0]                M1_AXI_AWSIZE,
    output wire [1:0]                M1_AXI_AWBURST,
    output wire                      M1_AXI_AWVALID,
    input  wire                      M1_AXI_AWREADY,

    output wire [DATA_WIDTH-1:0]     M1_AXI_WDATA,
    output wire [(DATA_WIDTH/8)-1:0] M1_AXI_WSTRB,
    output wire                      M1_AXI_WLAST,
    output wire                      M1_AXI_WVALID,
    input  wire                      M1_AXI_WREADY,

    input  wire [ID_WIDTH-1:0]       M1_AXI_BID,
    input  wire [1:0]                M1_AXI_BRESP,
    input  wire                      M1_AXI_BVALID,
    output wire                      M1_AXI_BREADY
);

    // Address write forwarding
    assign M0_AXI_AWID    = S_AXI_AWID;
    assign M0_AXI_AWADDR  = S_AXI_AWADDR;
    assign M0_AXI_AWLEN   = S_AXI_AWLEN;
    assign M0_AXI_AWSIZE  = S_AXI_AWSIZE;
    assign M0_AXI_AWBURST = S_AXI_AWBURST;
    assign M0_AXI_AWVALID = S_AXI_AWVALID;

    assign M1_AXI_AWID    = S_AXI_AWID;
    assign M1_AXI_AWADDR  = S_AXI_AWADDR;
    assign M1_AXI_AWLEN   = S_AXI_AWLEN;
    assign M1_AXI_AWSIZE  = S_AXI_AWSIZE;
    assign M1_AXI_AWBURST = S_AXI_AWBURST;
    assign M1_AXI_AWVALID = S_AXI_AWVALID;

    assign S_AXI_AWREADY = M0_AXI_AWREADY & M1_AXI_AWREADY;

    // Write data forwarding
    assign M0_AXI_WDATA  = S_AXI_WDATA;
    assign M0_AXI_WSTRB  = S_AXI_WSTRB;
    assign M0_AXI_WLAST  = S_AXI_WLAST;
    assign M0_AXI_WVALID = S_AXI_WVALID;

    assign M1_AXI_WDATA  = S_AXI_WDATA;
    assign M1_AXI_WSTRB  = S_AXI_WSTRB;
    assign M1_AXI_WLAST  = S_AXI_WLAST;
    assign M1_AXI_WVALID = S_AXI_WVALID;

    assign S_AXI_WREADY = M0_AXI_WREADY & M1_AXI_WREADY;

    assign S_AXI_BID     = M0_AXI_BID; // or M1_AXI_BID, they should be equal
    assign S_AXI_BRESP   = M0_AXI_BRESP;
    assign S_AXI_BVALID  = M0_AXI_BVALID & M1_AXI_BVALID;
    assign M0_AXI_BREADY = S_AXI_BREADY;
    assign M1_AXI_BREADY = S_AXI_BREADY;

endmodule
