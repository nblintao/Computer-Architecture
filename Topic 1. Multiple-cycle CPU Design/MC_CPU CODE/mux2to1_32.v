
`timescale 1ns / 1ps

module mux2to1_32(
	a,
	b,
	o,
	sel
    );
	input wire [31:0] a,b;
	input wire sel;
	output wire [31:0] o;

	assign o = sel ? a : b ;
endmodule
