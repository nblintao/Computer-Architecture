// Spartan-3E Starter Board
// Liquid Crystal Display Test lcdtest.v

module lcdtest(input CCLK, BTN2, input [3:0] SW, output LCDRS, LCDRW, LCDE, 
					output [3:0] LCDDAT, output [7:0] LED);
					
wire [3:0] lcdd;
wire rslcd, rwlcd, elcd;
wire debpb0;

reg [255:0]strdata = "0123456789abcdefHello world!0000";
reg [3:0] temp=0;

assign LCDDAT[3]=lcdd[3];
assign LCDDAT[2]=lcdd[2];
assign LCDDAT[1]=lcdd[1];
assign LCDDAT[0]=lcdd[0];

assign LCDRS=rslcd;
assign LCDRW=rwlcd;
assign LCDE=elcd;

assign LED[0] = SW[0];
assign LED[1] = SW[1];
assign LED[2] = SW[2];
assign LED[3] = SW[3];
assign LED[4] = temp[0];
assign LED[5] = temp[1];
assign LED[6] = temp[2];
assign LED[7] = temp[3];

display M0 (CCLK, debpb0, strdata, rslcd, rwlcd, elcd, lcdd);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
clock M2 (CCLK, 25000, clk);
pbdebounce M1 (clk, BTN2, debpb0);

always @(posedge debpb0)
begin
//	if(debpb0 == 1'b1) begin
		temp = temp +1;
		case(temp) 
		4'b0000:strdata[7:0] <= "0";
		4'b0001:strdata[7:0] <= "1";
		4'b0010:strdata[7:0] <= "2";
		4'b0011:strdata[7:0] <= "3";
		4'b0100:strdata[7:0] <= "4";
		4'b0101:strdata[7:0] <= "5";
		4'b0110:strdata[7:0] <= "6";
		4'b0111:strdata[7:0] <= "7";
		4'b1000:strdata[7:0] <= "8";
		4'b1001:strdata[7:0] <= "9";
		4'b1010:strdata[7:0] <= "A";
		4'b1011:strdata[7:0] <= "B";
		4'b1100:strdata[7:0] <= "C";
		4'b1101:strdata[7:0] <= "D";
		4'b1110:strdata[7:0] <= "E";
		4'b1111:strdata[7:0] <= "F";
		default:strdata[7:0] <= "0";
		endcase
//	end
end

endmodule

module display(input CCLK, reset,input [255:0]strdata, output rslcd, rwlcd, elcd, 
					output [3:0] lcdd);
wire [7:0] lcddatin;
					
lcd M0 (CCLK, resetlcd, clearlcd, homelcd, datalcd, addrlcd,
			lcdreset, lcdclear, lcdhome, lcddata, lcdaddr,
			rslcd, rwlcd, elcd, lcdd, lcddatin, initlcd);
			
genlcd M1 (CCLK, reset, strdata, resetlcd, clearlcd, homelcd, datalcd,
				addrlcd, initlcd, lcdreset, lcdclear, lcdhome,
				lcddata, lcdaddr, lcddatin);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        				
endmodule


module genlcd(input CCLK, debpb0, input [255:0]strdata, output reg resetlcd,
					output reg clearlcd, output reg homelcd,
					output reg datalcd, output reg addrlcd,
					output reg initlcd, input lcdreset, lcdclear,
					input lcdhome, lcddata, lcdaddr,
					output reg [7:0] lcddatin);
					
reg [3:0] gstate;		// state register

integer i;
	
always@(posedge CCLK)
	begin
		if (debpb0==1)
			begin
				resetlcd=0;
				clearlcd=0;
				homelcd=0;
				datalcd=0;
				gstate=0;
			end
		else
		
		case (gstate)
			0: begin
					initlcd=1;
					gstate=1;
				end
			1:	begin
					initlcd=0;
					gstate=2;
				end
			2:	begin
					resetlcd=1;
					if (lcdreset==1)
						begin
						   resetlcd=0;
							gstate=3;
						end
				end
			3: begin
					initlcd=1;
					gstate=4;
				end
			4:	begin
					initlcd=0;
					gstate=5;
				end
			5: begin
					clearlcd=1;
					if (lcdclear==1)
						begin
							clearlcd=0;
							gstate=6;
						end
				end
			6: begin
					initlcd=1;
					gstate=7;
				end
			7:	begin
					initlcd=0;
					i=255;
					gstate=8;
				end
			8: begin  
					if(i>127)
						lcddatin[7:0]=8'b0000_0000;
					else
						lcddatin[7:0]=8'b0100_0000;
						
					addrlcd=1;
					if (lcdaddr==1)
						begin
							addrlcd=0;
							gstate=9;
						end
				end
			9:	begin
					initlcd=1;
					gstate=10;
				end
			10: begin
					initlcd=0;
					gstate=11;
				end
			11: begin
					lcddatin[7:0]=strdata[i-:8];
					datalcd=1;
					if (lcddata==1)
						begin
							datalcd=0;
							gstate=12;
						end
				end
			12: begin
					initlcd=1;
					gstate=13;
				end
			13: begin
					initlcd=0;
					gstate=14;
				end
			14: begin
					i=i-8;
					if (i<0)
						gstate=15;
					else if (i==127)
						gstate=8;
					else
						gstate=11;
				end
			15: gstate=15;
			default: gstate=15;
		endcase

	end

endmodule
