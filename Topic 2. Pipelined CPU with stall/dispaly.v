module display (
	input wire clk,
	input wire rst,
	input wire [7:0] addr,
	input wire [31:0] data,
	output wire lcd_e,
	output wire lcd_rs,
	output wire lcd_rw,
	output wire [3:0] lcd_dat
	);
	
	reg [255:0] strdata = "* Hello World! ** Hello World! *";
	
	function [7:0] num2str;
		input [3:0] number;
		begin
			if (number < 10)
				num2str = "0" + number;
			else
				num2str = "A" - 10 + number;
		end
	endfunction
	
	genvar i;
	generate for (i=0; i<8; i=i+1) begin: NUM2STR
		always @(posedge clk) begin
			strdata[8*i+7-:8] <= num2str(data[4*i+3-:4]);
		end
	end
	endgenerate
	
	always @(posedge clk) begin
		strdata[71:64] <= " ";
		case (addr[7:5])
			3'b000: strdata[127:72] <= {"REGS-", num2str(addr[5:4]), num2str(addr[3:0])};
			3'b001: case (addr[4:0])
				// datapath debug signals, MUST be compatible with 'debug_data_signal' in 'datapath.v'
				0: strdata[127:72] <= "IF-ADDR";
				1: strdata[127:72] <= "IF-INST";
				2: strdata[127:72] <= "ID-ADDR";
				3: strdata[127:72] <= "ID-INST";
				4: strdata[127:72] <= "EX-ADDR";
				5: strdata[127:72] <= "EX-INST";
				6: strdata[127:72] <= "MM-ADDR";
				7: strdata[127:72] <= "MM-INST";
				8: strdata[127:72] <= "RS-ADDR";
				9: strdata[127:72] <= "RS-DATA";
				10: strdata[127:72] <= "RT-ADDR";
				11: strdata[127:72] <= "RT-DATA";
				12: strdata[127:72] <= "IMMEDAT";
				13: strdata[127:72] <= "ALU-AIN";
				14: strdata[127:72] <= "ALU-BIN";
				15: strdata[127:72] <= "ALU-OUT";
				16: strdata[127:72] <= "BRANCH ";
				17: strdata[127:72] <= "STALL  ";
				18: strdata[127:72] <= "MEMOPER";
				19: strdata[127:72] <= "MEMADDR";
				20: strdata[127:72] <= "MEMDATR";
				21: strdata[127:72] <= "MEMDATW";
				22: strdata[127:72] <= "WB-ADDR";
				23: strdata[127:72] <= "WB-DATA";
				default: strdata[127:72] <= "RESERVE";
			endcase
			3'b010: strdata[127:72] <= {"CP0S-", num2str(addr[5:4]), num2str(addr[3:0])};
			default: strdata[127:72] <= "RESERVE";
		endcase
	end
	
	reg refresh = 0;
	reg [7:0] addr_buf;
	reg [31:0] data_buf;
	
	always @(posedge clk) begin
		addr_buf <= addr;
		data_buf <= data;
		refresh <= (addr_buf != addr) || (data_buf != data);
	end
	
	displcd DISPLCD (
		.CCLK(clk),
		.reset(rst | refresh),
		.strdata(strdata),
		.rslcd(lcd_rs),
		.rwlcd(lcd_rw),
		.elcd(lcd_e),
		.lcdd(lcd_dat)
		);
	
endmodule
