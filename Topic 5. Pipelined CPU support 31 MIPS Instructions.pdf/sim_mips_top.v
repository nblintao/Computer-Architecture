`timescale 1ns / 1ps

`include "define.vh"	

module sim_mips_top;

	// Inputs
	reg CCLK;
	reg [3:0] SW;
	reg BTNN;
	reg BTNE;
	reg BTNS;
	reg BTNW;
	reg ROTA;
	reg ROTB;
	reg ROTCTR;

	// Outputs
	wire [7:0] LED;
	wire LCDE;
	wire LCDRS;
	wire LCDRW;
	wire [3:0] LCDDAT;

	// Instantiate the Unit Under Test (UUT)
	mips_top uut (
		.CCLK(CCLK), 
		.SW(SW), 
		.BTNN(BTNN), 
		.BTNE(BTNE), 
		.BTNS(BTNS), 
		.BTNW(BTNW), 
		.ROTA(ROTA), 
		.ROTB(ROTB), 
		.ROTCTR(ROTCTR), 
		.LED(LED), 
		.LCDE(LCDE), 
		.LCDRS(LCDRS), 
		.LCDRW(LCDRW), 
		.LCDDAT(LCDDAT)
	);

	initial begin
		// Initialize Inputs
		CCLK = 0;
		SW = 0;
		SW[3]=1;
		BTNN = 0;
		BTNE = 0;
		BTNS = 0;
		BTNW = 0;
		ROTA = 0;
		ROTB = 0;
		ROTCTR = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	
	initial forever #10 CCLK = ~CCLK;
	initial forever #20 BTNS = ~BTNS;
	
	//always begin
	//	BTNS=1;
	//	#10;
	//	BTNS=0;
	//	#100;
	//end
      
endmodule

