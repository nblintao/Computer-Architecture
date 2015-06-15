module inst_rom (
	input wire clk,
	input wire [31:0] addr,
	output reg [31:0] inst
	);
	
	parameter
		ADDR_WIDTH = 6;
	
	reg [31:0] inst_mem [0:(1<<ADDR_WIDTH)-1];
	
	initial	begin
		$readmemh("inst_mem.hex", inst_mem);
	end
	
	always @(negedge clk) begin
		if (addr[31:ADDR_WIDTH] != 0)
			inst <= 32'h0;
		else
			inst <= inst_mem[addr[ADDR_WIDTH-1:0]];
	end
	
endmodule
