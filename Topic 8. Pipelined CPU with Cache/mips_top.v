`include "define.vh"

/**
 * Top module for MIPS 5-stage pipeline CPU.
 * Author: Zhao, Hongyu, Zhejiang University
 */
 
module mips_top (
	input wire CCLK,
	input wire [3:0] SW,
	input wire BTNN, BTNE, BTNS, BTNW,
	input wire ROTA, ROTB, ROTCTR,
	output wire [7:0] LED,
	output wire LCDE, LCDRS, LCDRW,
	output wire [3:0] LCDDAT
	);
	
	// anti-jitter
	wire [3:0] switch;
	wire btn_reset, btn_step, btn_int;
	wire disp_prev, disp_next;
	reg btn_int_prev,real_int;
	wire inst_mem_cs,inst_mem_we;
	wire [31:0]inst_mem_addr;
	wire [31:0]inst_mem_dout;
	wire [31:0]inst_mem_din;
	wire inst_mem_ack;
	wire data_mem_cs,data_mem_we;
	wire [31:0]data_mem_addr;
	wire [31:0]data_mem_dout;
	wire [31:0]data_mem_din;
	wire data_mem_ack;
	`ifndef SIMULATING
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW0 (.clk(CCLK), .rst(1'b0), .sig_i(SW[0]), .sig_o(switch[0]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW1 (.clk(CCLK), .rst(1'b0), .sig_i(SW[1]), .sig_o(switch[1]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW2 (.clk(CCLK), .rst(1'b0), .sig_i(SW[2]), .sig_o(switch[2]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_SW3 (.clk(CCLK), .rst(1'b0), .sig_i(SW[3]), .sig_o(switch[3]));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(2000), .INIT_VALUE(0))
		AJ_ROTA (.clk(CCLK), .rst(1'b0), .sig_i(ROTA), .sig_o(disp_prev));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(2000), .INIT_VALUE(0))
		AJ_ROTB (.clk(CCLK), .rst(1'b0), .sig_i(ROTB), .sig_o(disp_next));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_ROTCTR (.clk(CCLK), .rst(1'b0), .sig_i(ROTCTR), .sig_o());
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_BTNE (.clk(CCLK), .rst(1'b0), .sig_i(BTNE), .sig_o());
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_BTNS (.clk(CCLK), .rst(1'b0), .sig_i(BTNS), .sig_o(btn_step));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(10000), .INIT_VALUE(0))
		AJ_BTNW (.clk(CCLK), .rst(1'b0), .sig_i(BTNW), .sig_o(btn_int));
	anti_jitter #(.CLK_FREQ(50), .JITTER_MAX(20000), .INIT_VALUE(1))
		AJ_BTNN (.clk(CCLK), .rst(1'b0), .sig_i(BTNN), .sig_o(btn_reset));
	`else
	assign
		switch = SW,
		disp_prev = ROTA,
		disp_next = ROTB,
		btn_step = BTNS,
		btn_int = BTNW,
		btn_reset = BTNN;

	`endif
	
	// clock generator
	wire clk_cpu, clk_disp;
	wire locked;
	reg rst_all;
	reg [15:0] rst_count = 16'hFFFF;
	
	clk_gen CLK_GEN (
		.clk_pad(CCLK),
		.clk_100m(),
		.clk_50m(clk_disp),
		.clk_25m(),
		.clk_10m(clk_cpu),
		.locked(locked)
		);
		
	always @(posedge clk_cpu) begin
		btn_int_prev <= btn_int;
	end
	always @(posedge clk_cpu) begin
		real_int <= 0;
		if (~btn_int_prev && btn_int) 
			real_int <= 1;
	end
	//initial begin
		//rst_count = 0;
	//end
	
	always @(posedge clk_cpu) begin
		rst_all <= (rst_count != 0);
		rst_count <= {rst_count[14:0], (btn_reset | (~locked))};
	end
	
	// display
	reg [4:0] disp_addr0, disp_addr1, disp_addr2, disp_addr3;
	wire [31:0] disp_data;
	
	reg disp_prev_buf, disp_next_buf;
	always @(posedge clk_cpu) begin
		disp_prev_buf <= disp_prev;
		disp_next_buf <= disp_next;
	end
	
	always @(posedge clk_cpu) begin
		if (rst_all) begin
			disp_addr0 <= 0;
			disp_addr1 <= 0;
			disp_addr2 <= 0;
			disp_addr3 <= 0;
		end
		else if (~disp_prev_buf && disp_prev && ~disp_next) case (switch[1:0])
			0: disp_addr0 <= disp_addr0 - 1'h1;
			1: disp_addr1 <= disp_addr1 - 1'h1;
			2: disp_addr2 <= disp_addr2 - 1'h1;
			3: disp_addr3 <= disp_addr3 - 1'h1;
		endcase
		else if (~disp_next_buf && disp_next && ~disp_prev) case (switch[1:0])
			0: disp_addr0 <= disp_addr0 + 1'h1;
			1: disp_addr1 <= disp_addr1 + 1'h1;
			2: disp_addr2 <= disp_addr2 + 1'h1;
			3: disp_addr3 <= disp_addr3 + 1'h1;
		endcase
	end
	
	reg [4:0] disp_addr;
	always @(*) begin
		case (switch[1:0])
			0: disp_addr = disp_addr0;
			1: disp_addr = disp_addr1;
			2: disp_addr = disp_addr2;
			3: disp_addr = disp_addr3;
		endcase
	end
	
	display DISPLAY (
		.clk(clk_disp),
		.rst(rst_all),
		.addr({2'b0, switch[0], disp_addr[4:0]}),
		.data(disp_data),
		.lcd_e(LCDE),
		.lcd_rs(LCDRS),
		.lcd_rw(LCDRW),
		.lcd_dat(LCDDAT)
		);
	
	assign LED = {4'b0, switch};
	
	// instruction signals
	wire inst_ren;
	wire [31:0] inst_addr;
	wire [31:0] inst_data;
	wire inst_stall;
	wire mem_stall;
	// memory signals
	wire mem_ren, mem_wen;
	wire [31:0] mem_addr;
	wire [31:0] mem_data_r;
	wire [31:0] mem_data_w;
	
	// mips core
	mips_core MIPS_CORE (
		.clk(clk_cpu),
		.rst(rst_all),
		`ifdef DEBUG
		.debug_en(switch[3]),
		.debug_step(btn_step),
		.debug_addr({switch[0], disp_addr[4:0]}),
		.debug_data(disp_data),
		`endif
		.inst_ren(inst_ren),
		.inst_addr(inst_addr),
		.inst_data(inst_data),
		.inst_stall(inst_stall),
		.mem_ren(mem_ren),
		.mem_wen(mem_wen),
		.mem_addr(mem_addr),
		.mem_dout(mem_data_w),
		.mem_din(mem_data_r),
		.mem_stall(mem_stall),
		.ir_in(real_int)
		);
	
	cmu INST_CMU (
		.clk(clk_cpu),
		.rst(rst_all),
		.addr_rw(inst_addr),
		.en_r(inst_ren),
		.data_r(inst_data),
		.en_w(1'b0),
		.data_w(0),
		.stall(inst_stall),
		.mem_cs_o(inst_mem_cs),
		.mem_we_o(inst_mem_we),
		.mem_addr_o(inst_mem_addr),
		.mem_data_i(inst_mem_dout),
		.mem_data_o(inst_mem_din),
		.mem_ack_i(inst_mem_ack)
		);
	
	// IF YOU ARE NOT SURE ABOUT INITIALIZING MEMORY USING 'READMEMH', PLEASE REPLACE BELOW MODULE TO IP CORE
	inst_rom #(
		.ADDR_WIDTH(6),
		.CLK_DELAY(8)
		) INST_ROM (
		.clk(clk_cpu),
		.rst(rst_all),
		//.addr(0),
		.addr({2'b0, inst_addr[31:2]}),
		//.addr(inst_addr),
		.ren(inst_mem_cs & ~inst_mem_we),
		.inst(inst_mem_dout),
		.stall(),
		.ack(inst_mem_ack)
		);

	cmu DATA_CMU (
		.clk(clk_cpu),
		.rst(rst_all),
		.addr_rw(mem_addr),
		.en_r(mem_ren),
		.data_r(mem_data_r),
		.en_w(mem_wen),
		.data_w(mem_data_w),
		.stall(mem_stall),
		.mem_cs_o(data_mem_cs),
		.mem_we_o(data_mem_we),
		.mem_addr_o(data_mem_addr),
		.mem_data_i(data_mem_dout),
		.mem_data_o(data_mem_din),
		.mem_ack_i(data_mem_ack)
		);
	
	// IF YOU ARE NOT SURE ABOUT INITIALIZING MEMORY USING 'READMEMH', PLEASE REPLACE BELOW MODULE TO IP CORE
	data_ram #(
		.ADDR_WIDTH(5),
		.CLK_DELAY(8)
		) DATA_RAM (
		.clk(clk_cpu),
		.rst(rst_all),
		.addr({2'b0, data_mem_addr[31:2]}),
		.ren(data_mem_cs & ~data_mem_we),
		.wen(data_mem_cs & data_mem_we),
		.din(data_mem_din),
		.dout(data_mem_dout),
		.stall(),
		.ack(data_mem_ack)
		);
	
endmodule
