// --------------------------------------------------------------------------
//  cache.v  – 4 KiB direct-mapped *preload* mode
//  – first request to any line is passthrough + background fill
//  – byte/half/word supported on cpu port
// --------------------------------------------------------------------------
module cache (
  input             cpu_valid,      
  output reg        cpu_ready,      
  input      [31:0] cpu_addr,       
  input      [ 1:0] cpu_size,       
  output reg [31:0] cpu_rdata,      

  output reg        mem_valid,      
  input             mem_ready,      
  output reg [31:0] mem_addr,       
  output reg [ 1:0] mem_size,       
  input      [31:0] mem_rdata,      

  input             clk,         
  input             rst_n
);

    localparam AW      = 32;
    localparam DW      = 32;
    localparam LINE_W  = 6;               // 2~6 Byte per line
    localparam INDEX_W = 1;               // 2^1 lines 
    localparam TAG_W   = AW - INDEX_W - LINE_W;
    // -------------------- cache geometry ----------------------------------
    localparam LINE_BYTES  = 1 << LINE_W;      // 16
    localparam LINE_WORDS  = LINE_BYTES / 4;   // 4
    `ifdef XILINX
    localparam OFFSET_W    = 2;
    localparam BYTE_OFFSET_W = 4;
    `else
    localparam OFFSET_W    = $clog2(LINE_WORDS);
    localparam BYTE_OFFSET_W = $clog2(LINE_BYTES);
    `endif

    // -------------------- storage ------------------------------------------
    reg [TAG_W-1:0]  tag_array   [0:(1<<INDEX_W)-1];
    reg [DW-1:0]     data_array  [0:(1<<INDEX_W)*LINE_WORDS-1];
    reg              valid_array [0:(1<<INDEX_W)-1];

    // -------------------- address fields -----------------------------------
    wire [TAG_W-1:0]         cpu_tag    = cpu_addr[AW-1 : AW-TAG_W];
    wire [INDEX_W-1:0]       cpu_index  = cpu_addr[AW-TAG_W-1 : BYTE_OFFSET_W];
    wire [OFFSET_W-1:0]      word_in_line = cpu_addr[BYTE_OFFSET_W-1 : 2];
    wire [1:0]               byte_in_word = cpu_addr[1:0];

    wire hit = valid_array[cpu_index] & (tag_array[cpu_index]==cpu_tag);

    // -------------------- preload FSM ---------------------------------------
    localparam IDLE    = 2'd0,
                 FILL   = 2'd1;

    reg [1:0]                state, nxt_state;
    reg [OFFSET_W-1:0]       fill_cnt, nxt_fill_cnt;
    reg [INDEX_W-1:0]        fill_index;
    reg [TAG_W-1:0]          fill_tag;
    reg                      fill_active;

    // -------------------- sequential ---------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            fill_cnt  <= 0;
            fill_active<= 1'b0;
        end else begin
            state     <= nxt_state;
            fill_cnt  <= nxt_fill_cnt;
            fill_active<= (nxt_state==FILL);
        end
    end

    // -------------------- combinational ------------------------------------
    // word from cache
    reg [DW-1:0] wdata;
    always @* begin
        // defaults
        nxt_state   = state;
        nxt_fill_cnt= fill_cnt;
        mem_valid   = 1'b0;
        mem_addr    = 0;
        mem_size    = 2'b11;
        cpu_ready   = 1'b0;
        cpu_rdata   = 0;

        case (state)
        IDLE: begin
            if (cpu_valid) begin
                if (hit) begin
                    // normal hit – single cycle
                    cpu_ready = 1'b1;
                    wdata = data_array[{cpu_index, word_in_line}];
                    case (cpu_size)
                      2'b00:   cpu_rdata = {{24{wdata[byte_in_word*8+7]}}, wdata[byte_in_word*8 +: 8]};
                      2'b01:   cpu_rdata = {{16{wdata[byte_in_word*8+15]}}, wdata[byte_in_word*8 +: 16]};
                      default: cpu_rdata = wdata;
                    endcase
                end
                else begin
                    // miss – trigger background fill
                    fill_index  = cpu_index;
                    fill_tag    = cpu_tag;
                    nxt_fill_cnt= 0;
                    nxt_state   = FILL;
                    // passthrough this request
                    mem_valid   = 1'b1;
                    mem_addr    = {cpu_tag, cpu_index, word_in_line, 2'b00};
                    cpu_ready   = mem_ready;
                    cpu_rdata   = mem_rdata;  // direct feed
                end
            end
        end

        FILL: begin
            // continue background line fill
            mem_valid = 1'b1;
            mem_addr  = {fill_tag, fill_index, fill_cnt, 2'b00};
            if (mem_ready) begin
                data_array[{fill_index, fill_cnt}] <= mem_rdata;
                if (fill_cnt == LINE_WORDS-1) begin
                    // commit tag & valid
                    tag_array[fill_index]   <= fill_tag;
                    valid_array[fill_index] <= 1'b1;
                    nxt_state               = IDLE;
                end else
                    nxt_fill_cnt = fill_cnt + 1'b1;
            end
        end
        endcase
    end

endmodule
