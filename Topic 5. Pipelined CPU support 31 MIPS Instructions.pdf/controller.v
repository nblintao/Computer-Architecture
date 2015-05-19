`include "define.vh"

/**
 * Controller for MIPS 5-stage pipelined CPU.
 * Author: Zhao, Hongyu, Zhejiang University
 */

`include "define.vh"

/**
 * Controller for MIPS 5-stage pipelined CPU.
 * Author: Zhao, Hongyu, Zhejiang University
 */

module controller (/*AUTOARG*/
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	// debug
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	`endif
	// instruction decode
	input wire [31:0] inst,  // instruction
	
	


	output reg imm_ext,  // whether using sign extended to immediate data
	output reg exe_b_src,  // data source of operand B for ALU
	output reg [3:0] exe_alu_oper,  // ALU operation type
	output reg mem_ren,  // memory read enable signal
	output reg mem_wen,  // memory write enable signal
	output reg wb_addr_src,  // address source to write data back to registers
	output reg wb_data_src,  // data source of data being written back to registers
	output reg wb_wen,  // register write enable signal
	output reg is_branch,  // whether current instruction is a branch instruction
	output reg rs_used,  // whether RS is used
	output reg rt_used,  // whether RT is used
	output reg unrecognized,  // whether current instruction can not be recognized
	output reg reg_stall,//output stall signal when LW instruction followed by an related R instruction
	// pipeline control
	 
	output reg if_rst,  // stage reset signal
	output reg if_en,  // stage enable signal
	input wire if_valid,  // stage valid flag
	output reg id_rst,
	output reg id_en,
	input wire id_valid,
	output reg exe_rst,
	output reg exe_en,
	input wire exe_valid,
	output reg mem_rst,
	output reg mem_en,
	input wire mem_valid,
	output reg wb_rst,
	output reg wb_en,
	input wire wb_valid,
	
	//NEW SIGNAL INPUT
	input wire rs_rt_equal, //whether data from RS and RT are equal
	//id part
	input wire [4:0] addr_rs,
	input wire [4:0] addr_rt,
	//exe part
	input wire is_load_exe,// whether data in EXE is LW
	input wire is_store_exe,//whether data in EXE is SW
	input wire [4:0] regw_addr_exe,//register write address from EXE stage
	input wire wb_wen_exe,// register write enable signal feedback from EXE stage
	//mem part
	input wire is_load_mem,//whether instruction in MEM is LW
	input wire is_store_mem,//whether insruction in MEM is SW
	input wire [4:0] addr_rt_mem,//address of RT from MEM stage
	input wire [4:0] regw_addr_mem,//register write address from MEM stage
	input wire wb_wen_mem,// register write enable signal feedback from MEM stage
	//wb part
	input wire[4:0] regw_addr_wb,//register write address from WB stage
	input wire wb_wen_wb,//write enable signal feedback from WB stage
	//output
	output reg [1:0] pc_src,//how would PC change to next
	output reg [1:0] fwd_a,//fowarding selection for channel A
	output reg [1:0] fwd_b,//fowarding selection for channel B
	output reg fwd_mem,//fowarding selection for memory
	output reg is_load,//whether current instruction is LW
	output reg is_store//whether current instruction is SW
	//These input wires come from datapath
	);
	
	`include "mips_define.vh"
	
	// instruction decode
	always @(*) begin
		imm_ext = 0;
		exe_b_src = EXE_B_RT;
		exe_alu_oper = EXE_ALU_ADD;
		mem_ren = 0;
		mem_wen = 0;
		wb_addr_src = WB_ADDR_RD;
		wb_data_src = WB_DATA_ALU;
		wb_wen = 0;
		is_branch = 0;
		rs_used = 0;
		rt_used = 0;
		//new
		is_store=0;
		is_load=0;
		pc_src=PC_NEXT;//no branch
		unrecognized = 0;
		case (inst[31:26])
			INST_R: begin
				case (inst[5:0])
					R_FUNC_ADD: begin
						exe_alu_oper = EXE_ALU_ADD;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_SUB: begin
						exe_alu_oper = EXE_ALU_SUB; //?
						wb_addr_src = WB_ADDR_RD; //?
						wb_data_src = WB_DATA_ALU; //?
						wb_wen = 1; //?
						rs_used = 1; //?
						rt_used = 1; //?
					end
					R_FUNC_AND: begin
						exe_alu_oper = EXE_ALU_AND;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_OR: begin
						exe_alu_oper = EXE_ALU_OR; 
						wb_addr_src = WB_ADDR_RD; 
						wb_data_src = WB_DATA_ALU; 
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					R_FUNC_XOR: begin
						exe_alu_oper = EXE_ALU_XOR;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
					end
					
					default: begin
						unrecognized = 1;
					end
				endcase
			end
			INST_BEQ: begin
				exe_b_src = EXE_B_IMM; 
				
				//FBI WARNNING!!!! if branch pc_src
				if(rs_rt_equal)begin
					pc_src=PC_BRANCH;
				end				
				imm_ext = 1; 
				is_branch = 1; 
				rs_used = 1; 
				rt_used = 0; 
			end
			INST_LW: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_alu_oper = EXE_ALU_ADD;
				mem_ren = 1;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_MEM;
				wb_wen = 1;
				rs_used = 1;
				is_load=1;//new signal
			end
			INST_J: begin
				pc_src=PC_JUMP;
			end
			INST_SW: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM; 
				exe_alu_oper = EXE_ALU_ADD; 
				wb_addr_src = WB_ADDR_RT;		
				mem_wen = 1;
				rs_used = 1;
				rt_used = 1; 
				is_store=1;// new signal
			end
			default: begin
				unrecognized = 1;
			end
		endcase
	end
	
	// pipeline control
	`ifdef DEBUG
	reg debug_step_prev;
	
	always @(posedge clk) begin
		debug_step_prev <= debug_step;
	end
	`endif

//SET SIGNAL	
	always @(*) begin
		if_rst = 0;
		if_en = 1;
		id_rst = 0;
		id_en = 1;
		exe_rst = 0;
		exe_en = 1;
		mem_rst = 0;
		mem_en = 1;
		wb_rst = 0;
		wb_en = 1;
		
		//new part in PPT
		reg_stall=0;
		fwd_a=0;
		fwd_b=0;
		fwd_mem=0;
		//fwd_a
		if(rs_used&&addr_rs!=0&&!is_store)begin
			if(regw_addr_exe==addr_rs && wb_wen_exe) begin
				if(is_load_exe)
					reg_stall=1;
				else
					fwd_a=1;
			end
			else if (regw_addr_mem==addr_rs && wb_wen_mem) begin
				if(is_load_mem)
					fwd_a=3;
				else
					fwd_a=2;
			end
		end
		//fwd_b
		if(rt_used&&addr_rt!=0&&!is_store)begin
			if(regw_addr_exe==addr_rt && wb_wen_exe) begin
				if(is_load_exe)
					reg_stall=1;
				else
					fwd_b=1;
			end
			else if (regw_addr_mem==addr_rt && wb_wen_mem) begin
				if(is_load_mem&&!is_store)
					fwd_b=3;
				else
					fwd_b=2;
			end
		end
		//FBI WARNING!!!! about fwd_mem                                                                                                                                                                                                                                              
		if(is_store_mem &&addr_rt_mem!=0) begin
			if(regw_addr_wb==addr_rt_mem&& wb_wen_wb)begin
				fwd_mem=1;
			end
		end
		
		if (rst) begin
			if_rst = 1;
			id_rst = 1;
			exe_rst = 1;
			mem_rst = 1;
			wb_rst = 1;
		end
		`ifdef DEBUG
		// suspend and step execution
		else if ((debug_en) && ~(~debug_step_prev && debug_step)) begin
			if_en = 0;
			id_en = 0;
			exe_en = 0;
			mem_en = 0;
			wb_en = 0;
		end
		`endif
		// this stall indicate that ID is waiting for previous LW instruction, insert one NOP between ID and EXE.
		else if (reg_stall) begin
			if_en = 0;
			id_en = 0;
			exe_rst = 1;
		end
	end
	
endmodule
