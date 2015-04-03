//Controller
module ctrl(clk, rst, ir_data, zero,
	write_pc, iord, write_mem, write_dr, write_ir, memtoreg, regdst, 
	pcsource, write_c, alu_ctrl, alu_srcA, alu_srcB, write_a, write_b, write_reg,
	state, insn_type, insn_code, insn_stage);  

	parameter IF = 4'b0000, ID = 4'b0001, EX_R = 4'b0010, 
		EX_LD = 4'b0011, EX_ST = 4'b0100, MEM_RD = 4'b0101, 
		MEM_ST = 4'b0111, WB_R = 4'b1000, WB_LS = 4'b1001, 
		EX_BEQ = 4'b1010, EX_J = 4'b1011, BR_BEQ = 4'b1100,
		OTHER = 4'b1111;
	
	parameter ADD = 2'b00, SUB = 2'b01, AND = 2'b11, NOR = 2'b10;     						
	parameter LED_IF = 4'b0001, LED_ID = 4'b0010, LED_EX = 4'b0011,
		LED_MEM =4'b0100, LED_WB = 4'b0101;    					
				 
	parameter LED_R = 4'b0001, LED_J = 4'b0010, LED_I = 4'b0011, LED_N = 4'b0000;   		
	parameter LED_LD = 4'b0001, LED_ST = 4'b0010, LED_AD = 4'b0011,
		LED_SU = 4'b0100, LED_AN = 4'b0101, LED_NO = 4'b0110,
		LED_JP = 4'b0111, LED_NI = 4'b0000;  									
	
	parameter STAGE_IF = 3'b000, STAGE_ID = 3'b001, STAGE_EXE = 3'b010,
		STAGE_WB = 3'b100, STAGE_MEM = 3'b011;
	
		// input signals
	input        clk;
	input        rst;
	input [31:0] ir_data;
	input        zero;

	output		  write_pc;
	output        iord;
	output		  write_mem;
	output        write_dr;
	output        write_ir;
	output		  memtoreg;
	output        regdst;
	output [1:0]  pcsource;
	output        write_c;
	output [1:0]  alu_ctrl;
	output		  alu_srcA;
	output [1:0]  alu_srcB;
	output        write_a;
	output        write_b;
	output        write_reg;
	output [3:0]  state;
	output [3:0]  insn_type;
	output [3:0]  insn_code;
	output [2:0]  insn_stage;
	
	reg [3:0]  state;
	reg [3:0]  insn_type;
	reg [3:0]  insn_code;
	reg [2:0]  insn_stage;
	reg		  write_pc;
	reg        iord;
	reg		  write_mem;
	reg        write_dr;
	reg        write_ir;
	reg		  memtoreg;
	reg        regdst;
	reg [1:0]  pcsource;
	reg        write_c;
	reg [1:0]  alu_ctrl;
	reg		  alu_srcA;
	reg [1:0]  alu_srcB;
	reg        write_a;
	reg        write_b;
	reg        write_reg;		  
	
	initial begin
		//state <= OTHER;
		state <= IF;
		
		write_pc <= 1'b0;
		write_mem <= 1'b0;
		write_dr <= 1'b0;
		write_ir <= 1'b0;
		memtoreg <= 1'b0;
		regdst <= 1'b0;
		pcsource <= 2'b00;
		write_c <= 1'b0;
		alu_ctrl <= 2'b00;
		alu_srcA <= 1'b0;
		alu_srcB <= 2'b01;
		write_a <= 1'b0;
		write_b <= 1'b0;
		write_reg <= 1'b0;
	end
	
	always @ (posedge clk or posedge rst)
	begin	
		if (rst == 1)
		begin
			//state <=;  
			//insn_stage <=;
		end
		else 
	   case (state)
			IF: 
			begin
				write_reg <= 1'b0;
				write_mem <= 1'b0;
				
				write_pc <= 1'b1;
				write_ir <= 1'b1;
				pcsource <= 2'b00;
				
				state <= ID;
				insn_stage <= 3'b0;
			end
			
			ID:
			begin
				// write_pc <= 1'b0;
				write_ir <= 1'b0;
				
				write_a <= 1'b1;
				write_b <= 1'b1;
				
				// write_c <= 1'b1;
				case (ir_data[31:26])
					6'b000000: 		// R type insn
					begin
						write_pc <= 1'b0;
						alu_srcA <= 1'b1;
						alu_srcB <= 2'b00;
						case(ir_data[5:0])
							6'b100000: alu_ctrl <= ADD;
							6'b100010: alu_ctrl <= SUB;
							6'b100100: alu_ctrl <= AND;
							6'b100111: alu_ctrl <= NOR;
							default:   alu_ctrl <= ADD;
						endcase
						state <= EX_R;
						insn_stage <= 3'b1;
					end
					6'b000010:    // Jump insn
					begin
						write_pc <= 1'b1;
						alu_srcA <= 1'b0;
						alu_srcB <= 2'b11;
						alu_ctrl <= ADD;

						state <= IF;
						insn_stage <= 3'b1;
						pcsource <= 2'b10;
					end
					6'b000100:    // Beq  insn
					begin
						write_pc <= 1'b0;
						alu_srcA <= 1'b0;
						alu_srcB <= 2'b11;
						alu_ctrl <= ADD;
						
						state <= EX_BEQ;
						insn_stage <= 3'b1;
					end
					6'b100011:   //Load
					begin
						write_pc <= 1'b0;
						alu_srcA <= 1'b1;
						alu_srcB <= 2'b10;
						alu_ctrl <= ADD;
						
						state <= EX_LD;
						insn_stage <= 3'b1;
					end
					6'b101011:   // Store
					begin
						write_pc <= 1'b0;
						alu_srcA <= 1'b1;
						alu_srcB <= 2'b10;
						alu_ctrl <= ADD;
						
						state <= EX_ST;
						insn_stage <= 3'b1;
					end
					default: 
					begin
						//state <=;
						//insn_stage <= ;
					end
				endcase
			end
			
			EX_R:          	// Excution of R-type
			begin
				write_a <= 1'b0;
				write_b <= 1'b0;
				
				alu_srcA <= 1'b1;
				alu_srcB <= 2'b00;
				write_c <= 1'b1;
				case(ir_data[5:0])
					6'b100000: alu_ctrl <= ADD;
					6'b100010: alu_ctrl <= SUB;
					6'b100100: alu_ctrl <= AND;
					6'b100111: alu_ctrl <= NOR;
					default:   alu_ctrl <= ADD;
				endcase
				state <= WB_R;
				insn_stage <= 3'b10;
				
				memtoreg <= 1'b0;
				write_reg <= 1'b1;
				regdst <= 1'b1;				
			end
			
			WB_R:
			begin
				write_c <= 1'b0;
				
				state <= IF;
				insn_stage <= 3'b11;
				iord <= 1'b0;
				alu_srcA <= 1'b0;
				alu_srcB <= 2'b01;
				alu_ctrl <= ADD;
				
				////
				write_reg <= 1'b0;
			end
			
			EX_LD: 
			begin
				write_a <= 1'b0;
				write_b <= 1'b0;
			
		 		iord <= 1'b1; 
				alu_srcA <= 1'b1;
				alu_srcB <= 2'b10;
				alu_ctrl <= ADD;
				write_c <= 1'b1;
				state <= MEM_RD;
				insn_stage <= 3'b10;
			end
			
			MEM_RD:
			begin
			// iord <= 1'b1;
				write_c <= 1'b0;
				
				write_dr <= 1'b1;
				state <= WB_LS;
				insn_stage <= 3'b11;
				
				write_reg <= 1'b1;
				memtoreg <= 1'b1;
				regdst <= 1'b0;
			end
			
			WB_LS:
			begin
				write_dr <= 1'b0;
				
				state <= IF;
				insn_stage <= 3'b100;
				iord <= 1'b0;
				alu_srcA <= 1'b0;
				alu_srcB <= 2'b01;
				alu_ctrl <= ADD;
				
				////
				write_reg <= 1'b0;
				//memtoreg <= 1'b0;
			end
			
			EX_ST:
			begin
				write_a <= 1'b0;
				write_b <= 1'b0;
				
				iord <= 1'b1;
 				alu_srcA <= 1'b1;
				alu_srcB <= 2'b10;
				alu_ctrl <= ADD;
				write_mem <= 1'b1;
								
				write_c <= 1'b1;
				state <= MEM_ST;
				insn_stage <= 3'b10;
			end
			
			MEM_ST:
			begin
		 	//	iord <= 1'b1;
				write_c <= 1'b0;

				state <= IF; 
				insn_stage <= 3'b11;
				iord <= 1'b0;
				alu_srcA <= 1'b0;
				alu_srcB <= 2'b01;
				alu_ctrl <= ADD;
			end
			
			EX_J:
			begin
			   write_a <= 1'b0;
				write_b <= 1'b0;
				write_c <= 1'b0;
				
				write_pc <= 1'b0;
				// pcsource <= 2'b00;
				
				state <= OTHER; 
				insn_stage <= 3'b10;
				
				alu_srcA <= 1'b0;
				alu_srcB <= 2'b01;
				alu_ctrl <= ADD;
			end
			
			EX_BEQ:
			begin
				write_a <= 1'b0;
				write_b <= 1'b0;
				write_c <= 1'b1;
				
				write_pc <= zero;
				pcsource <= 2'b01;
				
				alu_srcA <= 1'b1; 
				alu_srcB <= 2'b00;
				alu_ctrl <= SUB;
				
				state <= BR_BEQ; 
				insn_stage <= 3'b10;
			end
			
			BR_BEQ:
			begin
				write_pc <= 1'b0;
				write_c <= 1'b0;
				
				alu_srcA <= 1'b0;
				alu_srcB <= 2'b01;
				alu_ctrl <= ADD;
				iord <= 1'b0;
				
				state <= OTHER; 
				insn_stage <= 3'b11;
			end
			default: 
			begin
				state <= IF;
				insn_stage <= 3'b111;
				
				iord <= 1'b0;
				alu_srcA <= 1'b0;
				alu_srcB <= 2'b01;
				alu_ctrl <= ADD;
			end
		endcase
	end
					
	always @ (ir_data)
		case (ir_data[31:26])
			6'b000000: 	// R type insn
			begin
			case(ir_data[5:0])
			6'b100000: insn_code <= LED_AD;
			6'b100010: insn_code <= LED_SU;
			6'b100100: insn_code <= LED_AN;
			6'b100111: insn_code <= LED_NO;
			default:   insn_code <= LED_AD;
			endcase
			insn_type <= LED_R;
			end
			6'b000010:   // Jump insn
			begin
				insn_code <= LED_JP;
				insn_type <= LED_J;
			end
			6'b100011:   //Load
			begin
				insn_code <= LED_LD;
				insn_type <= LED_I;
			end
			6'b101011:   // Store
			begin
				insn_code <= LED_ST;
				insn_type <= LED_I;
			end
			default: 
			begin
				insn_type <= LED_N;
				insn_code <= LED_NI;
			end
		endcase
endmodule
