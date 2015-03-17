`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    19:50:06 02/27/2014
// Design Name:
// Module Name:    BTN_Anti_jitter
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

module BTN_Anti_jitter(
	input wire clk,
	input wire [ 4: 0] button,
	input wire [ 7: 0] SW,
	output reg [ 4: 0] button_out,
	output reg [ 7: 0] SW_OK
	);

	reg [31:0] counter;

	always @(posedge clk) begin
		if(counter > 0) begin
			if(counter < 100000)
				counter <= counter + 1;
			else begin
				counter <= 32'b0;
				button_out <= button;
				SW_OK <= SW;
			end
		end
		else if(button > 0 || SW > 0)
			counter <= counter + 1;
	end
endmodule
