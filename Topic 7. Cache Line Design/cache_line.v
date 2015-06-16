`timescale 1ns / 1ps
`include "mips_define.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:22:47 06/15/2015 
// Design Name: 
// Module Name:    cache_line 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module cache_line(
	input wire clk,
	input wire rst,
	input wire [31:0] addr,
	input wire load,
	input wire edit,
	input wire invalid,
	input wire [31:0] din,
	output reg hit,
	output reg [31:0] dout,
	output reg valid,
	output reg dirty,
	output reg [21:0] tag
);
	reg [LINE_NUM-1:0] inner_valid = 0;
	reg [LINE_NUM-1:0] inner_dirty = 0;
	reg [LINE_NUM-1:0] inner_tag [0:LINE_NUM-1];
	reg [WORD_BITS-1:0] inner_data [0:LINE_NUM*LINE_WORDS-1];

	always @(posedge clk) begin
		dout <= inner_data[addr[ADDR_BITS-TAG_BITS-1:WORD_BYTES_WIDTH]];
		if (edit&hit || load)
			inner_data[addr[ADDR_BITS-TAG_BITS-1:WORD_BYTES_WIDTH]] = din;
		
		if (invalid) begin
			inner_valid[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = 0;
			inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = 0;
		end
		
		if (load) begin
			inner_valid[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = 1;
			inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = 0;
			inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = addr[ADDR_BITS-1:ADDR_BITS-TAG_BITS];	
		end
		
		if (edit) begin
			inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = 1;
			inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] = addr[ADDR_BITS-1:ADDR_BITS-TAG_BITS];
		end

		valid = inner_valid[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]];
		dirty = inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]];
		tag = inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]];
		hit = valid & tag==addr[ADDR_BITS-1:ADDR_BITS-TAG_BITS];
	end
	
endmodule
