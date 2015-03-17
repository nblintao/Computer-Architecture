
`timescale 1ns / 1ps

module MIO_BUS(clk,
				rst,
				BTN,
				SW,
				mem_w,
				Cpu_data2bus,									//data from CPU
				addr_bus,
				ram_data_out,
				led_out,
				counter_out,
				counter0_out,
				counter1_out,
				counter2_out,

				Cpu_data4bus,									//write to CPU
				ram_data_in,								//from CPU write to Memory
				ram_addr,									//Memory Address signals
				data_ram_we,
				GPIOf0000000_we,
				GPIOe0000000_we,
				counter_we,
				Peripheral_in
				);


	input wire clk, rst, mem_w;
	input wire counter0_out, counter1_out, counter2_out;
	input wire [ 4: 0] BTN;
	input wire [ 7: 0] SW, led_out;
	input wire [31: 0] Cpu_data2bus, ram_data_out, addr_bus, counter_out;
	output reg data_ram_we, GPIOe0000000_we, GPIOf0000000_we, counter_we;
	output reg [31: 0] Cpu_data4bus, ram_data_in, Peripheral_in;
	output reg [ 9: 0] ram_addr;

	reg [ 7: 0] led_in;
	wire counter_over;

	always @(*) begin : proc_RAM_IO_DECODE_SIGNAL
		data_ram_we <= 0;
		counter_we <= 0;
		GPIOf0000000_we <= 0;
		GPIOe0000000_we <= 0;
		ram_addr <= 10'h0;
		ram_data_in <= 32'h0;
		Peripheral_in <= 32'h0;
		Cpu_data4bus <= 32'h0;

		case ( addr_bus[31:12] )
			20'h0000_0 : begin	// 8'h0000_00XX
				data_ram_we <= mem_w;
				ram_addr <= addr_bus[11: 2];
				ram_data_in <= Cpu_data2bus;						// Instructions from [11: 2] 10bits
				Cpu_data4bus <= ram_data_out;
			end
			/*6'hffff_fe : begin	// 6'hffff_fe
				GPIOe0000000_we <= mem_w;
				Peripheral_in <= Cpu_data2bus;
				Cpu_data4bus <= counter_out;
			end
			6'hffff_ff : begin	// 6'hffff_ff
				if ( addr_bus[2] ) begin
					counter_we <= mem_w;
					Peripheral_in <= Cpu_data2bus;
					Cpu_data4bus <= counter_out;
				end
				else begin
					GPIOf0000000_we <= mem_w;
					Peripheral_in <= Cpu_data2bus;
					Cpu_data4bus <= {counter0_out, counter1_out, counter2_out, 9'h0, led_out, BTN, SW};
				end
			end*/
			20'hffff_f : begin
				case ( addr_bus[11: 8] )
					4'he : begin									// 32'hffff_fe00 -- Seven_Seg display
						GPIOe0000000_we <= mem_w;
						Peripheral_in <= Cpu_data2bus;
						Cpu_data4bus <= counter_out;
					end
					4'hf : begin										// 32'hffff_ff00 --
						if ( addr_bus[2] ) begin
							counter_we <= mem_w;						// Counter_Signal
							Peripheral_in <= Cpu_data2bus;				// Write counter lock number
							Cpu_data4bus <= counter_out;
						end
						else begin
							GPIOf0000000_we <= mem_w;					// Led & Btn & Switch
							Peripheral_in <= Cpu_data2bus;				// set counter_ctrl signal
							Cpu_data4bus <= {counter0_out, counter1_out, counter2_out, 8'h0, led_out, BTN, SW};
						end
					end
				endcase
			end
			//default : ;
		endcase
	end

endmodule
