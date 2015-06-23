module cmu(
input wire clk,
input wire rst,
input wire [31:0] addr_rw,
input wire en_r,
output wire [31:0] data_r,
input wire en_w,
input wire [31:0] data_w,
output reg stall,
output reg mem_cs_o,
output reg mem_we_o,
output reg [31:0] mem_addr_o,
input wire [31:0] mem_data_i,
output reg [31:0] mem_data_o,
input wire mem_ack_i
	// input wire [31:0] mem_data_syn,
	// input wire []
	// output reg [31:0] data_r,
	// output reg busy,
	// output reg [31:0] mem_addr_o
	);
`include "mips_define.vh"
	
wire [31:0] mem_data_syn;
// wire busy;
assign mem_data_syn = mem_data_i;
assign mem_ack_syn = mem_ack_i;
// assign stall = busy;

// assign stall = (state != S_IDLE)?1:0;


reg [31:0] cache_addr;
reg cache_edit;
reg [31:0] cache_din;
reg cache_store;
wire [31:0] cache_dout;

initial begin
    cache_edit = 0;
end

cache_line CACHELINE(
.clk(clk),
.rst(rst),
.addr(cache_addr), // [31:0] 
.load(cache_store),
.edit(cache_edit),
.invalid(1'b0),
.din(cache_din), // [31:0] 

.hit(cache_hit),
.dout(cache_dout), // [31:0] 
.valid(cache_valid),
.dirty(cache_dirty),
.tag(cache_tag) // [21:0] 
);

reg [2:0] state;
reg [2:0] next_state;
reg [LINE_WORDS_WIDTH-1:0] word_count;
reg [LINE_WORDS_WIDTH-1:0] next_word_count;
reg [LINE_WORDS_WIDTH-1:0] word_count_buf;
reg mem_ack_i_pre;
wire mem_ack_i_real;
assign data_r = {32{((state==S_IDLE)&cache_hit)}}&cache_dout;
initial state = S_IDLE;
always @(*)begin
	// if(state!=S_IDLE)
	if(!cache_hit || (state !=S_IDLE))
		stall = 1;
	else
		stall = 0;
end
always@(posedge clk)begin
	word_count_buf <= word_count;
	mem_ack_i_pre <= mem_ack_i;
end
assign mem_ack_i_real = (~mem_ack_i_pre) & mem_ack_i;
always @(posedge clk) begin
	case(state)
	S_IDLE: begin
		if (en_r || en_w) begin
			if (cache_hit)
				next_state = S_IDLE;
			else if (cache_valid && cache_dirty) next_state = S_BACK;
			else next_state = S_FILL;
		end 
	end	

	S_BACK: begin
		if (mem_ack_i_real)
			next_word_count = word_count + 1'h1;
		else 
			next_word_count = word_count;

		if (mem_ack_i_real && word_count == {LINE_WORDS_WIDTH{1'b1}})
			next_state = S_BACK_WAIT;
		else
			next_state = S_BACK;
	end	

	S_BACK_WAIT: begin 
		next_word_count = 0;
		next_state = S_FILL; 
	end	

	S_FILL: begin
		if (mem_ack_i_real)
			next_word_count = word_count + 1'h1; 
		else
			next_word_count = word_count;
		if (mem_ack_i_real && word_count == {LINE_WORDS_WIDTH{1'b1}})
			next_state = S_FILL_WAIT; 
		else
			next_state = S_FILL;
	end	

	S_FILL_WAIT: begin
		next_word_count = 0;
		next_state = S_IDLE; 
	end
	endcase
	if (rst) begin
		state <= 0;
		word_count <= 0;
		next_word_count = 0;//
	end
	else begin
		state <= next_state;
		word_count <= next_word_count; 
	end
end



always @(*) begin
	case (next_state) 
		S_IDLE: begin
			cache_addr = addr_rw; 
			cache_edit = en_w; 
			cache_din = data_w;
		end
		S_BACK, S_BACK_WAIT: begin
			cache_addr = {addr_rw[31:LINE_WORDS_WIDTH+2], next_word_count, 2'b00};
		end
		S_FILL, S_FILL_WAIT: begin
			// cache_addr = {addr_rw[31:LINE_WORDS_WIDTH+2], next_word_count, 2'b00};
			cache_addr = {addr_rw[31:LINE_WORDS_WIDTH+2], word_count_buf, 2'b00};
			cache_din = mem_data_syn; 
			cache_store = mem_ack_syn;
		end 
	endcase	

	case (next_state)
		S_IDLE, S_BACK_WAIT, S_FILL_WAIT: begin
			mem_cs_o <= 0; 
			mem_we_o <= 0; 
			mem_addr_o <= 0;
		end
		S_BACK: begin
			mem_cs_o <= 1;
			mem_we_o <= 1;
			mem_addr_o <= {cache_tag, addr_rw[31-TAG_BITS:LINE_WORDS_WIDTH+2], next_word_count, 2'b00}; 
		end
		S_FILL: begin
			mem_cs_o <= 1;
			mem_we_o <= 0;
			mem_addr_o <= {addr_rw[31:LINE_WORDS_WIDTH+2], word_count_buf, 2'b00};
	end 
endcase
end

endmodule
