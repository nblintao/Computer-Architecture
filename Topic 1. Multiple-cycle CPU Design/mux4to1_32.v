
`timescale 1ns / 1ps

module mux4to1_32(
    a,
    b,
    c,
    d,
    o,
    sel
    );
    input wire  [31: 0] a, b, c, d;
    input wire  [ 1: 0] sel;
    output wire [31: 0] o;

    assign o = ( sel == 2'b00)? a: ( sel == 2'b01 )? b: ( sel == 2'b10 )? c: ( sel == 2'b11 )? d: 0;
endmodule
