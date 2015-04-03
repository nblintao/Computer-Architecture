`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:25:30 03/11/2014
// Design Name:   alu
// Module Name:   C:/Users/Student/Desktop/arch_frame/new_alu_test.v
// Project Name:  arch_frame
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

module new_alu_test;

	// Inputs
	reg [31:0] A;
	reg [31:0] B;
	reg [2:0] control;

	// Outputs
	wire [31:0] result;

	// Instantiate the Unit Under Test (UUT)
	alu uut (
		.A(A), 
		.B(B), 
		.control(control), 
		.result(result)
	);

	initial begin
		// Initialize Inputs
		A = 0;
		B = 0;
		control = 0;

		// Wait 100 ns for global reset to finish
		#100;
      A = 32'd123123;
		B = 32'd234234;
		control = 3'b000;	// add
		
		#100;
      A = 32'd123123;
		B = 32'd234234;
		control = 3'b001;	// sub
		
		#100;
      A = 32'h0101;
		B = 32'h1010;
		control = 3'b010;	// nor
		
		#100;
      A = 32'hABCD;
		B = 32'hEFAB;
		control = 3'b011;	// and
		
		#100;
      A = 32'd123123;
		B = 32'd322325;
		control = 3'b111;	// slt
		// Add stimulus here

	end
      
endmodule

