`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:04:34 05/26/2015 
// Design Name: 
// Module Name:    cp0 
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
module cp0(
	input wire clk, // main clock
	// debug
	`ifdef DEBUG
	input wire [4:0] debug_addr, // debug address
	output reg [31:0] debug_data, // debug data
	`endif
	// operations (read in ID stage and write in EXE stage)
	input wire [1:0] oper, // CP0 operation type
	input wire [4:0] addr_r, // read address
	output reg [31:0] data_r, // read data
	input wire [4:0] addr_w, // write address
	input wire [31:0] data_w, // write data
	// control signal
	input wire rst, // synchronous reset
	input wire ir_en, // interrupt enable
	input wire ir_in, // external interrupt input
	input wire [31:0] ret_addr, // target instruction address to store when interrupt occurred
	output reg jump_en, // force jump enable signal when interrupt authorised or ERET occurred
	output reg [31:0] jump_addr // target instruction address to jump to
	);
	// interrupt determination
	wire ir;
	reg ir_wait = 0, ir_valid = 1;
	reg eret = 0;
	reg [31:0] EHBR;
	reg [31:0] EPCR;
	always @(posedge clk) begin
		if (rst)
			ir_wait <= 0;
		else if (ir_in)
			ir_wait <= 1;
		else if (eret)
			ir_wait <= 0;
	end
	always @(posedge clk) begin
		if (rst)
			ir_valid <= 1;
		else if (eret)
			ir_valid <= 1;
		else if (ir)
			ir_valid <= 0; // prevent exception reenter
	end
	assign ir = ir_en & ir_wait & ir_valid;
	
	always @(posedge clk) begin
		jump_en = 0;
		if (ir||eret)
			jump_en = 1;	
	end
	
	always @(posedge clk) begin
		if(ir)
			EPCR = ret_addr;
			jump_addr = EHBR;
	end	
	
	always @(posedge clk) begin
		case(oper)
			EXE_CP_MFC0: begin	//MFC0
				case(addr_r)
					5'b00010: data_r = EPCR;
					5'b00011: data_r = EHBR;
					default: data_r = 0;
				endcase
			end				
			EXE_CP_MTC0: begin	//MTC0
				case(addr_w)
					5'b00010: EPCR = data_w;
					5'b00011: EHBR = data_w;
					default: ;
				endcase
			end
			EXE_CP0_ERET: begin	//ERET
				eret = 1;
				jump_addr = EPCR;
			end
			default:;
		endcase
	end

endmodule
