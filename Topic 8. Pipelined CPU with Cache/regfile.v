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
	input wire [31:0] data_w,
	input wire btn_reset
	);
	
	reg [31:0] regfile [1:31];  // $zero is always zero
	
	// write
	always @(posedge clk) begin
		if (en_w && addr_w != 0)
			regfile[addr_w] <= data_w;
		if (btn_reset) begin
			regfile[1] <= 32'b0;
			regfile[2] <= 32'b0;
			regfile[3] <= 32'b0;
			regfile[4] <= 32'b0;
			regfile[5] <= 32'b0;
			regfile[6] <= 32'b0;
			regfile[7] <= 32'b0;
			regfile[8] <= 32'b0;
			regfile[9] <= 32'b0;
			regfile[10] <= 32'b0;
			regfile[11] <= 32'b0;
			regfile[12] <= 32'b0;
			regfile[13] <= 32'b0;
			regfile[14] <= 32'b0;
			regfile[15] <= 32'b0;
			regfile[16] <= 32'b0;
			regfile[17] <= 32'b0;
			regfile[18] <= 32'b0;
			regfile[19] <= 32'b0;
			regfile[20] <= 32'b0;
			regfile[21] <= 32'b0;
			regfile[22] <= 32'b0;
			regfile[23] <= 32'b0;
			regfile[24] <= 32'b0;
			regfile[25] <= 32'b0;
			regfile[26] <= 32'b0;
			regfile[27] <= 32'b0;
			regfile[28] <= 32'b0;
			regfile[29] <= 32'b0;
			regfile[30] <= 32'b0;
			regfile[31] <= 32'b0;
		end
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
