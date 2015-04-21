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
	output reg [31:0] inst_data_ctrl,  // instruction
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
	output reg reg_stall,  // stall signal when LW instruction followed by an related R instruction
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
	output reg wb_valid
	);
	
	`include "mips_define.vh"
	
	// control signals
	reg [3:0] exe_alu_oper_exe;
	reg mem_ren_exe, mem_ren_mem;
	reg mem_wen_exe, mem_wen_mem;
	reg wb_data_src_exe, wb_data_src_mem;
	reg wb_wen_exe, wb_wen_mem, wb_wen_wb;
	reg is_branch_exe, is_branch_mem;
	
	// IF signals
	wire [31:0] inst_addr_next;
	
	// ID signals
	reg [31:0] inst_addr_id;
	reg [31:0] inst_addr_next_id;
	reg [4:0] regw_addr_id;
	reg [31:0] opa_id, opb_id;
	wire [4:0] addr_rs, addr_rt;
	wire [31:0] data_rs, data_rt, data_imm;
	// reg AFromEx,BFromEx,AFromMem,BFromMem;	
	reg AfromEXLW, BfromEXLW;
	
	// EXE signals
	reg [31:0] inst_addr_exe;
	reg [31:0] inst_data_exe;
	reg [31:0] inst_addr_next_exe;
	reg [4:0] regw_addr_exe;
	reg [31:0] opa_exe, opb_exe, data_rt_exe;
	wire [31:0] old_alu_a_exe, old_alu_b_exe;
	wire [31:0] alu_a_exe, alu_b_exe;
	wire [31:0] alu_out_exe;
	
	// MEM signals
	reg [31:0] inst_addr_mem;
	reg [31:0] inst_data_mem;
	reg [4:0] regw_addr_mem;
	reg [31:0] opa_mem, data_rt_mem;
	reg [31:0] alu_out_mem;
	reg [31:0] regw_data_mem;
	
	// WB signals
	reg [4:0] regw_addr_wb;
	reg [31:0] regw_data_wb;
	
	// debug
	`ifdef DEBUG
	wire [31:0] debug_data_reg;
	reg [31:0] debug_data_signal;


	// forwarding
	reg [1:0] fwd_a_ctrl;
	reg [1:0] fwd_b_ctrl;
	reg fwd_m_ctrl;
	
	always @(posedge clk) begin
		case (debug_addr[4:0])
			0: debug_data_signal <= inst_addr;
			1: debug_data_signal <= inst_data;
			2: debug_data_signal <= inst_addr_id;
			3: debug_data_signal <= inst_data_ctrl;
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
	assign
		inst_addr_next = inst_addr + 4;
	
	always @(posedge clk) begin
		if (if_rst) begin
			if_valid <= 0;
			inst_ren <= 0;
			inst_addr <= 0;
		end
		else if (if_en) begin
			if_valid <= 1;
			inst_ren <= 1;
			inst_addr <= is_branch_mem ? alu_out_mem[15:0]<<2 : inst_addr_next; //?
		end
	end
	
	// ID stage
	always @(posedge clk) begin
		if (id_rst) begin
			id_valid <= 0;
			inst_addr_id <= 0;
			inst_data_ctrl <= 0;
			inst_addr_next_id <= 0;
		end
		else if (id_en) begin
			id_valid <= if_valid;
			inst_addr_id <= inst_addr;
			inst_data_ctrl <= inst_data;
			inst_addr_next_id <= inst_addr_next;
		end
	end
	
	assign
		addr_rs = inst_data_ctrl[25:21],
		addr_rt = inst_data_ctrl[20:16],
		// data_imm = imm_ext_ctrl ? {inst_data_ctrl[15:0], 2'b0} : {inst_data_ctrl[15:0]}; //? zyh: it is not Sign Extend
		data_imm = imm_ext_ctrl ? {inst_data_ctrl[15:0]} : {inst_data_ctrl[15:0]}; //? zyh: it is not Sign Extend
	
	always @(*) begin
		regw_addr_id = inst_data_ctrl[15:11];
		case (wb_addr_src_ctrl)
			WB_ADDR_RD: regw_addr_id = inst_data_ctrl[15:11];
			WB_ADDR_RT: regw_addr_id = inst_data_ctrl[20:16];
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
		.en_w(wb_wen_wb),
		.addr_w(regw_addr_wb),
		.data_w(regw_data_wb)
		);
	
	always @(posedge clk) begin
		reg_stall = 0;
		
		// AFromEx = rs_used_ctrl && (addr_rs != 0) && (regw_addr_exe == addr_rs) && wb_wen_exe;
		// BFromEx = rt_used_ctrl && (addr_rt != 0) && (regw_addr_exe == addr_rt) && wb_wen_exe; //?
		// AFromMem = rs_used_ctrl && (addr_rs != 0) && (regw_addr_mem == addr_rs) && wb_wen_mem; //?
		// BFromMem = rt_used_ctrl && (addr_rt != 0) && (regw_addr_mem == addr_rt) && wb_wen_mem; //?

		AfromEXLW = rs_used_ctrl && (regw_addr_exe == addr_rs) && wb_wen_exe && mem_ren_exe && (!mem_wen_ctrl);
		BfromEXLW = rt_used_ctrl && (regw_addr_exe == addr_rt) && wb_wen_exe && mem_ren_exe && (!mem_wen_ctrl);
		
		reg_stall = AfromEXLW || BfromEXLW;	
		// reg_stall = AFromEx || BFromEx || AFromMem || BFromMem;		
	end

	reg last_wb_wen_mem, last_wb_wen_wb;
	reg [4:0] last_addr_rs, last_addr_rt;
	initial last_addr_rt = 0;
	always @(posedge clk) begin
		last_wb_wen_mem <= wb_wen_mem;
		last_wb_wen_wb <= wb_wen_wb;
		last_addr_rs <= addr_rs;
		// last_addr_rt <= addr_rt;
	end


	// reg [31:0] addr_rs_exe, addr_rs_mem, addr_rt_exe, addr_rt_mem;

	always @(*) begin
		// if(wb_wen_mem && (regw_addr_mem !=0) && (regw_addr_mem == last_addr_rs) && (wb_data_src_mem == WB_DATA_ALU))
		if(wb_wen_mem && (regw_addr_mem !=0) && (regw_addr_mem == last_addr_rs) && (wb_data_src_mem == WB_DATA_ALU))
			fwd_a_ctrl = 2'b01;
		else if(wb_wen_wb &&(regw_addr_wb!=0) && (regw_addr_mem !=last_addr_rs) &&(regw_addr_wb==last_addr_rs))
			fwd_a_ctrl = 2'b10;
		else
			fwd_a_ctrl = 2'b00;
	end

	always @(*) begin
		if(wb_wen_mem &&(regw_addr_mem !=0) && (regw_addr_mem == last_addr_rt) && (wb_data_src_mem == WB_DATA_ALU) && (mem_wen_exe == 0))
			fwd_b_ctrl = 2'b01;
		else if(wb_wen_wb &&(regw_addr_wb!=0) &&(regw_addr_mem !=last_addr_rt) &&(regw_addr_wb==last_addr_rt))
			fwd_b_ctrl = 2'b10;
		else
			fwd_b_ctrl = 2'b00;
	end

	// always @(*) begin
	// 	if(wb_wen_mem && (regw_addr_mem !=0) && (regw_addr_mem == addr_rs))
	// 		fwd_a_ctrl = 2'b01;
	// 	else if(wb_wen_wb &&(regw_addr_wb!=0) && (regw_addr_mem !=addr_rs) &&(regw_addr_wb==addr_rs))
	// 		fwd_a_ctrl = 2'b10;
	// 	else
	// 		fwd_a_ctrl = 2'b00;

	// 	if(wb_wen_mem &&(regw_addr_mem !=0) && (regw_addr_mem == addr_rt))
	// 		fwd_b_ctrl = 2'b01;
	// 	else if(wb_wen_wb &&(regw_addr_wb!=0) &&(regw_addr_mem !=addr_rt) &&(regw_addr_wb==addr_rt))
	// 		fwd_b_ctrl = 2'b10;
	// 	else
	// 		fwd_b_ctrl = 2'b00;
	// end

	always @(*) begin
		fwd_m_ctrl = (inst_data_mem[20:16] == regw_addr_wb) && mem_wen_mem && wb_wen_wb;
	end
	
	always @(*) begin
		opa_id = data_rs;
		opb_id = data_rt;
		case (exe_b_src_ctrl)
			EXE_B_RT: opb_id = data_rt; //?
			EXE_B_IMM: opb_id = data_imm; //?
		endcase
	end
	
	// EXE stage
	always @(posedge clk) begin
		if (exe_rst) begin
			exe_valid <= 0;
			inst_addr_exe <= 0;
			inst_data_exe <= 0;
			inst_addr_next_exe <= 0;
			regw_addr_exe <= 0;
			opa_exe <= 0;
			opb_exe <= 0;
			data_rt_exe <= 0;
			exe_alu_oper_exe <= 0;
			mem_ren_exe <= 0;
			mem_wen_exe <= 0;
			wb_data_src_exe <= 0;
			wb_wen_exe <= 0;
			is_branch_exe <= 0;
		end
		else if (exe_en) begin
			exe_valid <= id_valid;
			inst_addr_exe <= inst_addr_id;
			inst_data_exe <= inst_data_ctrl;
			inst_addr_next_exe <= inst_addr_next_id; //?
			regw_addr_exe <= regw_addr_id; //?
			opa_exe <= opa_id; //?
			opb_exe <= opb_id; //?
			data_rt_exe <= data_rt;
			exe_alu_oper_exe <= exe_alu_oper_ctrl;
			mem_ren_exe <= mem_ren_ctrl; //?
			mem_wen_exe <= mem_wen_ctrl; //?
			wb_data_src_exe <= wb_data_src_ctrl; //?
			wb_wen_exe <= wb_wen_ctrl; //?
			is_branch_exe <= is_branch_ctrl & (data_rs == data_rt);  // BEQ only
		end
	end
	
	assign
		old_alu_a_exe = is_branch_exe ? inst_addr_next_exe : opa_exe, //?
		old_alu_b_exe = is_branch_exe ? {opb_exe[29:0], 2'b0} : opb_exe;

	assign alu_a_exe = fwd_a_ctrl[1] ?
		regw_data_wb :	(fwd_a_ctrl[0]? // 10
		alu_out_exe :					// 01
		old_alu_a_exe );				// 00

	assign alu_b_exe = fwd_b_ctrl[1] ?
		regw_data_wb :	(fwd_b_ctrl[0]? // 10
		alu_out_exe :					// 01
		old_alu_b_exe );				// 00		
	
	alu ALU (
		.inst(inst_data_exe),
		.a(alu_a_exe),
		.b(alu_b_exe),
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
			opa_mem <= 0;
			data_rt_mem <= 0;
			alu_out_mem <= 0;
			mem_ren_mem <= 0;
			mem_wen_mem <= 0;
			wb_data_src_mem <= 0;
			wb_wen_mem <= 0;
			is_branch_mem <= 0;
			// last_addr_rt <= 0;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		end
		else if (mem_en) begin
			mem_valid <= exe_valid;
			inst_addr_mem <= inst_addr_exe;
			inst_data_mem <= inst_data_exe; //?
			regw_addr_mem <= regw_addr_exe; //?
			opa_mem <= opa_exe; //?
			data_rt_mem <= data_rt_exe; //?
			alu_out_mem <= alu_out_exe; //?
			mem_ren_mem <= mem_ren_exe; //?
			mem_wen_mem <= mem_wen_exe; //?
			wb_data_src_mem <= wb_data_src_exe;
			wb_wen_mem <= wb_wen_exe;
			is_branch_mem <= is_branch_exe;
			// last_addr_rt <= addr_rt;
		end
	end

	always @(*) begin
		regw_data_mem = alu_out_mem;
		case (wb_data_src_mem)
			WB_DATA_ALU: regw_data_mem = alu_out_mem; //?
			WB_DATA_MEM: regw_data_mem = mem_din; //?
		endcase
	end
	
	assign
		mem_ren = mem_ren_mem,
		mem_wen = mem_wen_mem,
		mem_addr = alu_out_mem,
		mem_dout = fwd_m_ctrl ? regw_data_wb : data_rt_mem;

	// WB stage
	reg [31:0] wb_data_src_wb;
	always @(posedge clk) begin
		if (wb_rst) begin
			wb_valid <= 0;
			regw_addr_wb <= 0;
			regw_data_wb <= 0;
			wb_wen_wb <= 0;
			wb_data_src_wb <= 0;
		end
		else if (wb_en) begin
			wb_valid <= 1;
			regw_addr_wb <= regw_addr_mem;
			regw_data_wb <= regw_data_mem;
			wb_wen_wb <= wb_wen_mem;
			wb_data_src_wb <= wb_data_src_mem;

		end
	end

	// always @(*) begin
	// 	wb_valid = wb_en;
	// 	wb_wen_wb = wb_wen_mem & wb_en;
	// 	regw_addr_wb = regw_addr_mem;
	// 	regw_data_wb = regw_data_mem; // Tao
	// end
endmodule
