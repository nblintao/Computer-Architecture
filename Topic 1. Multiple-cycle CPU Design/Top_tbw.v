`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:45:23 03/23/2015
// Design Name:   Top_Muliti_IOBUS
// Module Name:   E:/3130000011_multi_cpu/mcpu/Top_tbw.v
// Project Name:  mcpu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top_Muliti_IOBUS
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_tbw;

	// Inputs
	reg clk_50mhz;
	reg [4:0] BTN;
	reg [7:0] SW;

	// Outputs
	wire [7:0] LED;
	wire [7:0] SEGMENT;
	wire [3:0] AN_SEL;
	wire LCDRS;
	wire LCDRW;
	wire LCDE;
	wire [3:0] LCDDAT;

	// Instantiate the Unit Under Test (UUT)
	Top_Muliti_IOBUS uut (
		.clk_50mhz(clk_50mhz), 
		.BTN(BTN), 
		.SW(SW), 
		.LED(LED), 
		.SEGMENT(SEGMENT), 
		.AN_SEL(AN_SEL), 
		.LCDRS(LCDRS), 
		.LCDRW(LCDRW), 
		.LCDE(LCDE), 
		.LCDDAT(LCDDAT)
	);

	initial begin
		// Initialize Inputs
		clk_50mhz = 0;
		BTN = 0;
		SW = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		clk_50mhz = 1;
	end
	      
endmodule

