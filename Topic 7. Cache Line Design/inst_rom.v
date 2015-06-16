module inst_rom (
	input wire clk,
	input wire rst,
	input wire [31:0] addr,
	input wire ren,
	output reg [31:0] inst,
	output reg stall,
	output reg ack
	);
	
	parameter
		ADDR_WIDTH = 6,
		CLK_DELAY = 8;
	
	reg [31:0] inst_mem [0:(1<<ADDR_WIDTH)-1];
	reg [CLK_DELAY-1:0] ren_buf = 0;
	reg [CLK_DELAY-1:0] ren_buf_next;
	reg [31:0] addr_buf;
	
	initial	begin
		$readmemh("inst_mem.hex", inst_mem);
	end
	
	always @(posedge clk) begin
		if (rst)
			addr_buf <= 8'h00000000;
		else if (addr_buf != addr)
			addr_buf <= addr;
	end
	
	always @(*) begin
		if (rst || ~ren || addr_buf != addr)begin
			//addr_buf <= addr;
			ren_buf_next = 0;
		end
		else
			ren_buf_next = {ren, ren_buf[CLK_DELAY-1:1]};
	end

	always @(negedge clk) begin
		if (rst)
			ren_buf <= 0;
		else
			ren_buf <= ren_buf_next;
	end
	
	always @(negedge clk) begin
		inst <= 0;
		ack <= 0;
		if (addr[31:ADDR_WIDTH] == 0 && ren_buf_next[0]) 
		begin 
			inst <= inst_mem[addr[ADDR_WIDTH-1:0]];
			ack <= 1;
		end
	end
	
	always @(*) begin
		stall = (ren) & (~ack);
	end
		
endmodule
