module data_ram (
	input wire clk,
	input wire [31:0] addr,
	input wire we,
	input wire [31:0] din,
	output reg [31:0] dout
	);
	
	parameter
		ADDR_WIDTH = 5;
	
	reg [31:0] data_mem [0:(1<<ADDR_WIDTH)-1];
	
	initial	begin
		$readmemh("data_mem.hex", data_mem);
	end
	
	always @(negedge clk) begin
		if (we && addr[31:ADDR_WIDTH]==0)
			data_mem[addr[ADDR_WIDTH-1:0]] <= din;
	end
	
	always @(negedge clk) begin
		if (addr[31:ADDR_WIDTH] != 0)
			dout <= 32'h0;
		else
			dout <= data_mem[addr[ADDR_WIDTH-1:0]];
	end
	
endmodule
