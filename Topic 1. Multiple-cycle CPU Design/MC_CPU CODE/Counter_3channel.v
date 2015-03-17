
`timescale 1ns / 1ps

module Counter_x(   clk,
                    rst,
                    clk0,
                    clk1,
                    clk2,
                    counter_we,
                    counter_val,
                    counter_ch,
                    counter0_OUT,
                    counter1_OUT,
                    counter2_OUT,
                    counter_out,
                    M0
                    );
    input clk, rst, clk0, clk1, clk2, counter_we;
    reg   [32: 0] counter0, counter1, counter2;
    reg   [31: 0] counter0_Lock, counter1_Lock, counter2_Lock;
    output wire  [31: 0] counter_out;
    reg   [23: 0] counter_Ctrl;
    input [31: 0] counter_val;
    output reg M0;
    reg sq0, sq1, sq2, M1, M2, clr0, clr1, clr2;
    output wire counter0_OUT,counter1_OUT,counter2_OUT;
    input wire [ 1: 0] counter_ch; //Counter channel set
    //Counter read or write & set counter_ch=SC1 SC0; counter_Ctrl=XX M2 M1 M0 X


    initial begin
        counter0 <= 0;
        counter1 <= 0;
        counter2 <= 0;
    end


    always @ (posedge clk or posedge rst) begin
        if ( rst ) begin
            counter0_Lock <= 0;
            counter1_Lock <= 0;
            counter2_Lock <= 0;
            counter_Ctrl <= 0;
        end else if ( counter_we ) begin          // counter_Ctrl=XX M2 M1 M0 X
            case( counter_ch )
                2'h0: begin                     // f0000000: bit1 bit0 =00
                    counter0_Lock <= counter_val;
                    M0 <= 1;
                end
                2'h1: begin                     // f0000000: bit1 bit0 =01
                    counter1_Lock <= counter_val;
                    M1 <= 1;
                end
                2'h2: begin                     // f0000000: bit1 bit0 =10
                    counter2_Lock <= counter_val;
                    M2 <= 1;
                end
                2'h3: begin
                    counter_Ctrl <= counter_val[23:0];
                end
            endcase
        end else begin
            counter0_Lock <= counter0_Lock;
            counter1_Lock <= counter1_Lock;
            counter2_Lock <= counter2_Lock;
            counter_Ctrl <= counter_Ctrl;
            if ( clr0 ) M0 <= 0;
            if ( clr1 ) M1 <= 0;
            if ( clr2 ) M2 <= 0;
        end
    end

    // Counter channel 0
    always @ (posedge clk0 or posedge rst) begin
        if ( rst ) begin
            counter0[32: 0] <= 33'b0;
            sq0 <= 0;
            clr0 <= 0;
        end else begin
            case ( counter_Ctrl[ 2: 1] )
                2'b00: begin
                    if ( M0 ) begin                         // Just start or after clear
                        counter0 <= {1'b0,counter0_Lock};
                        clr0 <= 1;
                    end else
                        if ( counter0[32] == 0 ) begin
                            counter0 <= counter0 - 1'b1;
                            clr0 <= 0;                      // overflow need a software-clear, i.e. a re-set
                        end
                end
                2'b01: begin
                    if ( counter0[32] == 0 )
                        counter0 <= counter0 - 1'b1;
                    else counter0 <= {1'b0,counter0_Lock};
                end
                2'b10: begin
                    sq0 <= counter0[32];
                    if ( sq0 != counter0[32] )
                        counter0[31:0] <= {1'b0,counter0_Lock[31:1]};           // div-2
                    else counter0 <= counter0 - 1'b1;
                end
                2'b11:
                    counter0 <= counter0 - 1'b1;
            endcase
        end
    end

    // Counter channel 1
    always @ (posedge clk1 or posedge rst) begin
        if ( rst ) begin
            counter1[32: 0] <= 33'b0;
            sq1 <= 0;
            clr1 <= 0;
        end else begin
            case ( counter_Ctrl[10: 9] )
                2'b00: begin
                    if ( M1 ) begin
                        counter1 <= {1'b0, counter1_Lock};
                        clr1 <= 1;
                    end else
                        if ( counter1[32] == 0 ) begin
                            counter1 <= counter1 - 1'b1;
                            clr1 <= 0;
                        end
                end
                2'b01: begin
                    if ( counter1[32] == 0 )
                        counter1 <= counter1 - 1'b1;
                    else counter1 <= {1'b0, counter1_Lock};
                end
                2'b10: begin
                    sq1 <= counter1[32];
                    if ( sq1 != counter1[32] )
                        counter1[31:0] <= {1'b0, counter1_Lock[31:1]};
                    else counter1 <= counter1 - 1'b1;
                end
                2'b11:
                    counter1 <= counter1 - 1'b1;
            endcase
        end
    end

    // Counter channel 2
    always @ (posedge clk2 or posedge rst) begin
        if ( rst ) begin
            counter2[32: 0] <= 33'b0;
            sq2 <= 0;
            clr2 <= 0;
        end else begin
            case ( counter_Ctrl[18:17] )
                2'b00: begin
                    if ( M2 ) begin
                        counter2 <= {1'b0, counter2_Lock};
                        clr2 <= 1;
                    end else
                        if ( counter2[32] == 0 ) begin
                            counter2 <= counter2 - 1'b1;
                            clr2 <= 0;
                        end
                end
                2'b01: begin
                    if ( counter2[32] == 0 )
                        counter2 <= counter2 - 1'b1;
                    else counter2 <= {1'b0, counter2_Lock};
                end
                2'b10: begin
                    sq2 <= counter2[32];
                    if ( sq2 != counter2[32] )
                        counter2[31:0] <= {1'b0, counter2_Lock[31:1]};
                    else counter2 <= counter2 - 1'b1;
                end
                2'b11:
                    counter2 <= counter2 - 1'b1;
            endcase
        end
    end





    assign counter0_OUT = counter0[32];
    assign counter1_OUT = counter1[32];
    assign counter2_OUT = counter2[32];
    assign counter_out  = counter0[31: 0];
    //assign counter_out = ( counter_ch == 2'b00 )? counter0[31: 0]: ( counter_ch == 2'b01 )? counter1[31: 0] : counter2[31: 0];

endmodule
