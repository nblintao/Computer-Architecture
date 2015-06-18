module data_ram (
	input wire clk,
	input wire rst,
	input wire [31:0] addr,
	input wire ren,
	input wire wen,
	input wire [31:0] din,
	output reg [31:0] dout,
	output reg stall,
	output reg ack
	);
	
	parameter
		ADDR_WIDTH = 5,
		CLK_DELAY = 8;
	
	reg [31:0] data_mem [0:(1<<ADDR_WIDTH)-1];
	reg [CLK_DELAY-1:0] ren_buf = 0;
	reg [CLK_DELAY-1:0] ren_buf_next;
	reg [CLK_DELAY-1:0] wen_buf = 0;
	reg [CLK_DELAY-1:0] wen_buf_next;
	reg [31:0] addr_buf;
	
	initial	begin
		$readmemh("data_mem.hex", data_mem);
	end
	
	always @(posedge clk) begin
		if (rst)
			addr_buf <= 0;
		else
			addr_buf <= addr;
	end
	
	always @(*) begin
		if (rst || ~ren || wen || addr_buf != addr)
			ren_buf_next = 0;
		else
			ren_buf_next = {ren, ren_buf[CLK_DELAY-1:1]};
	end
	
	always @(negedge clk) begin
		if (rst)
			ren_buf <= 0;
		else
			ren_buf <= ren_buf_next;
	end
	
	always @(*) begin
		if (rst || ~wen || addr_buf != addr)
			wen_buf_next = 0;
		else
			wen_buf_next = {wen, wen_buf[CLK_DELAY-1:1]};
	end
	
	always @(negedge clk) begin
		if (rst)
			wen_buf <= 0;
		else
			wen_buf <= wen_buf_next;
	end
	
	always @(negedge clk) begin
		dout <= 0;
		ack <= 0;
		if (addr_buf[31:ADDR_WIDTH] == 0 && wen_buf_next[0]) begin
			data_mem[addr_buf[ADDR_WIDTH-1:0]] <= din;
			ack <= 1;
		end
		else if (addr_buf[31:ADDR_WIDTH] == 0 && ren_buf_next[0]) begin
			dout <= data_mem[addr_buf[ADDR_WIDTH-1:0]];
			ack <= 1;
		end
	end
	
	always @(*) begin
		stall = (ren | wen) & (~ack);
	end
	
endmodule
	