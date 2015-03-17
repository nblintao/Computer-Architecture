
`timescale 1ns / 1ps

module led_Dev_IO(  clk,
					rst,
					GPIOf0000000_we,
					Peripheral_in,
					counter_set,
					led_out,
					GPIOf0
					);
    input wire clk, rst, GPIOf0000000_we;
    input wire [31: 0] Peripheral_in;
    output wire [ 7: 0] led_out;
    output reg  [ 1: 0] counter_set;
    output reg  [21: 0] GPIOf0;
    reg  [ 7: 0] LED;

    assign led_out = LED;

    always @( negedge clk or posedge rst ) begin
        if( rst ) begin
            LED <= 8'hAA;
            counter_set <= 2'b00;
        end else begin
            if ( GPIOf0000000_we ) begin
                { GPIOf0[21:0], LED, counter_set} <= Peripheral_in;
            end
            else begin
                LED <= LED;
                counter_set <= counter_set;
            end
        end
    end

endmodule
