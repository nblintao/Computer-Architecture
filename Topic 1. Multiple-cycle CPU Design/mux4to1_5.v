`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:40:35 05/16/2014 
// Design Name: 
// Module Name:    mux4to1_5 
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
module mux4to1_5(
	a,
	b,
	c,
	d,
	sel,
	o
    );
	input [ 4: 0] a,b,c,d;
	input [ 1: 0] sel;
	output [ 4: 0] o; 
	
	 assign o = ( sel == 2'b00)? a: ( sel == 2'b01 )? b: ( sel == 2'b10 )? c: ( sel == 2'b11 )? d : 0;

endmodule
