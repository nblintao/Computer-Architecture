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
`include "define.vh"
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
	output wire jump_en, // force jump enable signal when interrupt authorised or ERET occurred
	output reg [31:0] jump_addr // target instruction address to jump to
	);
	`include "mips_define.vh"
	// interrupt determination
	wire ir;
	reg ir_wait = 0, ir_valid = 1;
	reg eret = 0;
	reg [31:0] EHBR;
	reg [31:0] EPCR;
	reg [31:0] TCR;
	reg eret_prv;
	initial begin
		EHBR = 0;
		EPCR = 0;
		TCR = 0;
	end
	always @(posedge clk) begin
		if (rst)
			ir_wait <= 0;
		else if (ir_in)
			ir_wait <= 1;
		else if (eret && ~eret_prv)
			ir_wait <= 0;
	end
	always @(posedge clk) begin
		if (rst)
			ir_valid <= 1;
		else if (eret && ~eret_prv)
			ir_valid <= 1;
		else if (ir)
			ir_valid <= 0; // prevent exception reenter
	end
	assign ir = ir_en & ir_wait & ir_valid;
	
	assign jump_en = ir||(eret && ~eret_prv); 
	always @(posedge clk) begin
			eret_prv <= eret;	
	end
	
	
	always @(*) begin
		eret <= 0;
		jump_addr <= 0;
		if(ir)begin
			jump_addr <= EHBR;
		end
		else begin
			case(oper)
				EXE_CP_NONE: begin	//MFC0
					case(addr_r)
						CP0_EPCR: data_r <= EPCR;
						CP0_EHBR: data_r <= EHBR;
						CP0_TCR: data_r <= TCR;
						default: data_r <= 0;
					endcase
				end				
				/*EXE_CP_STORE: begin	//MTC0
					case(addr_w)
						CP0_EPCR: EPCR <= data_w;
						CP0_EHBR: EHBR <= data_w;
						default: ;
					endcase
				end*/
				EXE_CP0_ERET: begin	//ERET
					eret <= 1;
					jump_addr <= EPCR;
				end
				default:;
			endcase
		end
	end
	
	always @(posedge clk) begin
		TCR <= TCR + 1;
		if(ir)begin
			EPCR <= ret_addr;
		end
		else begin
			case(oper)
				EXE_CP_STORE: begin	//MTC0
					case(addr_w)
						CP0_EPCR: EPCR <= data_w;
						CP0_EHBR: EHBR <= data_w;
						CP0_TCR: TCR <= data_w;
						default: ;
					endcase
				end
			endcase
		end
	end


endmodule
