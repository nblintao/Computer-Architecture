
//Register File
module reg_wrapper(clk, rst, ir_data, dr_data, c_data, memtoreg, regdst, write_reg,
						rdata_A, rdata_B, reg_addr, reg_out, CCLK);
	input         	clk;
	input				rst;
	input	[31:0]  	ir_data;
	input	[31:0]  	dr_data;
	input [31:0]	c_data;
	input				memtoreg;
	input				regdst;
	input				write_reg;
	output [31:0]	rdata_A;
	output [31:0]	rdata_B;
	wire [6:0]	r6out;
	
	input  [3:0]   reg_addr;
	output [31:0]  reg_out;
	input CCLK;
	
	wire [4:0]		rs;
	wire [4:0]		rt;
	wire [4:0]		rd;
	wire [4:0]		nd;
	wire [31:0]	ni;
	
	wire [31:0]    reg_out;
	wire CCLK;
	
	assign rs = ir_data[25:21];
	assign rt = ir_data[20:16];
	assign rd = ir_data[15:11];
	assign nd = regdst? rd : rt;
	assign ni = memtoreg? dr_data : c_data;
	
	regs  x_regs( .clk(clk),
					  .rst(rst),
					  .rnum_A(rs),
					  .rnum_B(rt),
					  .wnum(nd),
					  .wdata(ni),
					  .we(write_reg),
					  .rdata_A(rdata_A),
					  .rdata_B(rdata_B),
					  .r6out(r6out),
					  .reg_addr(reg_addr),
					  .reg_out(reg_out),
					  .CCLK(CCLK));

endmodule

