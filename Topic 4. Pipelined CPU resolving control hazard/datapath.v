`include "define.vh"

/**
 * Data Path for MIPS 5-stage pipelined CPU.
 * Author: Zhao, Hongyu, Zhejiang University
 */
 
module datapath (
	input wire clk,  // main clock
	// debug
	`ifdef DEBUG
	input wire [5:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	// control signals
	output reg [31:0] inst_data_id,  // instruction
	input wire rs_used_ctrl,  // whether RS is used
	input wire rt_used_ctrl,  // whether RT is used
	input wire imm_ext_ctrl,  // whether using sign extended to immediate data
	input wire exe_b_src_ctrl,  // data source of operand B for ALU
	input wire [3:0] exe_alu_oper_ctrl,  // ALU operation type
	input wire mem_ren_ctrl,  // memory read enable signal
	input wire mem_wen_ctrl,  // memory write enable signal
	input wire wb_addr_src_ctrl,  // address source to write data back to registers
	input wire wb_data_src_ctrl,  // data source of data being written back to registers
	input wire wb_wen_ctrl,  // register write enable signal
	input wire is_branch_ctrl,  // whether current instruction is a jump instruction
	// IF signals
	input wire if_rst,  // stage reset signal
	input wire if_en,  // stage enable signal
	output reg if_valid,  // working flag
	output reg inst_ren,  // instruction read enable signal
	output reg [31:0] inst_addr,  // address of instruction needed
	input wire [31:0] inst_data,  // instruction fetched
	// ID signals
	input wire id_rst,
	input wire id_en,
	output reg id_valid,
	input wire reg_stall,  // stall signal when LW instruction followed by an related R instruction
	// EXE signals
	input wire exe_rst,
	input wire exe_en,
	output reg exe_valid,
	// MEM signals
	input wire mem_rst,
	input wire mem_en,
	output reg mem_valid,
	output wire mem_ren,  // memory read enable signal
	output wire mem_wen,  // memory write enable signal
	output wire [31:0] mem_addr,  // address of memory
	output wire [31:0] mem_dout,  // data writing to memory
	input wire [31:0] mem_din,  // data read from memory
	// WB signals
	input wire wb_rst,
	input wire wb_en,
	output reg wb_valid,
	// add by zyh
	output reg rs_rt_equal,
	output reg is_load_exe,
	output reg is_store_exe,
	output reg [4:0] regw_addr_exe,
	output reg wb_wen_exe,
	output reg is_load_mem,
	output reg is_store_mem,
	output reg [4:0] addr_rt_mem,
	output reg [4:0] regw_addr_mem,
	output reg wb_wen_mem,
	output reg [4:0] regw_addr_wb,
	output reg wb_wen_wb,
	output wire [4:0] addr_rt,
	output wire [4:0] addr_rs,

	input wire [1:0] pc_src_ctrl,
	input wire [1:0] fwd_a_ctrl,
	input wire [1:0] fwd_b_ctrl,
	input wire fwd_m_ctrl,
	input wire is_load_ctrl,
	input wire is_store_ctrl
	);
		
	`include "mips_define.vh"
	
	// control signals
	reg [3:0] exe_alu_oper_exe;
	reg mem_ren_exe, mem_ren_mem;
	reg mem_wen_exe, mem_wen_mem;
	reg wb_data_src_exe, wb_data_src_mem;
	reg is_branch_exe, is_branch_mem;
	
	// IF signals
	wire [31:0] inst_addr_next;
	
	// ID signals
	reg [31:0] inst_addr_id;	
	reg [31:0] inst_addr_next_id;
	reg [4:0] regw_addr_id;
	wire [31:0] data_rs, data_rt, data_imm;
	//reg AFromExLW,BFromExLW,AFromMem,BFromMem,AFromEx,BFromEx;

	// EXE signals
	reg [31:0] inst_addr_exe;
	reg [31:0] inst_data_exe;	
	reg [31:0] inst_addr_next_exe;
	reg [31:0] opa_exe, opb_exe, data_rt_exe, data_rs_exe;
	reg [31:0] alu_a_exe, alu_b_exe;
	wire [31:0] alu_out_exe;
	reg [4:0] addr_rt_exe;
	reg [4:0] addr_rs_exe;
	// reg [1:0] fwd_a_ctrl_exe;
	// reg [1:0] fwd_b_ctrl_exe;

	// MEM signals
	reg [31:0] inst_addr_mem;
	reg [31:0] inst_data_mem;	
	reg [4:0]  regw_addr_final;
	reg [31:0] opa_mem, data_rt_mem;
	reg [31:0] alu_out_mem;
	reg [31:0] regw_data_mem, regw_data_final;
	reg [4:0] addr_rs_mem;
	reg [31:0]mem_din_mem;
	
	// WB signals
	reg [31:0] regw_data_wb;
	reg wb_wen_final;
	// debug
	`ifdef DEBUG
	wire [31:0] debug_data_reg;
	reg [31:0] debug_data_signal;
	
	// add by zyh
	reg [31:0] data_rs_fwd, data_rt_fwd;
	reg exe_b_src_exe;
	reg [31:0] data_imm_exe;
	
	always @(posedge clk) begin
		case (debug_addr[4:0])
			0: debug_data_signal <= inst_addr;
			1: debug_data_signal <= inst_data;
			2: debug_data_signal <= inst_addr_id;
			3: debug_data_signal <= inst_data_id;
			4: debug_data_signal <= inst_addr_exe;
			5: debug_data_signal <= inst_data_exe;
			6: debug_data_signal <= inst_addr_mem;
			7: debug_data_signal <= inst_data_mem;
			8: debug_data_signal <= {27'b0, addr_rs};
			9: debug_data_signal <= data_rs;
			10: debug_data_signal <= {27'b0, addr_rt};
			11: debug_data_signal <= data_rt;
			12: debug_data_signal <= data_imm;
			13: debug_data_signal <= alu_a_exe;
			14: debug_data_signal <= alu_b_exe;
			15: debug_data_signal <= alu_out_exe;
			16: debug_data_signal <= {20'b0, 3'b0, is_branch_ctrl, 3'b0, is_branch_exe, 3'b0, is_branch_mem};
			17: debug_data_signal <= {31'b0, reg_stall};
			18: debug_data_signal <= {19'b0, inst_ren, 7'b0, mem_ren, 3'b0, mem_wen};
			19: debug_data_signal <= mem_addr;
			20: debug_data_signal <= mem_din;
			21: debug_data_signal <= mem_dout;
			22: debug_data_signal <= {27'b0, regw_addr_wb};
			23: debug_data_signal <= regw_data_wb;
			default: debug_data_signal <= 32'hFFFF_FFFF;
		endcase
	end
	
	assign
		debug_data = debug_addr[5] ? debug_data_signal : debug_data_reg;
	`endif
	
	// IF stage
	assign inst_addr_next = inst_addr + 4;

	always @(*) begin
		if_valid = ~if_rst & if_en;
	end

	always @(posedge clk) begin
		if (if_rst) begin
			inst_ren <= 0;
			inst_addr <= 0;
		end
		else if (if_en) begin
			inst_ren <= 1;
			case (pc_src_ctrl)
				PC_NEXT: inst_addr <= inst_addr_next;
				PC_JUMP: inst_addr <= {inst_addr_id[31:28], inst_data_id[25:0], 2'b0};
				PC_BRANCH: inst_addr <= inst_addr_next_id + {data_imm[29:0], 2'b0};
			endcase
		end
	end
	
	// ID stage
	always @(posedge clk) begin
		if (id_rst) begin
			id_valid <= 0;
			inst_addr_id <= 0;
			inst_data_id <= 0;          //new 5_12
			inst_addr_next_id <= 0;
		end
		else if (id_en) begin
			id_valid <= if_valid;
			inst_addr_id <= inst_addr;
			inst_data_id <= inst_data;
			inst_addr_next_id <= inst_addr_next;
		end
	end
	
	
	assign
		addr_rs = inst_data_id[25:21],
		addr_rt = inst_data_id[20:16],
		data_imm = imm_ext_ctrl ? {{16{inst_data_id[15]}},inst_data_id[15:0]} : {16'b0,inst_data_id[15:0]};
	
	always @(*) begin
		regw_addr_id = inst_data_id[15:11];
		case (wb_addr_src_ctrl)
			WB_ADDR_RD: regw_addr_id = inst_data_id[15:11];
			WB_ADDR_RT: regw_addr_id = inst_data_id[20:16];
		endcase
	end
	
	regfile REGFILE (
		.clk(clk),
		`ifdef DEBUG
		.debug_addr(debug_addr[4:0]),
		.debug_data(debug_data_reg),
		`endif
		.addr_a(addr_rs),
		.data_a(data_rs),
		.addr_b(addr_rt),
		.data_b(data_rt),
		.en_w(wb_wen_final),     //zhe li you ge jiao final de dong xi~~~~~~~~~~~
		.addr_w(regw_addr_final),
		.data_w(regw_data_final)
		// ,.btn_reset(btn_reset)
		);
	always @(*) begin
		data_rs_fwd = data_rs;
		data_rt_fwd = data_rt;
		case (fwd_a_ctrl)
			0: data_rs_fwd = data_rs;
			1: data_rs_fwd = alu_out_exe;
			2: data_rs_fwd = alu_out_mem;
			3: data_rs_fwd = mem_din;
		endcase
		case (fwd_b_ctrl)
			0: data_rt_fwd = data_rt;
			1: data_rt_fwd = alu_out_exe;
			2: data_rt_fwd = alu_out_mem;
			3: data_rt_fwd = mem_din;
		endcase
		rs_rt_equal = (data_rs_fwd==data_rt_fwd);
	end

	/*always @(*) begin
		reg_stall = 0;

		// AfromEXLW = rs_used_ctrl && (regw_addr_exe == addr_rs) && wb_wen_exe && mem_ren_exe && (!mem_wen_ctrl);
		// BfromEXLW = rt_used_ctrl && (regw_addr_exe == addr_rt) && wb_wen_exe && mem_ren_exe && (!mem_wen_ctrl);

		AFromExLW  = rs_used_ctrl && (addr_rs_exe != 0) && (regw_addr_mem == addr_rs_exe) && wb_wen_mem && mem_ren_mem;
		BFromExLW  = rt_used_ctrl && (addr_rt_exe != 0) && (regw_addr_mem == addr_rt_exe) && wb_wen_mem && mem_ren_mem;
		//AFromExLW  = rs_used_ctrl && (addr_rs != 0) && (regw_addr_exe == addr_rs) && wb_wen_exe && mem_ren_exe;
		//BFromExLW  = rt_used_ctrl && (addr_rt != 0) && (regw_addr_exe == addr_rt) && wb_wen_exe && mem_ren_exe;
		//AFromEx = rs_used_ctrl && (addr_rs != 0) && (regw_addr_exe == addr_rs) && wb_wen_exe;
		//BFromEx = rt_used_ctrl && (addr_rt != 0) && (regw_addr_exe == addr_rt) && wb_wen_exe;
		//AFromMem = rs_used_ctrl && (addr_rs != 0) && (regw_addr_mem == addr_rs) && wb_wen_mem;
		//BFromMem = rt_used_ctrl && (addr_rt != 0) && (regw_addr_mem == addr_rt) && wb_wen_mem;
		
		//reg_stall = AFromEx || BFromEx || AFromExLW || BFromExLW;	
		
		reg_stall = AFromExLW || BFromExLW;	
	end*/
	
	/*always @(*) begin
		opa_id = data_rs;
		opb_id = data_rt;
		case (exe_b_src_ctrl)
			EXE_B_RT: opb_id = data_rt;
			EXE_B_IMM: opb_id = data_imm;
		endcase
	end*/
	
	// EXE stage
	/*always @(*) begin
		fwd_a_ctrl= 2'b00;
		if(wb_wen_mem && (regw_addr_mem != 0) && (regw_addr_mem == addr_rs_exe) && (mem_wen_exe == 0) && !reg_stall)
			fwd_a_ctrl= 2'b01;
		if(wb_wen__wb && (regw_addr__wb != 0) && (regw_addr_mem != addr_rs_exe) && (regw_addr__wb == addr_rs_exe) && (mem_wen_exe == 0) && !reg_stall)
			fwd_a_ctrl= 2'b10;
		
		fwd_b_ctrl= 2'b00;
		if(wb_wen_mem && (regw_addr_mem != 0) && (regw_addr_mem == addr_rt_exe) && (mem_wen_exe == 0) && !reg_stall)
			fwd_b_ctrl= 2'b01;
		if(wb_wen__wb && (regw_addr__wb != 0) && (regw_addr_mem != addr_rt_exe) && (regw_addr__wb == addr_rt_exe) && (mem_wen_exe == 0) && !reg_stall)
			fwd_b_ctrl= 2'b10;
	end*/
	
	always @(posedge clk) begin
		if (exe_rst) begin
			exe_valid <= 0;
			inst_addr_exe <= 0;
			inst_data_exe <= 0;
			inst_addr_next_exe <= 0;
			regw_addr_exe <= 0;
			//opa_exe <= 0;
			//opb_exe <= 0;
			data_rt_exe <= 0;
			data_rs_exe <= 0;
			exe_alu_oper_exe <= 0;
			mem_ren_exe <= 0;
			mem_wen_exe <= 0;
			wb_data_src_exe <= 0;
			wb_wen_exe <= 0;
			is_branch_exe <= 0;
			
			addr_rt_exe <= 0;
			addr_rs_exe <= 0;

		end
		else if (exe_en) begin
			exe_valid <= id_valid;
			inst_addr_exe <= inst_addr_id;
			inst_data_exe <= inst_data_id;
			regw_addr_exe <= regw_addr_id;
			exe_b_src_exe <= exe_b_src_ctrl;
			addr_rs_exe <= addr_rs;
			data_rs_exe <= data_rs;
			addr_rt_exe <= addr_rt;
			data_rt_exe <= data_rt;
			data_imm_exe <= data_imm;
			exe_alu_oper_exe <= exe_alu_oper_ctrl;
			mem_ren_exe <= mem_ren_ctrl;
			mem_wen_exe <= mem_wen_ctrl;
			wb_data_src_exe <= wb_data_src_ctrl;
			wb_wen_exe <= wb_wen_ctrl;	
			is_load_exe <= is_load_ctrl;
			is_store_exe <= is_store_ctrl;
			//opa_exe <= opa_id;
			//opb_exe <= opb_id;
		end
	end
	
	always @(*) begin
		opa_exe = data_rs_exe;
		opb_exe = data_rt_exe;
		case (exe_b_src_exe)
			EXE_B_RT: opb_exe = data_rt_exe;
			EXE_B_IMM: opb_exe = data_imm_exe;
		endcase
	end
	
	alu ALU (
		.inst(inst_data_exe),
		.a(opa_exe),
		.b(opb_exe),
		.oper(exe_alu_oper_exe),
		.result(alu_out_exe)
		);
	
	// MEM stage

	always @(posedge clk) begin
		if (mem_rst) begin
			mem_valid <= 0;
			inst_addr_mem <= 0;
			inst_data_mem <= 0;
			regw_addr_mem <= 0;
			data_rt_mem <= 0;
			alu_out_mem <= 0;
			mem_ren_mem <= 0;
			mem_wen_mem <= 0;
			wb_data_src_mem <= 0;
			wb_wen_mem <= 0;
			is_branch_mem <= 0;
			addr_rt_mem <= 0;
			addr_rs_mem <= 0;
			is_load_mem <= 0;
			is_store_mem <= 0;
		end
		else if (mem_en) begin
			mem_valid <= exe_valid;
			inst_addr_mem <= inst_addr_exe;
			inst_data_mem <= inst_data_exe;
			regw_addr_mem <= regw_addr_exe;
			opa_mem <= opa_exe;
			data_rt_mem <= data_rt_exe;
			alu_out_mem <= alu_out_exe;
			mem_ren_mem <= mem_ren_exe;
			mem_wen_mem <= mem_wen_exe;
			wb_data_src_mem <= wb_data_src_exe;
			wb_wen_mem <= wb_wen_exe;
			addr_rt_mem <= addr_rt_exe;
			addr_rs_mem <= addr_rs_exe;
			mem_din_mem <= mem_din;
			is_load_mem <= is_load_exe;
			is_store_mem <= is_store_exe;
		end
	end

	always @(*) begin
		regw_data_mem = alu_out_mem;
		case (wb_data_src_mem)
			WB_DATA_ALU: regw_data_mem = alu_out_mem;
			WB_DATA_MEM: regw_data_mem = mem_din;
		endcase
	end
	
	assign
		mem_ren = mem_ren_mem,
		mem_wen = mem_wen_mem,
		mem_addr = alu_out_mem,
		mem_dout = fwd_m_ctrl ? regw_data_wb : data_rt_mem;
	
	// WB stage		
	always @(posedge clk) begin
		if (wb_rst) begin
			wb_valid <= 0;
			wb_wen_wb <= 0;
			regw_addr_wb <= 0;
			regw_data_wb <= 0;
		end
		if (wb_en) begin
			wb_valid <= mem_valid;
			wb_wen_wb <= wb_wen_mem;
			regw_addr_wb <= regw_addr_mem;
			regw_data_wb <= regw_data_mem;
		end
	end

	always @(*) begin
		wb_wen_final = wb_wen_mem & wb_en;
		regw_addr_final = regw_addr_mem;
		regw_data_final = regw_data_mem;
	end

endmodule
