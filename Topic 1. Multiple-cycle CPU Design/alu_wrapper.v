//alu
module alu_wrapper(rin_A, rin_B, ir_data, pc, alu_srcA, alu_srcB, alu_ctrl, zero, res);
				 
	input [31:0] rin_A;
	input [31:0] rin_B;
	input [31:0] ir_data;
	input [31:0] pc;
	input        alu_srcA;
	input [1:0]  alu_srcB;
	input [1:0]	 alu_ctrl;
	output		 zero;
	output[31:0] res;

	wire [31:0]	 rin_A;
	wire [31:0]	 rin_B;
	wire [31:0]	 ir_data;
	wire [31:0]  pc;
	wire 			 alu_srcA;
	wire [1:0]   alu_srcB;
	wire [1:0]	 alu_ctrl;
	wire [31:0]	 res;
	wire [31:0]  in_A;
	wire [31:0]	 in_B;
	wire [31:0]  signimm;
	wire [31:0]  shiftimm;
	wire         zero;
	
	assign signimm = (ir_data[15] == 1'b0) ? {16'h0000, ir_data[15:0]} : {16'hFFFF, ir_data[15:0]};
	assign shiftimm = signimm;
	
	assign in_A = (alu_srcA == 1'b1)? rin_A : pc; 
	//assign in_A = pc; 
	assign in_B = (alu_srcB == 2'b00)? rin_B : ((alu_srcB == 2'b01)? 32'h00000001 : ((alu_srcB == 2'b10)? signimm: shiftimm));
	assign zero = (res == 32'h00000000)? 1 : 0;

	alu x_alu(in_A, in_B, alu_ctrl, res);

endmodule

module alu(
input wire [31:0] A,
input wire [31:0] B,
input wire [2:0] control,
output reg [31:0] result
    );
	
always @ * begin
	case (control)
		3'b000: result = A + B;
		3'b001: result = A - B;
		3'b010: result = ~(A | B);
		3'b011: result = A & B;
		3'b110: result=A-B;
		3'b111: result=A<B?1:0;
		default: result=~(A|B);
	endcase
end

endmodule