//regs module
module regs(clk, rst, rnum_A, rnum_B, wnum, wdata, we, rdata_A, rdata_B, r6out, reg_addr, reg_out, CCLK);
    input        clk;
	input        rst;
	input [4:0]  rnum_A;
	input [4:0]  rnum_B;
	input [4:0]  wnum;
	input [31:0] wdata;
	input        we;
	output [31:0] rdata_A;
	output [31:0] rdata_B;
   output [6:0] r6out;
	
	input [3:0] reg_addr;
	output [31:0] reg_out;
	input CCLK;
	
	wire         clk;
	wire         rst;
	wire [4:0]   rnum_A;
	wire [4:0]   rnum_B;
	wire [4:0]   wnum;
	wire [31:0]  wdata;
	wire         we;
   wire [7:0]   r6out;
	reg [31:0]   rdata_A;
	reg [31:0]   rdata_B;
	
	reg [31:0]   reg_out;
	wire CCLK;

	reg [31:0]   r0;
	reg [31:0]   r1;
	reg [31:0]   r2;
	reg [31:0]   r3;
	reg [31:0]   r4;
	reg [31:0]   r5;
	reg [31:0]   r6;
	reg [31:0]   r7;
	reg [31:0]   r8;
	reg [31:0]   r9;
	reg [31:0]   r10;
	reg [31:0]   r11;
	reg [31:0]   r12;
	reg [31:0]   r13;
	reg [31:0]   r14;
	reg [31:0]   r15;
   assign  r6out=r6[7:0];
	
	always @ (posedge CCLK)
		begin
			case (reg_addr)
				4'b0000: reg_out <= r0;
				4'b0001: reg_out <= r1;
				4'b0010: reg_out <= r2;
				4'b0011: reg_out <= r3;
				4'b0100: reg_out <= r4;
				4'b0101: reg_out <= r5;
				4'b0110: reg_out <= r6;
				4'b0111: reg_out <= r7;
				4'b1000: reg_out <= r8;
				4'b1001: reg_out <= r9;
				4'b1010: reg_out <= r10;
				4'b1011: reg_out <= r11;
				4'b1100: reg_out <= r12;
				4'b1101: reg_out <= r13;
				4'b1110: reg_out <= r14;
				4'b1111: reg_out <= r15;
			endcase
		end
	
	always @ (posedge clk or posedge rst)
	begin
 		if (rst == 1)
		begin
			r0 <= 0;
			r1 <= 0;
			r2 <= 0;
			r3 <= 0;
			r4 <= 0;
			r5 <= 0;
			r6 <= 0;
			r7 <= 0;
			r8 <= 0;
			r9 <= 0;
			r10 <= 0;
			r11 <= 0;
			r12 <= 0;
			r13 <= 0;
			r14 <= 0;
			r15 <= 0;
		end
		else if (we == 1)
		begin
			case (wnum)
				5'b00000: r0 <= 0;
				5'b00001: r1 <= wdata;
				5'b00010: r2 <= wdata;
				5'b00011: r3 <= wdata;
				5'b00100: r4 <= wdata;
				5'b00101: r5 <= wdata;
				5'b00110: r6 <= wdata;
				5'b00111: r7 <= wdata;
				5'b01000: r8 <= wdata;
				5'b01001: r9 <= wdata;
				5'b01010: r10 <= wdata;
				5'b01011: r11 <= wdata;
				5'b01100: r12 <= wdata;
				5'b01101: r13 <= wdata;
				5'b01110: r14 <= wdata;
				5'b01111: r15 <= wdata;
		      default:  r0 <= 0;
			endcase
	  end
	  else 
	  begin
		 case(rnum_A)
			 5'b00000: rdata_A <= r0;
			 5'b00001: rdata_A <= r1;
			 5'b00010: rdata_A <= r2;
			 5'b00011: rdata_A <= r3;
			 5'b00100: rdata_A <= r4;
			 5'b00101: rdata_A <= r5;
			 5'b00110: rdata_A <= r6;
			 5'b00111: rdata_A <= r7;
			 5'b01000: rdata_A <= r8;
			 5'b01001: rdata_A <= r9;
			 5'b01010: rdata_A <= r10;
			 5'b01011: rdata_A <= r11;
			 5'b01100: rdata_A <= r12;
			 5'b01101: rdata_A <= r13;
			 5'b01110: rdata_A <= r14;
			 5'b01111: rdata_A <= r15;
			 default:  rdata_A <= r0;
		 endcase 
         	 
		 case(rnum_B)
		    5'b00000: rdata_B <= r0;
			 5'b00001: rdata_B <= r1;
			 5'b00010: rdata_B <= r2;
			 5'b00011: rdata_B <= r3;
			 5'b00100: rdata_B <= r4;
			 5'b00101: rdata_B <= r5;
			 5'b00110: rdata_B <= r6;
			 5'b00111: rdata_B <= r7;
			 5'b01000: rdata_B <= r8;
			 5'b01001: rdata_B <= r9;
			 5'b01010: rdata_B <= r10;
			 5'b01011: rdata_B <= r11;
			 5'b01100: rdata_B <= r12;
			 5'b01101: rdata_B <= r13;
			 5'b01110: rdata_B <= r14;
			 5'b01111: rdata_B <= r15;
			 default:  rdata_B <= r0;
		 endcase
	  end
	end
endmodule

//pcm module
module pcm(clk, rst, alu_out, c_data, ir_data, pcsource, write_pc, pc);
	
	input         	clk;
	input         	rst;
	input [31:0]	alu_out;
	input [31:0]	c_data;
	input [31:0]	ir_data;
	input [1:0]		pcsource;
	input 			write_pc;
	
	output [31:0]	pc;
	
	reg [31:0]		pc;
	wire [31:0]		npc;
	wire [31:0]		addr;
	wire 				write_pc;
	
	initial begin
		pc = 32'h00000000;
	end
	
	assign addr = {pc[31:26], ir_data[25:0]};
 	assign npc = (pcsource == 2'b00)? alu_out : ((pcsource == 2'b01)? c_data : addr);
	
//	always @ (posedge write_pc) begin
//		pc <= npc;
	always @ (posedge clk or posedge rst) begin
		if(write_pc)
			pc <= npc;
		if (rst) begin
			pc <= 32'h00000000;
		end
	end

endmodule