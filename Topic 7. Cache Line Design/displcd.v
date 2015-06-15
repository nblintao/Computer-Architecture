`timescale 1ns / 1ps
// Spartan-3E Starter Board
// Liquid Crystal Display

module displcd(input CCLK, reset,input [255:0]strdata, output rslcd, rwlcd, elcd, 
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
			/*15: begin
					resetlcd=0;
					clearlcd=0;
					homelcd=0;
					datalcd=0;
					gstate=0;
				end*/
			default: gstate=15;
		endcase

	end
endmodule


module lcd(input CCLK, resetlcd, clearlcd, homelcd,
				datalcd, addrlcd, output reg lcdreset,
				output reg lcdclear, output reg lcdhome,
				output reg lcddata, output reg lcdaddr,
				output reg rslcd, output reg rwlcd,
				output reg elcd, output reg [3:0] lcdd,
				input [7:0] lcddatin, input initlcd);

reg [18:0] lcdcount;		// counter
reg [5:0] lcdstate;		// LCD state

always@(posedge CCLK)
	begin

// initialize LCD
		if (initlcd==1)
			begin
				lcdstate=0;			// LCD state register
				lcdcount=0;			// LCD delay count
				lcdreset=0;
				lcdclear=0;
				lcdhome=0;
				lcdaddr=0;
				lcddata=0;
			end
			
		else
			lcdcount=lcdcount+1;
			
//reset LCD
		if (resetlcd==1 && lcdreset==0)	//lcd reset
			begin
				rslcd=0;				// register select for command
				rwlcd=0;				// LCD read/write
				
				case (lcdstate)
					0: begin			// send '3'
							lcdd=3;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=1;
								end
						end						
					1: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=2;
								end
						end
					2: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=3;
								end
						end
					3: begin			// wait >4.1 msec (205 000 clock cycles)
							if (lcdcount==262144)
								begin
									lcdcount=0;
									lcdstate=4;
								end
						end
					4: begin			// send '3'
							lcdd=3;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=5;
									end
						end						
					5: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=6;
								end
						end
					6: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=7;
								end
						end
					7: begin			// wait >100 usec (5000 clock cycles)
							if (lcdcount==8192)
								begin
									lcdcount=0;
									lcdstate=8;
								end
						end		
					
					8: begin			// send '3'
							lcdd=3;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=9;
									end
						end						
					9: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=10;
								end
						end
					10: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=11;
								end
						end
					11: begin			// wait >40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=12;
								end
						end		
											
					12: begin			// send '2'
							lcdd=2;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=13;
									end
						 end						
					13: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=14;
								end
						 end
					14: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=15;
								end
						 end
					15: begin			// wait >40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=16;
								end
						end		
							
					16: begin			// send '2'  28h function set
							lcdd=2;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=17;
									end
						 end		 
					17: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=18;
								end
						 end
					18: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=19;
								end
						 end
					19: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=20;
								end
  						 end
						
					20: begin			// send '8'
							lcdd=8;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=21;
									end
						 end		 
					21: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=22;
								end
						 end
					22: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=23;
								end
						 end						 
					23: begin			// wait 40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=24;
								end
						end

					24: begin			// send '0'  06h entry mode
							lcdd=0;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=25;
									end
						 end		 
					25: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=26;
								end
						 end
					26: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=27;
								end
						 end						 
					27: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=28;
								end
						 end
						
					28: begin			// send '6'
							lcdd=6;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=29;
									end
						 end		 
					29: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=30;
								end
						 end
					30: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=31;
								end
						 end						 
					31: begin			// wait 40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=32;
								end
						end
						
					32: begin			// send '0'  0Ch display on, enable cursor
							lcdd=0;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=33;
									end
						 end		 
					33: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=34;
								end
						 end
					34: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=35;
								end
						 end						 
					35: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=36;
								end
						end
	
					36: begin			// send 'C'h
							lcdd=12;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=37;
									end
						 end		 
					37: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=38;
								end
						 end
					38: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=39;
								end
						 end						 
					39: begin			// wait 40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=40;
									lcdreset=1;
								end
						 end
					40: lcdstate=40;
					default: lcdstate=40;
				endcase
			end

// send 8-bit data to LCD
		if (datalcd==1 && lcddata==0)			//lcd data
			begin
				rslcd=1;				// register select for data
				rwlcd=0;				// LCD read/write
				
				case (lcdstate)
					0: begin			// send upper nibble
							lcdd[3:0]=lcddatin[7:4];
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=1;
								end
						end						
					1: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=2;
								end
						end
					2: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=3;
								end
						end
					3: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=4;
								end
						end
						
					4: begin			// send lower nibble
							lcdd[3:0]=lcddatin[3:0];
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=5;
									end
						end						
					5: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=6;
								end
						end
					6: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=7;
								end
						end
					7: begin			// wait 40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=8;
									lcddata=1;
								end
						end
					8: lcdstate=8;
					default: lcdstate=8;
				endcase
			end
			
// return cursor home
		if (homelcd==1 && lcdhome==0)		//lcd home
			begin
				rslcd=0;				// register select for command
				rwlcd=0;				// LCD read/write
				
				case (lcdstate)
					0: begin			// send '0'
							lcdd=0;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=1;
								end
						end						
					1: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=2;
								end
						end
					2: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=3;
								end
						end
					3: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=4;
								end
						end
					4: begin			// send '2'
							lcdd=2;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=5;
									end
						end						
					5: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=6;
								end
						end
					6: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=7;
								end
						end
					7: begin			// wait 1.6 msec (80000 clock cycles)
							if (lcdcount==131072)
								begin
									lcdcount=0;
									lcdstate=8;
									lcdhome=1;
								end
						end
					8: lcdstate=8;
					default: lcdstate=8;
				endcase
			end
			
// clear display
		if (clearlcd==1 && lcdclear==0)	//lcd clear
			begin
				rslcd=0;				// register select for command
				rwlcd=0;				// LCD read/write
				
				case (lcdstate)
					0: begin			// send '0'
							lcdd=0;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=1;
								end
						end						
					1: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=2;
								end
						end
					2: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=3;
								end
						end
					3: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=4;
								end
						end
					4: begin			// send '1'
							lcdd=1;
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=5;
									end
						end						
					5: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=6;
								end
						end
					6: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=7;
								end
						end
					7: begin			// wait 1.64 msec (82000 clock cycles)
							if (lcdcount==131072)
								begin
									lcdcount=0;
									lcdstate=8;
									lcdclear=1;
								end
						end
					8: lcdstate=8;
					default: lcdstate=8;
				endcase
			end
			
// set display address
		if (addrlcd==1 && lcdaddr==0)	//lcd display address
			begin
				rslcd=0;				// register select for command
				rwlcd=0;				// LCD read/write
				
				case (lcdstate)
					0: begin
							lcdd[3]=1;
							lcdd[2:0]=lcddatin[6:4];
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=1;
								end
						end						
					1: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=2;
								end
						end
					2: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=3;
								end
						end
					3: begin			// wait 1 usec (50 clock cycles)
							if (lcdcount==64)
								begin
									lcdcount=0;
									lcdstate=4;
								end
						end
					4: begin
							lcdd[3:0]=lcddatin[3:0];
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=5;
									end
						end						
					5: begin
							elcd=1;
							if (lcdcount==32)
								begin
									lcdcount=0;
									lcdstate=6;
								end
						end
					6: begin
							elcd=0;
							if (lcdcount==16)
								begin
									lcdcount=0;
									lcdstate=7;
								end
						end
					7: begin			// wait 40 usec (2000 clock cycles)
							if (lcdcount==2048)
								begin
									lcdcount=0;
									lcdstate=8;
									lcdaddr=1;
								end
						end
					8: lcdstate=8;
					default: lcdstate=8;
				endcase
			end
			
	end
endmodule
