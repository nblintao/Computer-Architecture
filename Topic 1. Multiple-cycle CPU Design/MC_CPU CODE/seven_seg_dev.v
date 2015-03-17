`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date:    19:38:40 02/27/2014
// Design Name:
// Module Name:    seven_seg_dev
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

module seven_seg_dev (
	input wire	clk,
	input wire [31:0] disp_num, // 32binary or grid
	input wire clr,
	input wire [1:0] SW,
	input wire [1:0] Scanning, // from clk_div
	output wire [7:0] SEGMENT,
	output reg [3:0] AN
	);
	reg [3:0] digit;
	reg [7:0] temp_seg, digit_seg;
	wire [15:0] disp_current;

	assign SEGMENT = SW[0] ? digit_seg : temp_seg; 	// 0£ºpicture£¬1:hex_number
	assign disp_current = SW[1] ? disp_num[31:16] : disp_num[15:0];

	always @(*) begin  // decode
		AN = 4'b1111;
		case (Scanning)
			0: begin
				digit = disp_current[3:0]; // D3:D0 or D19:D16
				temp_seg = {disp_num[24], disp_num[12], disp_num[5], disp_num[17], disp_num[25], disp_num[16], disp_num[4], disp_num[0]};
				AN = 4'b1110;
			end
			1: begin
				digit = disp_current[7:4]; // D7:D4 or D23:D20
				temp_seg = {disp_num[26], disp_num[13], disp_num[7], disp_num[19], disp_num[27], disp_num[18], disp_num[6], disp_num[1]};
				AN = 4'b1101;
			end
			2: begin
				digit = disp_current[11:8]; // D11:D8 or D27:D24
				temp_seg = {disp_num[28], disp_num[14], disp_num[9], disp_num[21], disp_num[29], disp_num[20], disp_num[8], disp_num[2]};
				AN = 4'b1011;
			end
			3: begin
				digit = disp_current[15:12]; // D15:D12 or D31:D28
				temp_seg = {disp_num[30], disp_num[15], disp_num[11], disp_num[23], disp_num[31], disp_num[22], disp_num[10], disp_num[3]};
				AN = 4'b0111;
			end
		endcase
	end

	always @(*) begin
		case (digit)
			4'h0: digit_seg = 8'b11000000;
			4'h1: digit_seg = 8'b11111001;
			4'h2: digit_seg = 8'b10100100;
			4'h3: digit_seg = 8'b10110000;
			4'h4: digit_seg = 8'b10011001;
			4'h5: digit_seg = 8'b10010010;
			4'h6: digit_seg = 8'b10000010;
			4'h7: digit_seg = 8'b11111000;
			4'h8: digit_seg = 8'b10000000;
			4'h9: digit_seg = 8'b10010000;
			4'hA: digit_seg = 8'b10001000;
			4'hB: digit_seg = 8'b10000011;
			4'hC: digit_seg = 8'b11000110;
			4'hD: digit_seg = 8'b10100001;
			4'hE: digit_seg = 8'b10000110;
			4'hF: digit_seg = 8'b10001110;
		endcase
	end
endmodule
