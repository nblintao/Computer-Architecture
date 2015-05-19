`include "define.vh"

/**
 * Clock generator.
 * Author: Zhao, Hongyu, Zhejiang University
 */
 
module clk_gen (
	input wire clk_pad,  // input clock, 50MHz
	output wire clk_100m,
	output wire clk_50m,
	output wire clk_25m,
	output wire clk_10m,
	output wire locked
	);
	
	wire clk_pad_buf;
	wire clk_100m_unbuf;
	wire clk_50m_unbuf;
	wire clk_25m_unbuf;
	wire clk_10m_unbuf;
	
	//IBUFG CLK_PAD_BUF (.I(clk_pad), .O(clk_pad_buf));
	assign clk_pad_buf = clk_pad;
	
	DCM_SP #(
		.CLKDV_DIVIDE(2),
		.CLKFX_DIVIDE(10),
		.CLKFX_MULTIPLY(2),
		.CLKIN_DIVIDE_BY_2("FALSE"),
		.CLKIN_PERIOD(10.0),
		.CLK_FEEDBACK("2X"),
		.CLKOUT_PHASE_SHIFT("NONE"),
		.PHASE_SHIFT(0),
		.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
		.STARTUP_WAIT("TRUE")
		) DCM_SYS (
		.CLKIN(clk_pad_buf),
		.CLKFB(clk_100m),
		.RST(1'b0),
		.CLK0(clk_50m_unbuf),
		.CLK90(),
		.CLK180(),
		.CLK270(),
		.CLK2X(clk_100m_unbuf),
		.CLK2X180(),
		.CLKDV(clk_25m_unbuf),
		.CLKFX(clk_10m_unbuf),
		.CLKFX180(),
		.LOCKED(locked),
		.STATUS(),
		.DSSEN(1'b0),
		.PSCLK(1'b0),
		.PSEN(1'b0),
		.PSINCDEC(1'b0),
		.PSDONE()
		);
	
	BUFG
		CLK_BUF_100M (.I(clk_100m_unbuf), .O(clk_100m)),
		CLK_BUF_50M (.I(clk_50m_unbuf), .O(clk_50m)),
		CLK_BUF_25M (.I(clk_25m_unbuf), .O(clk_25m)),
		CLK_BUF_10M (.I(clk_10m_unbuf), .O(clk_10m));
	
endmodule
