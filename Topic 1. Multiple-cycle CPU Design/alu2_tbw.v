`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:08:00 03/22/2015
// Design Name:   alu
// Module Name:   E:/3130000011_multi_cpu/mcpu/alu2_tbw.v
// Project Name:  mcpu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: alu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module alu2_tbw;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] ALU_operation;

	// Outputs
	wire [31:0] res;
	wire zero;
	wire overflow;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.ALU_operation(ALU_operation), 
		.res(res), 
		.zero(zero), 
		.overflow(overflow)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		ALU_operation = 0;

		// Wait 100 ns for global reset to finish
		#10;
        
		// Add stimulus here
		A = 31;
		B = 8;
		ALU_operation = 1;
		#10;
		ALU_operation = 2;
		#10;
		ALU_operation = 3;
		#10;
		ALU_operation = 4;
		#10;
		ALU_operation = 5;
		#10;
		ALU_operation = 6;
		#10;
		ALU_operation = 7;
		#10;
	end
      
endmodule

