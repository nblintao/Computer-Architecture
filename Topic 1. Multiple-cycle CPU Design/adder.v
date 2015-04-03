`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:41:46 03/23/2015 
// Design Name: 
// Module Name:    adder 
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
module adder(input clk, output reg [3:0] address 
    );
	 initial begin
		address = 4'b0;
	 end
	 
	 always@(posedge clk)
	 begin
	   if (address < 4'b1111)
		  begin
		    address <= address + 1;
		  end
		else
		  begin
		    address <= 4'b0;
		  end
	 end

endmodule

