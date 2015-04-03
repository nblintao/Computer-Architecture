`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:34:11 03/11/2014
// Design Name:   ctrl
// Module Name:   C:/Users/Student/Desktop/arch_frame/ctrl_test.v
// Project Name:  arch_frame
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ctrl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ctrl_test;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] ir_data;
	reg zero;

	// Outputs
	wire write_pc;
	wire iord;
	wire write_mem;
	wire write_dr;
	wire write_ir;
	wire memtoreg;
	wire regdst;
	wire [1:0] pcsource;
	wire write_c;
	wire [1:0] alu_ctrl;
	wire alu_srcA;
	wire [1:0] alu_srcB;
	wire write_a;
	wire write_b;
	wire write_reg;
	wire [3:0] state;
	wire [3:0] insn_type;
	wire [3:0] insn_code;
	wire [2:0] insn_stage;

	// Instantiate the Unit Under Test (UUT)
	ctrl uut (
		.clk(clk), 
		.rst(rst), 
		.ir_data(ir_data), 
		.zero(zero), 
		.write_pc(write_pc), 
		.iord(iord), 
		.write_mem(write_mem), 
		.write_dr(write_dr), 
		.write_ir(write_ir), 
		.memtoreg(memtoreg), 
		.regdst(regdst), 
		.pcsource(pcsource), 
		.write_c(write_c), 
		.alu_ctrl(alu_ctrl), 
		.alu_srcA(alu_srcA), 
		.alu_srcB(alu_srcB), 
		.write_a(write_a), 
		.write_b(write_b), 
		.write_reg(write_reg), 
		.state(state), 
		.insn_type(insn_type), 
		.insn_code(insn_code), 
		.insn_stage(insn_stage)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		ir_data = 0;
		zero = 0;

		// Wait 100 ns for global reset to finish
      ir_data = 32'h8C010014;  
		
		#450;
      ir_data = 32'h8C020015;
		
		#450;
      ir_data = 32'h00221820;
		
		#350;
      ir_data = 32'h00222022;
		
		#350;
      ir_data = 32'h00642824;
		
		#350;
      ir_data = 32'h00853027;
		
		#350;
      ir_data = 32'hAC060016;
		
		#350;
      ir_data = 32'h08000000;
		// Add stimulus here

	end
	
	always #50 clk = ~clk;
      
endmodule

