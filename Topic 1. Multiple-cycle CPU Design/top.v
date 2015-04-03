module top(input wire CCLK, BTN0, BTN1, BTN2, BTN3, output wire [3:0]LED, output reg LED1, output wire LCDE, LCDRS, LCDRW, output wire [3:0]LCDDAT);
  
   wire			  clk_1ms;
	wire          clk;
	wire          rst;         
	wire [31:0]   raddr;   
	wire [31:0]   waddr;
	wire [31:0]   mem_data;
	
	wire 			  zero;
	wire			  write_pc;
	wire          iord;
	wire			  write_mem;
	wire          write_dr;
	wire          write_ir;
	wire			  memtoreg;
	wire          regdst;
	wire [1:0]    pcsource;
	wire          write_c;
	wire [1:0]    alu_ctrl;
	wire 			  alu_srcA;
	wire [1:0]    alu_srcB;
	wire          write_a;
	wire          write_b;
	wire          write_reg;

	wire [31:0]   alu_out;
	wire [31:0]   rdata_A;
	wire [31:0]   rdata_B;
 
	wire [31:0]   pc;
	wire [3:0]    state_out;
	wire [3:0]    insn_type;
	wire [3:0]    insn_code;
	wire [2:0]    insn_stage;
	wire [7:0]	  r6out;
	wire [3:0]    SW;
	
	reg  [31:0]   ir_data;
	reg  [31:0]   dr_data;
	reg  [31:0]   a_data;
	reg  [31:0]   b_data;
	reg  [31:0]   c_data;
	
	clock C1 (CCLK, 25000, clk0);//¡¤??¦Ì?¡Â
	
	pbdebounce M1(clk0, BTN0, BTN0_OUT);
	pbdebounce M2(clk0, BTN1, BTN1_OUT);
	pbdebounce M3(clk0, BTN2, BTN2_OUT);
	pbdebounce M4(clk0, BTN3, BTN3_OUT);
	adder M5(BTN0_OUT, SW);
	
	assign raddr = iord? c_data[31:0] : pc;
	assign waddr = c_data[31:0];
	
	wire [31: 0] reg_out;
	
	assign clk = BTN3_OUT;//¦Ì£¤2??¡äDDclk
	assign rst = BTN2_OUT;//PC??0
	assign LED[3:0] = SW[3:0];
	
	reg [255:0]    strdata;//??¨º?¡Á?¡¤?¡ä?
	reg            cls;//display¦Ì?reset
	reg [31:0]     mem_data_old;
	reg [31:0]     pc_old;
	reg [31:0]		raddr_old;
	reg [31:0]     waddr_old;

	wire [3:0]     lcdd;
	wire rslcd, rwlcd, elcd;

	assign LCDDAT[3] = lcdd[3];
	assign LCDDAT[2] = lcdd[2];
	assign LCDDAT[1] = lcdd[1];
	assign LCDDAT[0] = lcdd[0];
	
	assign LCDRS = rslcd;
	assign LCDRW = rwlcd;
	assign LCDE = elcd;
	
	initial begin
		strdata = "01234567 01 01  0 1 2 1         ";
	end

	display M0 (CCLK, cls, strdata, rslcd, rwlcd, elcd, lcdd);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	
	
	reg reg_selector = 0;
	always @(posedge BTN1_OUT) 
		begin
			reg_selector = ~reg_selector;
			LED1 = reg_selector;
		end
	
	always @(posedge CCLK)
		begin
			//space
			if (reg_selector == 1'b0)
			begin
				strdata[39:32] = 8'h30 + reg_out[15:12] + ((reg_out[15:12] < 8'b1010)? 4'b0 : 4'b0111);
				strdata[31:24] = 8'h30 + reg_out[11:8] + ((reg_out[11:8] < 8'b1010)? 4'b0 : 4'b0111);
				strdata[23:16] = 8'h30 + reg_out[7:4] + ((reg_out[7:4] < 8'b1010)? 4'b0 : 4'b0111);
				strdata[15:8] = 8'h30 + reg_out[3:0] + ((reg_out[3:0] < 8'b1010)? 4'b0 : 4'b0111);
			end
			else
			begin
				strdata[39:32] = 8'h30 + reg_out[31:28] + ((reg_out[31:28] < 8'b1010)? 4'b0 : 4'b0111);
				strdata[31:24] = 8'h30 + reg_out[27:24] + ((reg_out[27:24] < 8'b1010)? 4'b0 : 4'b0111);
				strdata[23:16] = 8'h30 + reg_out[23:20] + ((reg_out[23:20] < 8'b1010)? 4'b0 : 4'b0111);
				strdata[15:8] = 8'h30 + reg_out[19:16] + ((reg_out[19:16] < 8'b1010)? 4'b0 : 4'b0111);
			end
		end
	
	reg [3:0] SW_old;
	reg BTN1_OUT_old;
	reg BTN2_OUT_old;
	always @(CCLK) begin
			
		if ((BTN3_OUT == 1'b1) || (mem_data != mem_data_old) || (pc != pc_old) || (raddr != raddr_old) || (waddr != waddr_old) || (SW != SW_old) || (BTN1_OUT == 1'b1) || (BTN2_OUT == 1'b1)  ) begin
			strdata[255:248] = 8'h30 + mem_data[31:28] + ((mem_data[31:28] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[247:240] = 8'h30 + mem_data[27:24] + ((mem_data[27:24] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[239:232] = 8'h30 + mem_data[23:20] + ((mem_data[23:20] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[231:224] = 8'h30 + mem_data[19:16] + ((mem_data[19:16] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[223:216] = 8'h30 + mem_data[15:12] + ((mem_data[15:12] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[215:208] = 8'h30 + mem_data[11:8]  + ((mem_data[11:8] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[207:200] = 8'h30 + mem_data[7:4]   + ((mem_data[7:4] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[199:192] = 8'h30 + mem_data[3:0]   + ((mem_data[3:0] < 4'b1010)? 4'b0 : 4'b0111);
			//space
			//strdata[191:184] = " ";
			//2 4-bit raddr
			strdata[183:176] = 8'h30 + raddr[7:4] + ((raddr[7:4] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[175:168] = 8'h30 + raddr[3:0] + ((raddr[3:0] < 4'b1010)? 4'b0 : 4'b0111);
			//space
			//strdata[167:160] = " ";
			//2 4-bit waddr
			strdata[159:152] = 8'h30 + waddr[7:4] + ((waddr[7:4] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[151:144] = 8'h30 + waddr[3:0] + ((waddr[3:0] < 4'b1010)? 4'b0 : 4'b0111);
			
			//secondline
			strdata[127:120] = 8'h30 + state_out + ((state_out < 4'b1010)? 4'b0 : 4'b0111);
			//space
			strdata[111:104] = 8'h30 + insn_type + ((insn_type < 4'b1010)? 4'b0 : 4'b0111);
			//space
			strdata[95:88] = 8'h30 + insn_code + ((insn_code < 4'b1010)? 4'b0 : 4'b0111);
			//space
			//2 4-bit stage
			//strdata[79:72] = 8'h30;// + pc[7:4] + ((pc[7:4] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[79:72] = 8'h30 + insn_stage[2:0];
			
			//space
			//2 4-bit pc
			strdata[63:56] = 8'h30 + pc[7:4] + ((pc[7:4] < 4'b1010)? 4'b0 : 4'b0111);
			strdata[55:48] = 8'h30 + pc[3:0] + ((pc[3:0] < 4'b1010)? 4'b0 : 4'b0111);
			

			cls = 1;
			
			pc_old <= pc;
			mem_data_old <= mem_data;
			raddr_old <= raddr;
			waddr_old <= waddr;
			SW_old <= SW;
			BTN1_OUT_old <= reg_selector;
			BTN2_OUT_old <= BTN2_OUT;
		end
		else
			cls = 0;
	end

	memory x_memory(
		.addra(raddr),
		.addrb(waddr),
		.clka(clk),
		.clkb(clk),
		.dinb(b_data),
		.douta(mem_data),
		.web(write_mem));   
       
	ctrl	x_ctrl(clk, rst, ir_data, zero,
		write_pc, iord, write_mem, write_dr, write_ir, memtoreg, regdst, 
		pcsource, write_c, alu_ctrl, alu_srcA, alu_srcB, write_a, write_b, write_reg,
		state_out, insn_type, insn_code, insn_stage);  

	pcm x_pcm(clk, rst, alu_out, c_data, ir_data, pcsource, write_pc, pc);
	
	always @(write_ir) begin
		if (write_ir)
			ir_data <= mem_data;
	end
	
	always @(write_dr) begin
		if (write_dr)
			dr_data <= mem_data;
	end
	
	reg_wrapper x_reg_wrapper(clk, rst, ir_data, dr_data, c_data, memtoreg, regdst, write_reg,
										 rdata_A, rdata_B, SW, reg_out, CCLK); 

	always @(write_a) begin
 		if (write_a)
			a_data <= rdata_A;
	end
	
	always @(write_b) begin
 		if (write_b)
			b_data <= rdata_B;
	end

	alu_wrapper x_alu_wrapper(a_data, b_data, ir_data, pc, 
		alu_srcA, alu_srcB, alu_ctrl,
		zero, alu_out);
										 
	always @(write_c) begin
 		if (write_c)
			c_data <= alu_out;
	end
	
endmodule