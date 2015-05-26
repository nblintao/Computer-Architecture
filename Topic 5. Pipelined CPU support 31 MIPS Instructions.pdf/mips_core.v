`include "define.vh"

/**
 * MIPS 5-stage pipeline CPU Core, including data path and co-processors.
 * Author: Zhao, Hongyu, Zhejiang University
 */

module mips_core (
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	// debug
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	input wire [5:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	// instruction interfaces
	output wire inst_ren,  // instruction read enable signal
	output wire [31:0] inst_addr,  // address of instruction needed
	input wire [31:0] inst_data,  // instruction fetched
	// memory interfaces
	output wire mem_ren,  // memory read enable signal
	output wire mem_wen,  // memory write enable signal
	output wire [31:0] mem_addr,  // address of memory
	output wire [31:0] mem_dout,  // data writing to memory
	input wire [31:0] mem_din  // data read from memory
	);
	
	// control signals
	wire [31:0] inst_data_ctrl;
	
	wire imm_ext_ctrl;
	wire [1:0] exe_a_src_ctrl;
	wire [1:0] exe_b_src_ctrl;
	wire [3:0] exe_alu_oper_ctrl;
	wire mem_ren_ctrl;
	wire mem_wen_ctrl;
	wire [1:0] wb_addr_src_ctrl;
	wire wb_data_src_ctrl;
	wire wb_wen_ctrl;
	wire is_branch_ctrl;
	wire [4:0] addr_rs;
	wire [4:0] addr_rt;
	
	wire rs_used_ctrl, rt_used_ctrl;
	
	wire reg_stall;
	wire if_rst, if_en, if_valid;
	wire id_rst, id_en, id_valid;
	wire exe_rst, exe_en, exe_valid;
	wire mem_rst, mem_en, mem_valid;
	wire wb_rst, wb_en, wb_valid;
	wire [4:0] rs_addr_exe,rt_addr_exe,rt_addr_mem,regw_addr_wb,regw_addr_mem;
	
	//NEW SIGNAL INPUT
	wire rs_rt_equal; //whether data from RS and RT are equal
	//exe part
	wire is_load_exe;// whether data in EXE is LW
	wire is_store_exe;//whether data in EXE is SW
	wire [4:0] regw_addr_exe;//register write address from EXE stage
	wire wb_wen_exe;// register write enable signal feedback from EXE stage
	//mem part
	wire is_load_mem;//whether instruction in MEM is LW
	wire is_store_mem;//whether insruction in MEM is SW
	wire [4:0] addr_rt_mem;//address of RT from MEM stage
	//wire [4:0] regw_addr_mem;//register write address from MEM stage
	wire wb_wen_mem;// register write enable signal feedback from MEM stage
	//wb part
	//wire[4:0] regw_addr_wb;//register write address from WB stage
	wire wb_wen_wb;//write enable signal feedback from WB stage
	//output
	wire [1:0] pc_src;//how would PC change to next
	wire [1:0] fwd_a;//fowarding selection for channel A
	wire [1:0] fwd_b;//fowarding selection for channel B
	wire fwd_mem;//fowarding selection for memory
	wire is_load;//whether current instruction is LW
	wire is_store;//whether current instruction is SW
	// controller
	controller CONTROLLER (
		.clk(clk),
		.rst(rst),
		`ifdef DEBUG
		.debug_en(debug_en),
		.debug_step(debug_step),
		`endif
		.inst(inst_data_ctrl),
		.imm_ext(imm_ext_ctrl),
		.exe_a_src(exe_a_src_ctrl),
		.exe_b_src(exe_b_src_ctrl),
		.exe_alu_oper(exe_alu_oper_ctrl),
		.mem_ren(mem_ren_ctrl),
		.mem_wen(mem_wen_ctrl),
		.wb_addr_src(wb_addr_src_ctrl),
		.wb_data_src(wb_data_src_ctrl),
		.wb_wen(wb_wen_ctrl),
		.is_branch(is_branch_ctrl),
		.rs_used(rs_used_ctrl),
		.rt_used(rt_used_ctrl),
		.unrecognized(),
		.reg_stall(reg_stall),
		.if_rst(if_rst),
		.if_en(if_en),
		.if_valid(if_valid),
		.id_rst(id_rst),
		.id_en(id_en),
		.id_valid(id_valid),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.exe_valid(exe_valid),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.mem_valid(mem_valid),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		.wb_valid(wb_valid),
		//NEW SIGNAL INPUT
		.rs_rt_equal(rs_rt_equal), //whether data from RS and RT are equal
		.addr_rs(addr_rs),
		.addr_rt(addr_rt),
		//exe part
		.is_load_exe(is_load_exe),// whether data in EXE is LW
		.is_store_exe(is_store_exe),//whether data in EXE is SW
		.regw_addr_exe(regw_addr_exe),//register write address from EXE stage
		.wb_wen_exe(wb_wen_exe),// register write enable signal feedback from EXE stage
		//mem part
		.is_load_mem(is_load_mem),//whether instruction in MEM is LW
		.is_store_mem(is_store_mem),//whether insruction in MEM is SW
		.addr_rt_mem(addr_rt_mem),//address of RT from MEM stage
		.regw_addr_mem(regw_addr_mem),//register write address from MEM stage
		.wb_wen_mem(wb_wen_mem),// register write enable signal feedback from MEM stage
		//wb part
		.regw_addr_wb(regw_addr_wb),//register write address from WB stage
		.wb_wen_wb(wb_wen_wb),//write enable signal feedback from WB stage
		//output
		.pc_src(pc_src),//how would PC change to next
		.fwd_a(fwd_a),//fowarding selection for channel A
		.fwd_b(fwd_b),//fowarding selection for channel B
		.fwd_mem(fwd_mem),//fowarding selection for memory
		.is_load(is_load),//whether current instruction is LW
		.is_store(is_store)//whether current instruction is SW
		
		//.mem_valid(mem_valid),//MEM.WriteReg
		//.wb_valid(wb_valid) //WB.WriteReg
	);
	
	// data path
	datapath DATAPATH (
		.clk(clk),
		`ifdef DEBUG
		.debug_addr(debug_addr),
		.debug_data(debug_data),
		`endif
		.inst_data_ctrl(inst_data_ctrl),
		.rs_used_ctrl(rs_used_ctrl),
		.rt_used_ctrl(rt_used_ctrl),
		.imm_ext_ctrl(imm_ext_ctrl),
		.exe_a_src_ctrl(exe_a_src_ctrl),
		.exe_b_src_ctrl(exe_b_src_ctrl),
		.exe_alu_oper_ctrl(exe_alu_oper_ctrl),
		.mem_ren_ctrl(mem_ren_ctrl),
		.mem_wen_ctrl(mem_wen_ctrl),
		.wb_addr_src_ctrl(wb_addr_src_ctrl),
		.wb_data_src_ctrl(wb_data_src_ctrl),
		.wb_wen_ctrl(wb_wen_ctrl),
		.is_branch_ctrl(is_branch_ctrl),
		.if_rst(if_rst),
		.if_en(if_en),
		.if_valid(if_valid),
		.inst_ren(inst_ren),
		.inst_addr(inst_addr),
		.inst_data(inst_data),
		.id_rst(id_rst),
		.id_en(id_en),
		.id_valid(id_valid),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.exe_valid(exe_valid),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.mem_valid(mem_valid),
		.mem_ren(mem_ren),
		.mem_wen(mem_wen),
		.mem_addr(mem_addr),
		.mem_dout(mem_dout),
		.mem_din(mem_din),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		.wb_valid(wb_valid),
		.rs_rt_equal(rs_rt_equal),
		.addr_rs(addr_rs),
		.addr_rt(addr_rt),
		.is_load_exe(is_load_exe),
		.is_store_exe(is_store_exe),
		.regw_addr_exe(regw_addr_exe),
		.wb_wen_exe(wb_wen_exe),
		.is_load_mem(is_load_mem),
		.is_store_mem(is_store_mem),
		.rt_addr_mem(addr_rt_mem),
		.regw_addr_mem(regw_addr_mem),
		.wb_wen_mem(wb_wen_mem),
		.regw_addr_wb(regw_addr_wb),
		.wb_wen_wb(wb_wen_wb),
		.pc_src(pc_src),
		.fwd_a(fwd_a),
		.fwd_b(fwd_b),
		.fwd_mem(fwd_mem),
		.is_load(is_load),
		.is_store(is_store)
	
	);
	
endmodule
