`timescale 1ns / 1ps
module            ctrl(
                            clk,
                            reset,
                            Inst_in,
                            zero,
                            overflow,
                            MIO_ready,
                            MemRead,
                            MemWrite,
                            ALU_operation,
                            state_out,
                            CPU_MIO,
                            IorD,
                            IRWrite,
                            RegDst,
                            RegWrite,
                            MemtoReg,
                            ALUSrcA,
                            ALUSrcB,
                            PCSource,
                            PCWrite,
                            PCWriteCond,
                            Beq
                            );
    input clk, reset;
    input zero, overflow, MIO_ready;
    input [31:0] Inst_in;
    output [2:0] ALU_operation;
    output CPU_MIO, MemRead, MemWrite, IorD, IRWrite, RegWrite, ALUSrcA, PCWrite, PCWriteCond, Beq;
    output [ 4: 0] state_out;
    output [ 1: 0] RegDst, MemtoReg, ALUSrcB, PCSource;
    wire   [ 4: 0] state_out;
    wire   reset, MIO_ready;
    reg    CPU_MIO, MemRead, MemWrite, IorD, IRWrite, RegWrite, ALUSrcA, PCWrite, PCWriteCond, Beq;
    reg       [ 1: 0] RegDst, MemtoReg, ALUSrcB, PCSource;
    reg    [2:0] ALU_operation;
    reg       [4:0] state;

    parameter  IF     = 5'b00000,
					ID		 = 5'b00001,
               EX_R   = 5'b00010,
               EX_Mem = 5'b00011,
               EX_I   = 5'b00100,
               Lui_WB = 5'b00101,
               EX_beq = 5'b00110,
               EX_bne = 5'b00111,
               EX_jr  = 5'b01000,
               EX_JAL = 5'b01001,
               Exe_J  = 5'b01010,
               MEM_RD = 5'b01011,
               MEM_WD = 5'b01100,
               WB_R   = 5'b01101,
               WB_I   = 5'b01110,
               WB_LW  = 5'b01111,
               Error  = 5'b11111;

    parameter  AND = 3'b000,
               OR  = 3'b001,
               ADD = 3'b010,
               XOR = 3'b011,
               NOR = 3'b100,
               SRL = 3'b101,
               SUB = 3'b110,
               SLT = 3'b111;



    `define CPU_ctrl_signals {PCWrite, PCWriteCond, IorD, MemRead, MemWrite, IRWrite, MemtoReg, PCSource, ALUSrcB, ALUSrcA, RegWrite, RegDst, CPU_MIO}
    //
    assign state_out = state;

    always @ (posedge clk or posedge reset)
        if ( reset == 1 ) begin
            `CPU_ctrl_signals <= 17'h12821; //12821
            ALU_operation <= ADD;
            state <= IF;
        end
        else begin
            case ( state )
                IF : begin
                    if ( MIO_ready ) begin
                        `CPU_ctrl_signals <= 17'h00060;
                        ALU_operation <= ADD;
                        state <= ID;
                    end
                    else begin
                        state <= IF;
                        `CPU_ctrl_signals <= 17'h12821;
                    end
                end
                ID : begin
                    case ( Inst_in[31:26] )
                        6'b000000 : begin //R-type OP
                            `CPU_ctrl_signals <= 17'h00010;
                            state <= EX_R;
                            case ( Inst_in[5:0] )
                                6'b100000 : ALU_operation <= ADD;
                                //6'b10_0001 addu
                                6'b100010 : ALU_operation <= SUB;
                                // 6'b10_0011 subu
                                6'b100100 : ALU_operation <= AND;
                                6'b100101 : ALU_operation <= OR;
                                6'b100110 : ALU_operation <= XOR;
                                6'b100111 : ALU_operation <= NOR;
                                6'b101010 : ALU_operation <= SLT;
                                // 6'b101011 sltu
                                6'b000010 : ALU_operation <= SRL;   //shfit 1bit right
                                // 6'b000000 : ALU_operation <= XOR;   // something wrong, 6'b0 should be sll?
                                6'b001000 :  begin
                                    `CPU_ctrl_signals <= 17'h10010;
                                    ALU_operation <= ADD;
                                    state <= EX_jr;
                                end
                                6'b001001 : begin								// jalr
                                    `CPU_ctrl_signals <= 17'h1079C;		// set PcSource to 11
                                    ALU_operation <= ADD;
                                    state <= EX_JAL;
                                end
                                default: ALU_operation <= ADD;
                            endcase
                        end
                        6'b100011 : begin                       // Lw
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= ADD;
                            state <= EX_Mem;
                        end
                        6'b101011 : begin                       // Sw
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= ADD;
                            state <= EX_Mem;
                        end
                        6'b000010 : begin                       // Jump
                            `CPU_ctrl_signals <= 17'h10160;
                            state <= Exe_J;
                        end
                        6'b000100 : begin                       // Beq
                            `CPU_ctrl_signals <= 17'h08090;
                            Beq <= 1;
                            ALU_operation <= SUB;
                            state <= EX_beq;
                        end
                        6'b000101 : begin                       // Bne
                            `CPU_ctrl_signals <= 17'h08090;
                            Beq <= 0;
                            ALU_operation <= SUB;
                            state <= EX_bne;
                        end
                        6'b000011 : begin                       // Jal
                            `CPU_ctrl_signals <= 17'h1076c;
                            state <= EX_JAL;
                        end
                        6'b001000 : begin                       // Addi
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= ADD;
                            state <= EX_I;
                        end
                        // 6'b00_1001 addiu
                        6'b001010 : begin                       // Slti
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= SLT;
                            state <= EX_I;
                        end
                        // 6'b00_1011 sltiu
                        6'b00_1100 : begin                      // andi
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= AND;
                            state <= EX_I;
                        end
                        6'b00_1101 : begin                      // ori
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= OR;
                            state <= EX_I;
                        end
                        6'b00_1110 : begin                      // xori
                            `CPU_ctrl_signals <= 17'h00050;
                            ALU_operation <= XOR;
                            state <= EX_I;
                        end
                        6'b001111 : begin                       // Lui
                            `CPU_ctrl_signals <= 17'h00468;
                            state <= Lui_WB;
                        end
                        default : begin
                            `CPU_ctrl_signals <= 17'h12821;
                            state <= Error;
                        end
                    endcase
                end //end ID
                EX_Mem: begin
                    if ( Inst_in[31:26] == 6'b100011 ) begin
                        `CPU_ctrl_signals <= 17'h06051;
                                state <= MEM_RD;
                    end
                    else if ( Inst_in[31:26] == 6'b101011 ) begin
                        `CPU_ctrl_signals <= 17'h05051;
                                state <= MEM_WD;
                    end
                end
            MEM_RD: begin
                if ( MIO_ready ) begin
                    `CPU_ctrl_signals <= 17'h00208;
                          state <= WB_LW;
                end
                else begin
                    state <= MEM_RD;
                    `CPU_ctrl_signals <= 17'h06050;
                end
            end
            MEM_WD: begin
                if ( MIO_ready ) begin
                    `CPU_ctrl_signals <= 17'h12821;
                    ALU_operation <= ADD;
                    state <= IF;
                end
                else begin
                    state <= MEM_WD;
                    `CPU_ctrl_signals <= 17'h05050;
                end
            end
            WB_LW: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            EX_R: begin
                `CPU_ctrl_signals <= 17'h0001a;
                state <= WB_R;
            end
            EX_I: begin
                `CPU_ctrl_signals <= 17'h00058;
                state <= WB_I;
            end
            WB_R: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            WB_I: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            Exe_J: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            EX_bne: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            EX_beq: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            EX_jr: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            EX_JAL: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            Lui_WB: begin
                `CPU_ctrl_signals <= 17'h12821;
                ALU_operation <= ADD;
                state <= IF;
            end
            Error:
                state <= Error;
            default: begin
                `CPU_ctrl_signals <= 17'h12821;
                     Beq <= 0;
                ALU_operation <= ADD;
                state <= Error;
            end
        endcase
    end
endmodule
