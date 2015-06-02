`include "define.vh"

/**
 * Controller for MIPS 5-stage pipelined CPU.
 * Author: Zhao, Hongyu, Zhejiang University
 */

module controller (/*AUTOARG*/
    input wire clk, // main clock
    input wire rst, // synchronous reset
    // debug
    `ifdef DEBUG
    input wire debug_en, // debug enable
    input wire debug_step, // debug step clock
    `endif
    // instruction decode
	 input wire [31:0] inst, // instruction

    input wire rs_rt_equal, // whether data from RS and RT are equal
    input wire is_load_exe, // whether instruction in EXE stage is LW
    input wire is_store_exe, // whether instruction in EXE stage is SW
    input wire [4:0] regw_addr_exe, // register write address from EXE stage
    input wire wb_wen_exe, // register write enable signal feedback from EXE stage
    input wire is_load_mem, // whether instruction in MEM stage is LW
    input wire is_store_mem, // whether instruction in MEM stage is SW
    input wire [4:0] addr_rt_mem, // address of RT from MEM stage
    input wire [4:0] regw_addr_mem, // register write address from MEM stage
    input wire wb_wen_mem, // register write enable signal feedback from MEM stage
    input wire [4:0] regw_addr_wb, // register write address from WB stage
    input wire wb_wen_wb, // register write enable signal feedback from WB stage
	 output reg [1:0] pc_src, // how would PC change to next

    output reg imm_ext, // whether using sign extended to immediate data
	 output reg [1:0] exe_a_src, // data source of operand A for ALU
    output reg [1:0] exe_b_src, // data source of operand B for ALU
    output reg [3:0] exe_alu_oper, // ALU operation type
    output reg mem_ren, // memory read enable signal
    output reg mem_wen, // memory write enable signal
    output reg [1:0]wb_addr_src, // address source to write data back to registers
    output reg wb_data_src, // data source of data being written back to registers
	 output reg wb_wen, // register write enable signal

    output reg [1:0] fwd_a, // forwarding selection for channel A
    output reg [2:0] fwd_b, // forwarding selection for channel B
    output reg fwd_m, // forwarding selection for memory
    output reg is_load, // whether current instruction is LW
	 output reg is_store, // whether current instruction is SW

    output reg unrecognized, // whether current instruction can not be recognized
    // pipeline control
    output reg if_rst, // stage reset signal
    output reg if_en, // stage enable signal
    input wire if_valid, // stage valid flag
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
	
    output reg [1:0] cp_oper,//out 2
    output wire ir_en,//out 1
	 input wire jump_en
);

	`include "mips_define.vh"
	
	reg wb_data_src_exe, wb_data_src_mem;
	reg is_branch; // whether current instruction is a branch instruction
	reg rs_used;  // whether RS is used
	reg rt_used;  // whether RT is used
	reg reg_stall;  // stall signal when LW instruction followed by an related R instruction
	reg AFromExLW,BFromExLW;
	wire [4:0] addr_rs, addr_rt;
	
	assign
		addr_rs = inst[25:21],
		addr_rt = inst[20:16];
	
	// instruction decode
	always @(*) begin

		pc_src = 2'b00;

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
		cp_oper = EXE_CP_NONE;
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
						exe_a_src = 0;
					end
					R_FUNC_SUB: begin
					
						exe_alu_oper = EXE_ALU_SUB;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_AND: begin
						exe_alu_oper = EXE_ALU_AND;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_OR: begin
						exe_alu_oper = EXE_ALU_OR;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_XOR: begin
						exe_alu_oper = EXE_ALU_XOR;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_ADDU:begin
						exe_alu_oper = EXE_ALU_ADD;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_SUBU:begin
						exe_alu_oper = EXE_ALU_SUB;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_NOR:begin
						exe_alu_oper = EXE_ALU_NOR;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_SLT:begin
						exe_alu_oper = EXE_ALU_SLT;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_SLTU:begin
						exe_alu_oper = EXE_ALU_SLTU;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_SLL:begin
						exe_alu_oper = EXE_ALU_SLL;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						//rs_used = 1;
						rt_used = 1;
						exe_a_src = 1;
					end
					R_FUNC_SRL:begin
						exe_alu_oper = EXE_ALU_SRL;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						//rs_used = 1;
						rt_used = 1;
						exe_a_src = 1;
					end
					R_FUNC_SRA:begin
						exe_alu_oper = EXE_ALU_SRA;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						//rs_used = 1;
						rt_used = 1;
						exe_a_src = 1;
					end
					R_FUNC_SLLV:begin
						exe_alu_oper = EXE_ALU_SLL;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_SRLV:begin
						exe_alu_oper = EXE_ALU_SRL;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_SRAV:begin
						exe_alu_oper = EXE_ALU_SRA;
						wb_addr_src = WB_ADDR_RD;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
						rs_used = 1;
						rt_used = 1;
						exe_a_src = 0;
					end
					R_FUNC_JR:begin
						pc_src = 2'b10;
						rs_used = 1;
						
					end
					default: begin
						unrecognized = 1;
					end
				endcase
			end
			INST_BEQ: begin
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				imm_ext = 1;
				is_branch = 1;
				rs_used = 1;
				rt_used = 1;
				if(rs_rt_equal)
					pc_src = 2'b11;
			end
			INST_BNE:begin
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				imm_ext = 1;
				is_branch = 1;
				rs_used = 1;
				rt_used = 1;
				if(!rs_rt_equal)
					pc_src = 2'b11;
			end
			INST_ADDI:begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_ADD;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_ADDIU:begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_ADD;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_ANDI:begin
				imm_ext = 0;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_AND;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_ORI:begin
				imm_ext = 0;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_OR;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_XORI:begin
				imm_ext = 0;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_XOR;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_LUI:begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_LUI;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				//rs_used = 1;
				rt_used = 1;
			end
			INST_LW: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_ADD;
				mem_ren = 1;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_MEM;
				wb_wen = 1;
				rs_used = 1;
			end
			INST_SW: begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_ADD;
				mem_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_SLTI:begin
				imm_ext = 1;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_SLT;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_SLTIU:begin
				imm_ext = 0;
				exe_b_src = EXE_B_IMM;
				exe_a_src = 0;
				exe_alu_oper = EXE_ALU_SLTU;
				wb_addr_src = WB_ADDR_RT;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
				rs_used = 1;
				rt_used = 1;
			end
			INST_J: begin
				pc_src = 2'b01;
			end
			INST_JAL:begin
				exe_alu_oper = EXE_ALU_ADD;
				pc_src = 2'b01;
				exe_b_src = EXE_B_FOUR;
				exe_a_src = 2;
				wb_addr_src = WB_DATA_LINK;
				wb_data_src = WB_DATA_ALU;
				wb_wen = 1;
			end
			INST_CP0:begin
				case(inst[25:21])
					5'b10000: cp_oper = EXE_CP0_ERET;
					5'b00000: begin
						cp_oper = EXE_CP_MFC0; 
						exe_alu_oper = EXE_ALU_B;
						// rt_used = 1;
						wb_addr_src = WB_ADDR_RT;
						wb_data_src = WB_DATA_ALU;
						wb_wen = 1;
					end
					5'b00100: begin
						cp_oper = EXE_CP_MTC0;
						rt_used = 1;
					end
				endcase 
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
		else if (reg_stall) begin
			if_en = 0;
			id_en = 0;
			//exe_en = 0;
			//mem_en = 0;
			//wb_en = 0;
			exe_rst = 1;
		end
		else if (jump_en) begin
			//if_en = 0;
			id_rst = 1;
			//exe_en = 0;
			//mem_en = 0;
			//wb_en = 0;
			//exe_rst = 1;
		end
	end

	//TODO Interupt
	// When it is in the interruption, no new interruption is allowed, ir_en = 0.
	assign ir_en = 1;
	

	always @(posedge clk) begin
		if (exe_rst)
			wb_data_src_exe <= 0;
		else if (exe_en)
			wb_data_src_exe <= wb_data_src;
	end
	always @(posedge clk) begin
		if (mem_rst)
			wb_data_src_mem <= 0;
		else if (mem_en)
			wb_data_src_mem <= wb_data_src_exe;
	end
	
	always @(*) begin
	
		reg_stall = 0;
		
		AFromExLW  = rs_used && (addr_rs != 0) && (regw_addr_exe == addr_rs) && wb_wen && is_load_exe;
		BFromExLW  = rt_used && (addr_rt != 0) && (regw_addr_exe == addr_rt) && wb_wen && is_load_exe;
		reg_stall = AFromExLW || BFromExLW;	

	end
	
	always @(*) begin
		fwd_a= 2'b00;
		if(wb_wen_exe && (regw_addr_exe != 0) && (regw_addr_exe == addr_rs) && (mem_wen == 0) && !reg_stall)
			fwd_a= 2'b01;
		if(wb_wen_mem && (regw_addr_mem != 0) && (regw_addr_exe != addr_rs) && (regw_addr_mem == addr_rs) && (mem_wen == 0) && !reg_stall && !wb_data_src_mem)
			fwd_a= 2'b10;
		if(wb_wen_mem && (regw_addr_mem != 0) && (regw_addr_exe != addr_rs) && (regw_addr_mem == addr_rs) && (mem_wen == 0) && !reg_stall && wb_data_src_mem)
			fwd_a= 2'b11;
		
		fwd_b= 3'b000;
		if(cp_oper == EXE_CP_MFC0)
			//Interupt
			fwd_b = 3'b110;		
		else begin
			if(wb_wen_exe && (regw_addr_exe != 0) && (regw_addr_exe == addr_rt) && (mem_wen == 0) && !reg_stall)
				fwd_b= 3'b001;
			if(wb_wen_mem && (regw_addr_mem != 0) && (regw_addr_exe != addr_rt) && (regw_addr_mem == addr_rt) && (mem_wen == 0) && !reg_stall && !wb_data_src_mem)
				fwd_b= 3'b010;
			if(wb_wen_mem && (regw_addr_mem != 0) && (regw_addr_exe != addr_rt) && (regw_addr_mem == addr_rt) && (mem_wen == 0) && !reg_stall && wb_data_src_mem)
				fwd_b= 3'b011;			
		end


	end
	
	always @(posedge clk) begin
		fwd_m = (addr_rt_mem == regw_addr_wb) && is_store_exe && wb_wen_mem;
	end
	

	
endmodule
