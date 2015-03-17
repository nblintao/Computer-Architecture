module  data_path   (
                    clk,
                    reset,
                    MIO_ready,
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
                    Beq,
                    ALU_operation,
                    PC_Current,
                    data2CPU,
                    Inst_R,
                    data_out,
                    M_addr,
                    zero,
                    overflow
                    );

    input clk, reset;
    input MIO_ready, IorD, IRWrite, RegWrite, ALUSrcA, PCWrite, PCWriteCond, Beq;
    input [1:0] RegDst, MemtoReg, ALUSrcB, PCSource;
    input [2:0] ALU_operation;
    input [31:0] data2CPU;
    output [31:0] Inst_R, M_addr, data_out, PC_Current; //
    output zero, overflow;
    reg [31:0] Inst_R, ALU_Out, MDR, PC_Current;
    wire [1:0] RegDst, MemtoReg, ALUSrcB, PCSource;
    wire [31:0] reg_outA, reg_outB, r6out; //regs
    wire reset, rst, zero, overflow, IRWrite, MIO_ready, RegWrite, Beq, modificative;
    //ALU
    wire IorD, ALUSrcA, PCWrite, PCWriteCond;
    wire [31:0] Alu_A, Alu_B, res;
    wire [31:0] w_reg_data, rdata_A, rdata_B, data_out, data2CPU,M_addr;
    wire [2:0] ALU_operation;
    wire [15:0] imm;
    wire [4:0] reg_Rs_addr_A, reg_Rt_addr_B, reg_rd_addr, reg_Wt_addr;

    assign rst=reset;
    // locked inst form memory
    always @(posedge clk or posedge rst) begin
        if ( rst ) begin
            Inst_R <= 0;
        end
        else begin
            if ( IRWrite && MIO_ready )
                Inst_R <= data2CPU;
            else
                Inst_R <= Inst_R;
            if (MIO_ready)
                MDR <= data2CPU;
            ALU_Out<=res;
        end
    end
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    alu                x_ALU(
                            .A(Alu_A),
                            .B(Alu_B),
                            .ALU_operation(ALU_operation),
                            .res(res),
                            .zero(zero),
                            .overflow(overflow)
                            );

    Regs           reg_files(
                            .clk(clk),
                            .rst(rst),
                            .reg_R_addr_A(reg_Rs_addr_A),
                            .reg_R_addr_B(reg_Rt_addr_B),
                            .reg_W_addr(reg_Wt_addr),
                            .wdata(w_reg_data),
                            .reg_we(RegWrite),
                            .rdata_A(rdata_A),
                            .rdata_B(rdata_B)
                            );

//path with MUX++++++++++++++++++++++++++++++++++++++++++++++++++++++

// reg path
    assign reg_Rs_addr_A = Inst_R[25:21];   //REG Source 1 rs
    assign reg_Rt_addr_B = Inst_R[20:16];   //REG Source 2 or Destination rt
    assign reg_rd_addr = Inst_R[15:11];     //REG Destination rd
    assign imm = Inst_R[15: 0];             //Immediate

// reg write data
    mux4to1_32 mux_w_reg_data(
                            .a(ALU_Out), //ALU OP
                            .b(MDR), //LW
                            .c({imm,16'h0000}), //lui
                            .d(PC_Current), // jr
                            .sel(MemtoReg),
                            .o(w_reg_data)
                            );

// reg write port addr
    mux4to1_5 mux_w_reg_addr(
                            .a(reg_Rt_addr_B), //reg addr=IR[21:16]
                            .b(reg_rd_addr), //reg addr=IR[15:11], LW or lui
                            .c(5'b11111), //reg addr=$Ra(31) jr
                            .d(5'b00000), // not use
                            .sel(RegDst),
                            .o(reg_Wt_addr)
                            );
//---------------ALU path
    mux2to1_32      mux_Alu_A(
                            .a(rdata_A), // reg out A
                            .b(PC_Current), // PC
                            .sel(ALUSrcA),
                            .o(Alu_A)
                            );

    mux4to1_32      mux_Alu_B(
                            .a(rdata_B), //reg out B
                            .b(32'h00000004), //4 for PC+4
                            .c({{16{imm[15]}},imm}), //imm
                            .d({{14{imm[15]}},imm,2'b00}),// offset
                            .sel(ALUSrcB),
                            .o(Alu_B)
                            );

//pc Generator
//+++++++++++++++++++++++++++++++++++++++++++++++++

    assign modificative = PCWrite||(PCWriteCond&&(~(zero||Beq)|(zero&&Beq)));
    //(PCWriteCond&&zero)

    always @(posedge clk or posedge reset)begin
        if ( reset == 1 )                                                           	// reset
            PC_Current<=32'h00000000;
        else if ( modificative==1 ) begin
            case(PCSource)
                2'b00 :
                    if ( MIO_ready ) PC_Current <= res;                             	// PC+4
                2'b01 : PC_Current <= ALU_Out;                                       	// branch
                2'b10 : PC_Current <= { PC_Current[31:28],Inst_R[25:0],2'b00 };      	// jump
                2'b11 : PC_Current <= rdata_A;                                       	// j$r
            endcase
        end
    end
/* mux4to1_32 mux_pc_next(
.a(pc_4),
.b(branch_pc),
.c(jump_pc),
.d(jump_pc),
.sel({jump,zero&Beq}),
.o(pc_next)
);
*/
//---------------memory path
    assign data_out=rdata_B; //data to store memory

    mux2to1_32  mux_M_addr  (
                            .a(ALU_Out), //access memory
                            .b(PC_Current), //IF
                            .sel(IorD),
                            .o(M_addr)
                            );

endmodule
