// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat Jun 14 20:22:54 2025
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/mrflu/Projects/vivado-pynq-bram/vivado-pynq-bram.srcs/sources_1/bd/design_1/ip/design_1_axi_bram_ctrl_0_bram_0/design_1_axi_bram_ctrl_0_bram_0_sim_netlist.v
// Design      : design_1_axi_bram_ctrl_0_bram_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_axi_bram_ctrl_0_bram_0,blk_mem_gen_v8_4_7,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_7,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module design_1_axi_bram_ctrl_0_bram_0
   (clka,
    rsta,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    rstb,
    enb,
    web,
    addrb,
    dinb,
    doutb,
    rsta_busy,
    rstb_busy);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA RST" *) input rsta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [3:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [31:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [31:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [31:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE BRAM_CTRL, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB RST" *) input rstb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [3:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [31:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [31:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [31:0]doutb;
  output rsta_busy;
  output rstb_busy;

  wire [31:0]addra;
  wire [31:0]addrb;
  wire clka;
  wire clkb;
  wire [31:0]dina;
  wire [31:0]dinb;
  wire [31:0]douta;
  wire [31:0]doutb;
  wire ena;
  wire enb;
  wire rsta;
  wire rsta_busy;
  wire rstb;
  wire rstb_busy;
  wire [3:0]wea;
  wire [3:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [31:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [31:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "32" *) 
  (* C_ADDRB_WIDTH = "32" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "8" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "2" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "1" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "1" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     10.7492 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "1" *) 
  (* C_HAS_RSTB = "1" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "NONE" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "2048" *) 
  (* C_READ_DEPTH_B = "2048" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "32" *) 
  (* C_READ_WIDTH_B = "32" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "1" *) 
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "4" *) 
  (* C_WEB_WIDTH = "4" *) 
  (* C_WRITE_DEPTH_A = "2048" *) 
  (* C_WRITE_DEPTH_B = "2048" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "32" *) 
  (* C_WRITE_WIDTH_B = "32" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  design_1_axi_bram_ctrl_0_bram_0_blk_mem_gen_v8_4_7 U0
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addra[12:2],1'b0,1'b0}),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,addrb[12:2],1'b0,1'b0}),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[31:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(rsta),
        .rsta_busy(rsta_busy),
        .rstb(rstb),
        .rstb_busy(rstb_busy),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[31:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
jLV29U0rrfMIZhYJzdoUrPoqB9eHQ5NXmWyCdqnN3Wgm+GU4C3zthrN1m4QGiaj0thPCIynZbX+0
7yjtkv+T5ByJ6NhiofAwWseGLvPXlYu6ERAPvi4SAYpF2VUqQHtPAbPmnPubGdDRgIEpeobF7hsz
rEcpEru1pyiScUriyuo=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
vsoizVrOONWw/DhjRLEYrtRmtji+Ok63CbpSg/l9VnoKAi8tAzqRbQ57atGB2N6IGGbKHkbK2Uzh
EHgWvYZeyt4hE+bpQX91vc9PNxfjQMGzPoFD3jCWk30EmEk+AND39eWx+DhJ8xhFuucoOQ2GwyAk
B+Mjs15naPE7DvlHel8hnD4dfSdYhGKp96oozu8JeBto8aHG6poOuYkxSwaut7NCI+mabCkMxtMp
RrydgmRuTvhRTbJMyx5CxFSZTRDrS5aU1vaRlnMiqKCI7g2KY9pemYaJsFeVodBuo6IyKGynyEhs
wr+VtUhQDtaVhMkwB95WwmMoDk9F2L5Au1I+TQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
W081dPMCWhKs5YlQD7n3zvf7+PTcnb8eFWxoVs8+zHLkxDMA1klITbsfztGYvJFce8Yao5XQLLqZ
oUE5Pq2arq+zwICFUcLjdMsmP1WmL82znHOPHm83zNwrxWMloHkySAqzFbgJeHa973uZqj0M8ydc
sYmzCYVlGVjt0QX0xqA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Zpc3MmdLWaVOv+S4z2POuoyslYoAbWc+Npxq2UyQRtDwf566IId3uwAetolMAgfLo/G3ezuSOXMn
8NznS37h9XvmVrxA50SAux68P87WgkLtiUYqM3CMBKkxNlZ/TR8WzTuQyFdvzkOE9lp8HC7LXnk5
RDsnOM+su46FW7ysY01COslo9Xc7rhs6WFqx29+Xcqk8+ZMLSzaJfuwZdNmJFS3Q1vhlq3ZeYqMl
wMieB731KsPxjxp7VKNHpTbgFryC2isqc4ohBDOt52M/Bz4B/rIpFeHfZ7X3jWSiKtSuBsDN2NXf
EMjfAT248dlK7NxJ+NBNPhS5sLxTiGyQhta57A==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rPMYqnkKhJKV1wltOfDrKos9ZbucaoX3WGTuqsdLkGpcKObzslHBwlGrKtWV7bZYmS2SM+QuEMfa
CE+tCUdsSiprp+n5BuSQlJa6BJ8mlqccjoo/JLw2QEmUhyMXQ3TLGomGGoZdeTmMPXhUBAOyLPea
Ddc8mgtTN8Kpy117GOTXDKP+IKJqW01fLrPJpgEhFiJCbyElLgtCRWmI94gX+y4XNVS0Cd1YwNw6
4nHgnEdC7fXARDKcYO3VsWC/pdzPQgursXloNLrVYa6i2xr+8E1V0+nSWwNYQZP7XUIVqXKMU8Ea
bT4acXrRCF/5tJJ5B9JparYI0zxXSbaakn1dIw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mfroTgL8g2pyIXQ/mGO9YHm19cd5mOlJ++qpusOYeVxGmkIhvF4aKx+AyIUz2yGGAeCtOzIasHty
pyqKgZhibSqxcpHgR0m6GOxXXOXJiHaK8NzxUzXeRJovcBI/WjtDhXeb1LRMI1J97jVBtJPJQH0Y
fGOD7jWvkvQwxnrZdyLp6kPWgSIcavHHDbO7iJv4gnyGp6W3/FCDo2RKWNLoW+SNjSdLZ6YRP8a+
ldaGU8TYvJ03KWlmik7repuN6AwxCjg2KeQ+x1sBAEXzROXomuSbvX3ZAo8UiIKAQY1SJumHLG3L
QI/S4Wbl1Hz6LDTsttMwP480gq6+tb6s1E4oWw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QJIabgm8dx/gVHbOQFwt8maOKVHFgkpZTPR6dzD8fqoGo9M9oGPTqBqchtPZWgv2UYFF2KEUSlV4
L3SDXBKrLs+NsAVTcICaEMiEi6j82zj/C1LsPkQfS8RLrg0ab8lbDMb5YqJ7lkHs3iM65x2iN1Mf
66cTgCbkAdl3rDpab75btpTQt5ZKiq5CSY3RZfyIW0uWbTGTELm6liuRKM9+K8BQwTU7A+FFFQBA
/9eJwQYzNNA/iwoYJ2WTPd6pBlzXriNLu9M+/2bYicNBSuH1PBR9v2ESrTB6k7EiV1zvBXV9NuG/
sFt4MumWMuSNwP2W38bQATxxW/l0IrmaXGOC/w==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
lhKf/Vgj6pHpme1ji4HVe36BU8pMkam/2I9lFeyOiBnIbzgdEGfLJBcEvkL33A7s0hxa6LFbHnkT
upgMpPjmIghBz3xUQ13vpiY152thFec6qvlcdg1r+GTmnBOSFl6g/OfZ3eFUhfsve6ZjQHpXnKFo
a55hN2+eP1EG9+VxGeM7XkHaeFhEIry52qtnmg072KEFIwRiGs2d/TJ4AqupuIdIiP1kTN9k+oqa
2ta1vdtqPY0dDHqrf+5YSd0CejkhQeCqg/bauLP3755SwdOPRgooG5ANT8hUpTiFMFXtU+GC9NSp
evJtMHUy1NbgMmhFHO+w3URLEdjSaBxZPD7YLdWkF65jY526tJzoek+BzEKoBaGfCaY7O1nHKXm+
89k3rPUy0Xo4/0nHpno+N/Db09heJPbnGsCwN/l+KnR6Lz8kvWziBjZe0ijOkKI+T12y3T1VeOtY
H/aqtNlQt1mhFwrbw6ezaAiDPVbCQXnly6b4tbb8+nFsxWOGIGAfLozB

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
PNsQ8uEcQYrl+GaDuBaq1tQ5br5aAdaqHnyrc0NVu/JnQUk53jaiLx8Oz5fNACvWelUUk2/C+P5I
b2rbU1bb/dC6TqC5J1N0yoMYRYw58u4Lrl8Kgqgt9Rlph5Qgzzfxp+oblXF/pO4mRyAXpZhpNkFT
0Ar9BUtPOTOtJ9/g53SRnZ6GjxzfeD+25J4fcXBNo2gCTgUkwiLSsJRwTB/cJmn+dZPwPdIOHEP9
TkfDK+OrbLYO3T+DFBTCMRNH2NB1J9sc5s+nPU8iYnjgPTo6HoGW+LIlCz6yNJMZzJzoeW708utc
0fJXkT7vLDVh7olvy3V9AAY8Do0YR1kiZlhVhQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zAz8RnGHFebkJFAS+gjC+mXHW7m7We+JgSmIz15mS01u/4+9Ng0sJfkeXOClmVPTQ2Mp2Yuv6/6f
ehzUTcANilWsqLM6Q1FToCPNX/NTqodlcHirGM7b5R9yevouNT/aqH12nmbunBQmBHmehNutdCjG
r6Z7kZgeZ2ZE7MMOF0rTy1XHEPkqgMNTRoS8R/pPWPTW4/j+bn3aJj0Q/fTz4Gi3mbSUKWs2fREQ
UKiuolNJkN6DiDvhlVYHUyytXNJG44ikmBXehoQQRLapkYaxnQmMRT1ok9uY6pKoy71CtvJ3Mt2x
EQv1GU2i4qQyAOwa0mkEohWXduicU6tDz3zQwQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TK3eE9V+v1z2P1KjG4GrjhA1n3qDOpNzLGXdtjnjhF0QBFPSuhC+nmNqTPOb3p2a9r5KD0miY3Cd
+KpjH6Ao09E2/LD2Go4aLQh6vP+9BldlSKEwCGfx2NjBQrXWVH21lQR7IRjOvyTOclpd7SgtUJLw
dvebETyLiKr9C6RfnIBeptuCA3iJlXfwkh6I0JfzD5WBizQkotioZmmrXv5105pCXQ4Ta1WThFsA
2ll9dZeSjEDHUxxhfyfjryv9m4VL89ZDU/rGITsdptwB1BC1jLqmPDymY05lyECnjA6NIR5GGfI4
K2y2f4GfikKoN5r9IOvFzw963Wm82ZZPtXOKGg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 60000)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
