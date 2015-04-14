`include "define.vh"

/**
 * Register File for MIPS CPU.
 * Author: Zhao, Hongyu, Zhejiang University
 */

module regfile (
	input wire clk,  // main clock
	// debug
	`ifdef DEBUG
	input wire [4:0] debug_addr,  // debug address
	output reg [31:0] debug_data,  // debug data
	`endif
	// read channel A
	input wire [4:0] addr_a,
	output reg [31:0] data_a,
	// read channel B
	input wire [4:0] addr_b,
	output reg [31:0] data_b,
	// write channel W
	input wire en_w,
	input wire [4:0] addr_w,
	input wire [31:0] data_w
	);
	
	reg [31:0] regfile [1:31];  // $zero is always zero
	
	// write
	always @(posedge clk) begin
		if (en_w && addr_w != 0)
			regfile[addr_w] <= data_w;
	end
	
	// read
	always @(negedge clk) begin
		data_a <= addr_a == 0 ? 0 : regfile[addr_a];
		data_b <= addr_b == 0 ? 0 : regfile[addr_b];
	end
	
	// debug
	`ifdef DEBUG
	always @(negedge clk) begin
		debug_data <= debug_addr == 0 ? 0 : regfile[debug_addr];
	end
	`endif
	
	/*
	// write
	always @(negedge clk) begin
		if (en_w && addr_w != 0)
			regfile[addr_w] <= data_w;
	end
	
	wire [31:0] da, db;
	assign
		da = regfile[addr_a],
		db = regfile[addr_b];
	
	// read
	always @(*) begin
		data_a = addr_a == 0 ? 0 : da;
		data_b = addr_b == 0 ? 0 : db;
	end
	
	// debug
	`ifdef DEBUG
	wire [31:0] dd;
	assign
		dd = regfile[debug_addr];
	
	always @(*) begin
		debug_data = debug_addr == 0 ? 0 : dd;
	end
	`endif
	*/
	
endmodule
