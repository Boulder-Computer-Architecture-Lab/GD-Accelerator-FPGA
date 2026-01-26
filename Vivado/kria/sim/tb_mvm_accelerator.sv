`timescale 1ns / 1ps

module tb_mvm_accelerator;

    `include "axi_a_channel_bindings.svh"
    `define GET_CHANNELS `CHANNELS_4 // <------------ `CHANNELS_{CHANNELS_PER_INST} (must match the parameter)
                                     // Note: Also run ./Vivado/scripts/update_channels.py when this 
                                     // is changed to update all the relevant header files

    // --- Config ---
    
    parameter  real     PCLK0_FREQ_MHZ = 250.0;
    localparam realtime PCLK0_PERIOD_NS = 1000.0 / PCLK0_FREQ_MHZ;

    parameter ARCH_TYPE = 0; // Select accelerator type (0=split)
    
    parameter int NUM_TRANSFERS = 2;
    parameter int BATCHES_PER_TRANSFER = 2;

    parameter int DATA_WIDTH = 128; // Max data width for HP ports is 128
    parameter int ADDR_WIDTH = 64;
    parameter int ID_WIDTH   = 8;
    parameter int STRB_WIDTH = DATA_WIDTH/8; // Unused
    
    parameter int ELEMENT_WIDTH = 32; // Can be 16, 32, or 64
    parameter int RESULT_WIDTH  = 64; // Must be 64
    
    parameter int NUM_ACCEL_INST     = 1;
    parameter int CHANNELS_PER_INST  = 4;
    parameter int NUM_CHANNELS       = NUM_ACCEL_INST * CHANNELS_PER_INST;
    parameter int NUM_RAM_PARTITIONS = CHANNELS_PER_INST;
    
    parameter int ELEMENTS_PER_ROW = 17048;
    parameter int NUM_ROWS         = 48;
    parameter int ROWS_PER_CHANNEL = NUM_ROWS / NUM_CHANNELS;
    parameter int ROWS_PER_CHANNEL_PER_BATCH = ROWS_PER_CHANNEL / BATCHES_PER_TRANSFER;
         
    parameter int AXI_RAM_DATA_WIDTH = 256;
    parameter int AXI_RAM_STRB_WIDTH = AXI_RAM_DATA_WIDTH/8;
    
    int OFFSET_CYCLES = 1000;
    int input_order[CHANNELS_PER_INST] = '{1, 2, 3, 4}; // Switch the order that s_axis_a channels start arriving. 
                                                        // Set to (0, 0, 0, 0) for simultaneous start, but note that
                                                        // the partition arbitration logic assumes an offset.
    
    localparam ELEMENTS_PER_WORD      = DATA_WIDTH / ELEMENT_WIDTH;
    localparam WORDS_PER_ROW          = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD;
    
    localparam AXI_RAM_ELEMENTS_PER_WORD = AXI_RAM_DATA_WIDTH / ELEMENT_WIDTH;
    localparam ALIGN_FACTOR              = AXI_RAM_ELEMENTS_PER_WORD * NUM_RAM_PARTITIONS;
    localparam ELEMENTS_PER_ROW_PADDED   = ((ELEMENTS_PER_ROW + ALIGN_FACTOR - 1) / ALIGN_FACTOR) * ALIGN_FACTOR;
    localparam WORDS_PER_ROW_PADDED      = ELEMENTS_PER_ROW_PADDED / ELEMENTS_PER_WORD;
    
    localparam AXI_RAM_WORDS_PER_ROW       = ELEMENTS_PER_ROW_PADDED / AXI_RAM_ELEMENTS_PER_WORD;
    localparam AXI_RAM_WORDS_PER_PARTITION = AXI_RAM_WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    localparam AXI_RAM_BYTES_PER_PARTITION = AXI_RAM_WORDS_PER_PARTITION * AXI_RAM_STRB_WIDTH;
    localparam AXI_RAM_ADDR_WIDTH          = $clog2(AXI_RAM_BYTES_PER_PARTITION+1);
    localparam [ADDR_WIDTH-1:0] PARTITION_ALIGN = (1 << AXI_RAM_ADDR_WIDTH);
    
    localparam MAX_BURST_LEN = 128;
    
    // --------------
    
    initial assert (PCLK0_FREQ_MHZ > 0.0)                                              else $fatal(1, "PCLK0_FREQ_MHZ must be > 0");
    initial assert (ELEMENT_WIDTH == 16 || ELEMENT_WIDTH == 32 || ELEMENT_WIDTH == 64) else $fatal(1, "ELEMENT_WIDTH must be 16, 32, or 64");
    initial assert (RESULT_WIDTH == 64)                                                else $fatal(1, "RESULT_WIDTH must be 64");
    initial assert (ROWS_PER_CHANNEL % BATCHES_PER_TRANSFER == 0)                      else $fatal(1, "ROWS_PER_CHANNEL must be divisible by BATCHES_PER_TRANSFER");
    
    // --- Floating-point helpers ---
    
    typedef logic [15:0] fp16_t;

    function automatic fp16_t f32_to_f16(input shortreal s);

        int unsigned x;
        bit          sign;
        int unsigned exp_u, frac_u;
        int          half_exp; // signed
        int unsigned half_frac;
        fp16_t       h;
    
        x       = $shortrealtobits(s); // 0|8|23
        sign    = x[31];
        exp_u   = (x >> 23) & 8'hFF;
        frac_u  =  x        & 32'h7FFFFF;
    
        if (exp_u == 8'hFF) begin
            // Inf/NaN
            half_frac = (frac_u != 0) ? (16'h200 | (frac_u >> 13)) : 16'h000;
            h = {sign, 5'h1F, half_frac[9:0]};
        end else if (exp_u == 0) begin
            if (frac_u == 0) begin
                h = {sign, 5'h00, 10'h000}; // +/- 0
            end else begin
                // normalize float subnormal
                int e = -126;
                int unsigned f = frac_u;
                while ((f & 32'h0080_0000) == 0) begin
                    f <<= 1;
                    e -= 1;
                end
                f &= 32'h007F_FFFF;
                half_exp = e + 15;
                if (half_exp <= 0) begin
                    if (half_exp < -10) h = {sign, 5'h00, 10'h000};
                    else begin
                        int unsigned mant = (f | 32'h0080_0000) >> (1 - half_exp);
                        half_frac = (mant + 32'h0000_1000) >> 13;  // RNE
                        h = {sign, 5'h00, half_frac[9:0]};
                    end
                end else begin
                    half_frac = (frac_u + 32'h0000_1000) >> 13;  // RNE
                    if (half_frac == 1024) begin half_exp += 1; half_frac = 0; end
                    if (half_exp >= 31) h = {sign, 5'h1F, 10'h000};
                    else                h = {sign, half_exp[4:0], half_frac[9:0]};
                end
            end
        end else begin
            // normal float
            half_exp = $signed(exp_u) - 127 + 15;
            if (half_exp >= 31) begin
                h = {sign, 5'h1F, 10'h000}; // overflow -> Inf
            end else if (half_exp <= 0) begin
                if (half_exp < -10) h = {sign, 5'h00, 10'h000};
                else begin
                    int unsigned mant = (frac_u | 32'h0080_0000);
                    int          sh   = 14 - half_exp;
                    int unsigned sub  = (mant + (1 << (sh-1))) >> sh; // RNE
                    h = {sign, 5'h00, sub[9:0]};
                end
            end else begin
                half_frac = (frac_u + 32'h0000_1000) >> 13;  // RNE
                if (half_frac == 1024) begin half_exp += 1; half_frac = 0; end
                if (half_exp >= 31) h = {sign, 5'h1F, 10'h000};
                else                h = {sign, half_exp[4:0], half_frac[9:0]};
            end
        end
        return h;
    endfunction
    
    function automatic shortreal f16_to_f32(input fp16_t h);
        bit          sign;
        int unsigned exp_h, frac_h;
        int unsigned out_exp, out_frac;
        int unsigned u32;
    
        sign   = h[15];
        exp_h  = h[14:10];
        frac_h = h[9:0];
    
        if (exp_h == 0) begin
            if (frac_h == 0) begin
                out_exp  = 0;
                out_frac = 0;
            end else begin
                // half subnormal -> normalize
                int f = frac_h;
                int shift = 0;
                while ((f & 10'h200) == 0) begin
                    f <<= 1; shift++;
                end
                f &= 10'h3FF;
                out_exp  = 127 - 15 - shift;
                out_frac = f << 13;
            end
        end else if (exp_h == 31) begin
            out_exp  = 255;
            out_frac = (frac_h != 0) ? ((frac_h << 13) | 32'h0007_FFFF) : 0; // keep NaN payload non-zero
        end else begin
            out_exp  = exp_h - 15 + 127;
            out_frac = frac_h << 13;
        end
    
        u32 = (sign << 31) | (out_exp << 23) | out_frac;
        return $bitstoshortreal(u32);
    endfunction
    
    typedef logic [ELEMENT_WIDTH-1:0] elem_t;
    
    // Pack a real into elem_t according to ELEMENT_WIDTH
    function automatic elem_t real_to_elem(input real r);
        elem_t result;
        shortreal sr;
        logic [31:0] u32;
        longint unsigned u64;
        begin
            if (ELEMENT_WIDTH == 16) begin
                // real -> shortreal -> fp16 bits
                sr     = shortreal'(r);
                result = elem_t'(f32_to_f16(sr));
            end
            else if (ELEMENT_WIDTH == 32) begin
                // real -> shortreal -> IEEE-754 single
                sr  = shortreal'(r);
                u32 = $shortrealtobits(sr);
                result = elem_t'(u32[ELEMENT_WIDTH-1:0]);
            end
            else if (ELEMENT_WIDTH == 64) begin
                // real -> IEEE-754 double
                u64    = $realtobits(r);
                result = elem_t'(u64[ELEMENT_WIDTH-1:0]); // 64 bits
            end
            else begin
                $fatal(1, "Unsupported ELEMENT_WIDTH = %0d", ELEMENT_WIDTH);
            end
    
            return result;
        end
    endfunction
    
    // Unpack elem_t back into real
    function automatic real elem_to_real(input elem_t h);
        real r;
        shortreal sr;
        logic [31:0] u32;
        longint unsigned u64;
        begin
            if (ELEMENT_WIDTH == 16) begin
                // fp16 -> shortreal -> real
                sr = f16_to_f32(fp16_t'(h));
                r  = real'(sr);
            end
            else if (ELEMENT_WIDTH == 32) begin
                // bits -> shortreal -> real
                u32 = '0;
                u32[ELEMENT_WIDTH-1:0] = h;
                sr = $bitstoshortreal(u32);
                r  = real'(sr);
            end
            else if (ELEMENT_WIDTH == 64) begin
                // bits -> real
                u64 = '0;
                u64[ELEMENT_WIDTH-1:0] = h;
                r  = $bitstoreal(u64);
            end
            else begin
                $fatal(1, "Unsupported ELEMENT_WIDTH = %0d", ELEMENT_WIDTH);
            end
    
            return r;
        end
    endfunction
    
    // ------------------------------

    // Clock & reset signals    
    reg clk = 0, rstn = 1;
    reg start_transfer = 0;
    
    always #(PCLK0_PERIOD_NS/2.0) clk = ~clk;
    
    // Inputs
    logic [DATA_WIDTH-1:0] s_axis_a_tdata   [NUM_CHANNELS] = '{default:'0};
    logic                  s_axis_a_tvalid  [NUM_CHANNELS] = '{default:1'b0};
    logic                  s_axis_a_tready  [NUM_CHANNELS] = '{default:1'b0};
    logic                  s_axis_a_tlast   [NUM_CHANNELS] = '{default:1'b0};
    
    // Outputs
    logic [RESULT_WIDTH-1:0] m_axis_tdata     [NUM_CHANNELS] = '{default:'0};
    logic                    m_axis_tvalid    [NUM_CHANNELS] = '{default:1'b0};
    logic                    m_axis_tready    [NUM_CHANNELS] = '{default:1'b0};
    logic                    m_axis_tlast     [NUM_CHANNELS] = '{default:1'b0};

    // AXI Full write interface for vector b
    logic [ID_WIDTH-1:0]           s_axi_b_awid    [NUM_ACCEL_INST] = '{default:'0};
    logic [ADDR_WIDTH-1:0]         s_axi_b_awaddr  [NUM_ACCEL_INST] = '{default:'0};
    logic [7:0]                    s_axi_b_awlen   [NUM_ACCEL_INST] = '{default:'0};
    logic [2:0]                    s_axi_b_awsize  [NUM_ACCEL_INST] = '{default:'0};
    logic [1:0]                    s_axi_b_awburst [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_awlock  [NUM_ACCEL_INST] = '{default:'0};
    logic [3:0]                    s_axi_b_awcache [NUM_ACCEL_INST] = '{default:'0};
    logic [2:0]                    s_axi_b_awprot  [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_awvalid [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_awready [NUM_ACCEL_INST] = '{default:'0};
    logic [AXI_RAM_DATA_WIDTH-1:0] s_axi_b_wdata   [NUM_ACCEL_INST] = '{default:'0};
    logic [AXI_RAM_STRB_WIDTH-1:0] s_axi_b_wstrb   [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_wlast   [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_wvalid  [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_wready  [NUM_ACCEL_INST] = '{default:'0};
    logic [ID_WIDTH-1:0]           s_axi_b_bid     [NUM_ACCEL_INST] = '{default:'0};
    logic [1:0]                    s_axi_b_bresp   [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_bvalid  [NUM_ACCEL_INST] = '{default:'0};
    logic                          s_axi_b_bready  [NUM_ACCEL_INST] = '{default:'0};
             
    logic [AXI_RAM_DATA_WIDTH-1:0] vector [AXI_RAM_WORDS_PER_ROW-1:0] = '{default:'0};
    
    // AXI full write task
    task axi_write_burst(
        input logic [ADDR_WIDTH-1:0] addr, 
        input int len, 
        input int vec_offset,
        input int glob_inst
    );
        integer k, idx;
        begin
            automatic int inst = glob_inst;

            // Write address
            s_axi_b_awaddr[inst]  = addr;
            s_axi_b_awlen[inst]   = len - 1;
            s_axi_b_awsize[inst]  = $clog2(AXI_RAM_STRB_WIDTH);
            s_axi_b_awburst[inst] = 1;
            s_axi_b_awvalid[inst] = 1;
            
            $display("\n[AXI WRITE] Instance %0d: Starting burst write", inst);
            $display("[AXI WRITE]   Address    = 0x%08h", addr);
            $display("[AXI WRITE]   Burst Len  = %0d (beats)", len);
            $display("[AXI WRITE]   Beat Size  = %0d bytes", (1 << s_axi_b_awsize[inst]));
            $display("[AXI WRITE]   Total Size = %0d bytes", len * (1 << s_axi_b_awsize[inst]));

            @(posedge clk iff (s_axi_b_awready[inst] && s_axi_b_awvalid[inst]));
            s_axi_b_awvalid[inst] = 0;
            $display("[AXI WRITE] Instance %0d: AW handshake done", inst);
                
            // Write data
            for (k = 0; k < len; k++) begin
                idx = k + vec_offset;
                $display("[AXI WRITE] Instance %0d: Writing beat %0d: data = %h (vector[%0d])", inst, k, vector[idx], idx);
                s_axi_b_wdata[inst] = vector[idx];
                s_axi_b_wstrb[inst] = {AXI_RAM_STRB_WIDTH{1'b1}};
                s_axi_b_wvalid[inst] = 1;
                s_axi_b_wlast[inst] = (k == len-1);
                
                @(posedge clk iff (s_axi_b_wready[inst] && s_axi_b_wvalid[inst]));
                s_axi_b_wvalid[inst] = 0;
            end
            s_axi_b_wvalid[inst] = 0;
            s_axi_b_wlast[inst] = 0;
            $display("[AXI WRITE] Instance %0d: Data phase complete", inst);
                    
            // Write response
            s_axi_b_bready[inst] = 1;
            @(posedge clk iff (s_axi_b_bvalid[inst] && s_axi_b_bready[inst]));
            s_axi_b_bready[inst] = 0;
            $display("[AXI WRITE] Instance %0d: Received B response", inst);
            
            // Reset
            s_axi_b_awvalid[inst] = 0;
            s_axi_b_wvalid[inst]  = 0;
            s_axi_b_bready[inst]  = 0;
            s_axi_b_awid[inst]    = 0;
            s_axi_b_awlock[inst]  = 0;
            s_axi_b_awcache[inst] = 0;
            s_axi_b_awprot[inst]  = 0;
            s_axi_b_wlast[inst]   = 0;
            s_axi_b_wstrb[inst]   = {AXI_RAM_STRB_WIDTH{1'b1}};
            $display("[AXI WRITE] Instance %0d: Burst write complete\n", inst);
        end
    endtask
    
    localparam [ADDR_WIDTH-1:0] BASE_ADDR = { {(ADDR_WIDTH-32){1'b0}}, 32'h8000_0000 };
    localparam [ADDR_WIDTH-1:0] STRIDE    = { {(ADDR_WIDTH-32){1'b0}}, 32'h1000_0000 };

    // Instantiate DUT
    generate
        for (genvar inst = 0; inst < NUM_ACCEL_INST; inst++) begin : gen_accel
            localparam int base_idx = inst * CHANNELS_PER_INST;
        
            mvm_accelerator #(
                .ARCH_TYPE(ARCH_TYPE),
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .ELEMENT_WIDTH(ELEMENT_WIDTH),
                .ELEMENTS_PER_ROW(ELEMENTS_PER_ROW_PADDED),
                .NUM_ROWS(NUM_ROWS),
                .NUM_CHANNELS(CHANNELS_PER_INST),
                .AXI_RAM_DATA_WIDTH(AXI_RAM_DATA_WIDTH),
                .AXI_RAM_BASE_ADDR(BASE_ADDR + STRIDE * inst),
                .RESULT_WIDTH(RESULT_WIDTH)
            ) dut (
                .clk(clk), 
                .rstn(rstn),
                .s_axil_aclk(clk),
                .s_axil_aresetn(rstn),
                
                `GET_CHANNELS
                .s_axi_b_awid      (s_axi_b_awid   [inst]),
                .s_axi_b_awaddr    (s_axi_b_awaddr [inst]),
                .s_axi_b_awlen     (s_axi_b_awlen  [inst]),
                .s_axi_b_awsize    (s_axi_b_awsize [inst]),
                .s_axi_b_awburst   (s_axi_b_awburst[inst]),
                .s_axi_b_awlock    (s_axi_b_awlock [inst]),
                .s_axi_b_awcache   (s_axi_b_awcache[inst]),
                .s_axi_b_awprot    (s_axi_b_awprot [inst]),
                .s_axi_b_awvalid   (s_axi_b_awvalid[inst]),
                .s_axi_b_awready   (s_axi_b_awready[inst]),
                .s_axi_b_wdata     (s_axi_b_wdata  [inst]),
                .s_axi_b_wstrb     (s_axi_b_wstrb  [inst]),
                .s_axi_b_wlast     (s_axi_b_wlast  [inst]),
                .s_axi_b_wvalid    (s_axi_b_wvalid [inst]),
                .s_axi_b_wready    (s_axi_b_wready [inst]),
                .s_axi_b_bid       (s_axi_b_bid    [inst]),
                .s_axi_b_bresp     (s_axi_b_bresp  [inst]),
                .s_axi_b_bvalid    (s_axi_b_bvalid [inst]),
                .s_axi_b_bready    (s_axi_b_bready [inst])
            );
        end
    endgenerate
    
    elem_t a_values [NUM_CHANNELS][ELEMENTS_PER_ROW_PADDED];
    elem_t b_values [ELEMENTS_PER_ROW_PADDED];
    
    logic [NUM_CHANNELS-1:0] inputs_sent       = '{default:'0};
    logic [NUM_CHANNELS-1:0] inputs_sent_batch = '{default:'0};
    logic [NUM_CHANNELS-1:0] outputs_received  = '{default:'0};
    
    real expected [NUM_CHANNELS-1:0][ROWS_PER_CHANNEL-1:0];    
    
    logic [ADDR_WIDTH-1:0] base_addr, part_base, vec_base_offset, burst_offset;
    int unsigned num_full_bursts = AXI_RAM_WORDS_PER_PARTITION / MAX_BURST_LEN;
    int unsigned final_burst_len = AXI_RAM_WORDS_PER_PARTITION % MAX_BURST_LEN;

    // Initialization + start_transfer control
    int finished_transfer;
    initial begin
    
        // Reset
        rstn = 0;
        repeat (16) @(posedge clk); 
        rstn = 1;
        
        repeat (4) @(posedge clk);
        
        for (int i = 0; i < NUM_CHANNELS; i++) begin
            inputs_sent[i] = 0;
            outputs_received[i] = 0;
            m_axis_tready[i] = 1;
        end
    
        // Initialize a_values
        for (int i = 0; i < NUM_CHANNELS; i++) begin
            for (int j = 0; j < ELEMENTS_PER_ROW; j++) begin
                automatic real a_r = ((j+1.0) / ((i+1) * 100000.0));
                a_values[i][j] = real_to_elem(a_r);
                //$display("Channel %0d : a_values[%0d] = %h (real=%f)", i, j, a_values[i][j], elem_to_real(a_values[i][j]));
            end
            for (int j = ELEMENTS_PER_ROW; j < ELEMENTS_PER_ROW_PADDED; j++) begin
                a_values[i][j] = '0;
            end
        end
        
        // Initialize b_values
        for (int j = 0; j < ELEMENTS_PER_ROW; j++) begin
            automatic real b_r = ((j+1.0) / 10000.0);
            b_values[j] = real_to_elem(b_r);
            //$display("b_values[%0d] = %h (real=%f)", j, b_values[j], elem_to_real(b_values[j]));
        end
        for (int j = ELEMENTS_PER_ROW; j < ELEMENTS_PER_ROW_PADDED; j++) begin
            b_values[j] = '0;
        end
        
        // Initialize vector (group b_values)
        for (int w = 0; w < AXI_RAM_WORDS_PER_ROW; w++) begin
            vector[w] = '0;
            for (int j = 0; j < AXI_RAM_ELEMENTS_PER_WORD; j++) begin
                vector[w][j*ELEMENT_WIDTH +: ELEMENT_WIDTH] = b_values[w * AXI_RAM_ELEMENTS_PER_WORD + j];
                //$display("vector[%0d][%0d] = %h (real = %f)", 
                //         w, j, vector[w][j*ELEMENT_WIDTH +: ELEMENT_WIDTH], elem_to_real(b_values[w * AXI_RAM_ELEMENTS_PER_WORD + j]));
            end
        end
        
        // Write vector to BRAM
        for (int i = 0; i < NUM_ACCEL_INST; i++) begin
            base_addr = BASE_ADDR + STRIDE * i;
                      
            for (int j = 0; j < NUM_RAM_PARTITIONS; j++) begin
                part_base = base_addr + j * PARTITION_ALIGN;
                vec_base_offset = j * AXI_RAM_WORDS_PER_PARTITION;
                                
                for (int k = 0; k < num_full_bursts; k++) begin
                    automatic int unsigned word_off = k * MAX_BURST_LEN;
                    burst_offset = part_base + word_off * AXI_RAM_STRB_WIDTH;
                    axi_write_burst(
                        burst_offset,
                        MAX_BURST_LEN,
                        vec_base_offset + word_off,
                        i
                    );
                end
                
                if (final_burst_len > 0) begin
                    automatic int unsigned word_off = num_full_bursts * MAX_BURST_LEN;
                    burst_offset = part_base + word_off * AXI_RAM_STRB_WIDTH;
                    axi_write_burst(
                        burst_offset,
                        final_burst_len,
                        vec_base_offset + word_off,
                        i
                    );
                end
            end
        end
                
        $display("Initialization complete\n");
        start_transfer = 1;
        
        forever begin
            @(posedge clk);
            start_transfer = 0;
            wait(finished_transfer);
            repeat (1024) @(posedge clk);
            start_transfer = 1;
        end
    end
                
    // Parallel channel drivers
    generate
        for (genvar ch = 0; ch < NUM_CHANNELS; ch++) begin : channel_driver
            initial begin                
                for (int i = 0; i < NUM_TRANSFERS; i++) begin
                
                    wait(start_transfer);
                    
                    for (int b = 0; b < BATCHES_PER_TRANSFER; b++) begin
                        inputs_sent_batch[ch] = 0;
                    
                        // Stagger first input
                        repeat(OFFSET_CYCLES * input_order[ch]) @(posedge clk);

                        for (int j = 0; j < ROWS_PER_CHANNEL_PER_BATCH; j++) begin  
                        
                            automatic int row = b*ROWS_PER_CHANNEL_PER_BATCH + j;
                            expected[ch][row] = 0.0;
                            
                            // Send inputs
                            for (int word_idx = 0; word_idx < WORDS_PER_ROW_PADDED; word_idx++) begin
                            
                                // Random delays
                                //automatic bit rand_bool = ($urandom_range(0, 999) < 1); // 0.1% chance
                                //if (rand_bool) repeat(256) @(posedge clk);
                            
                                s_axis_a_tdata[ch] = '0;
                                for (int k = 0; k < ELEMENTS_PER_WORD; k++) begin
                                    automatic int abs_idx = word_idx * ELEMENTS_PER_WORD + k;
                                    automatic real a_r = elem_to_real(a_values[ch][abs_idx]);
                                    automatic real b_r = elem_to_real(b_values[abs_idx]);
                                    
                                    s_axis_a_tdata[ch][k*ELEMENT_WIDTH +: ELEMENT_WIDTH] = a_values[ch][abs_idx];
                                    expected[ch][row] += a_r * b_r;
                                end
                                
                                s_axis_a_tvalid[ch] = 1;
                                s_axis_a_tlast[ch]  = (word_idx == WORDS_PER_ROW_PADDED-1) 
                                                   && (j == ROWS_PER_CHANNEL_PER_BATCH-1);
        
                                do begin
                                    @(posedge clk);
                                end while (!(s_axis_a_tvalid[ch] && s_axis_a_tready[ch]));
                                
                                s_axis_a_tvalid[ch] = 0;
                                s_axis_a_tlast[ch]  = 0;
                            end
                            $display("%0d: Channel %0d: All inputs sent.", row, ch);
                        end
                        
                        // Batch synchronization barrier
                        inputs_sent_batch[ch] = 1;
                        wait(inputs_sent_batch == {NUM_CHANNELS{1'b1}});
                        @(posedge clk);
                        if (ch == 0 && b < BATCHES_PER_TRANSFER-1) 
                            $display("\nTransfer %0d: Batch %0d sent.\n", finished_count, b);
                    end
                    
                    inputs_sent[ch] = 1;
                end
            end
        end
    endgenerate
        
    // Capture outputs
    generate
        for (genvar ch = 0; ch < NUM_CHANNELS; ch++) begin : capture_output
            initial begin
                for (int i = 0; i < NUM_TRANSFERS; i++) begin
                    for (int j = 0; j < ROWS_PER_CHANNEL; j++) begin
                        @(posedge clk iff (m_axis_tvalid[ch] && m_axis_tready[ch]));
                        $display("%0d: Ch%0d: Result=%.16f | Expected=%.16f",
                            j, ch, $bitstoreal(m_axis_tdata[ch]), expected[ch][j]);
                    end
                    outputs_received[ch] = 1;
                end
            end
        end
    endgenerate
    
    // Finish once all outputs are received
    int finished_count = 0;
    initial begin
        wait(start_transfer);
    
        forever begin        
            automatic int check_finished = 1;
            for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                if (!inputs_sent[ch] || !outputs_received[ch])
                    check_finished = 0;
            end
            finished_transfer = check_finished;
            
            if (finished_transfer) begin
                $display("\nTransfer %0d: All outputs received.\n", finished_count);
                if (finished_count == NUM_TRANSFERS - 1) begin
                    break;
                end else begin
                    @(posedge clk);
                    finished_transfer = 0;
                    finished_count = finished_count + 1;
                    for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                        inputs_sent[ch] = 0;
                        outputs_received[ch] = 0;
                    end
                end
            end
            @(posedge clk);
        end
    
        repeat (10) @(posedge clk);
        
        $finish;
    end

endmodule
