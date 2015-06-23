`timescale 1ns / 1ps

module cache_tbw;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] addr;
	reg load;
	reg edit;
	reg invalid;
	reg [31:0] din;

	// Outputs
	wire hit;
	wire [31:0] dout;
	wire valid;
	wire dirty;
	wire [21:0] tag;

	// Instantiate the Unit Under Test (UUT)
	cache_line uut (
		.clk(clk), 
		.rst(rst), 
		.addr(addr), 
		.load(load), 
		.edit(edit), 
		.invalid(invalid), 
		.din(din), 
		.hit(hit), 
		.dout(dout), 
		.valid(valid), 
		.dirty(dirty), 
		.tag(tag)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		addr = 0;
		load = 0;
		edit = 0;
		invalid = 0;
		din = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		#210 load = 1; din = 32'h11111111; addr = 32'h00000000;
		#20 addr = 32'h00000004;
		#20 addr = 32'h000000A8;
		#20 addr = 32'h0000001C;
		#20 load = 0; addr = 32'h000000B4; din = 0;
		#100 edit = 1; din = 32'h22222222; addr = 32'h00000008;
		#100 edit = 0; din = 0; addr = 0;
	end
	
	initial forever #10 clk = ~clk;
      
endmodule

