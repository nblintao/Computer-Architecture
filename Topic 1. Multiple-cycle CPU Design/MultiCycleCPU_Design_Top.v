`timescale 1ns / 1ps
module Top_Muliti_IOBUS(
                        clk_50mhz,
                        BTN,
                        // I/O:
                        SW,
                        LED,
                        SEGMENT,
                        AN_SEL
                        );
    input clk_50mhz;
    input  [ 4: 0] BTN;
    input  [ 7: 0] SW;
    output [ 7: 0] LED, SEGMENT;
    output [ 3: 0] AN_SEL;
    wire Clk_CPU, rst, clk_m, mem_w, data_ram_we, GPIOf0000000_we, GPIOe0000000_we, counter_we;
    wire counter_OUT0, counter_OUT1, counter_OUT2;
    wire   [ 1: 0] Counter_set;
    wire   [ 4: 0] state;
    wire   [ 3: 0] digit_anode, blinke;
    wire   [ 4: 0] button_out;
    wire   [ 7: 0] SW_OK, SW, led_out, LED, SEGMENT; //led_out is current LED light
    wire   [ 9: 0] rom_addr, ram_addr;
    wire   [21: 0] GPIOf0;
    wire   [31: 0] pc, Inst, addr_bus, Cpu_data2bus, ram_data_out, disp_num;
    wire   [31: 0] clkdiv, Cpu_data4bus, counter_out, ram_data_in, Peripheral_in;
    wire MIO_ready;
    wire CPU_MIO;


    assign MIO_ready = ~button_out[1];
    assign rst = button_out[3];

    assign SW2 = SW_OK[2];
    assign LED = {led_out[7]|Clk_CPU,led_out[6:0]};
    assign clk_m = ~clk_50mhz;
    assign rom_addr = pc[11:2];
    assign AN_SEL = digit_anode;
    assign clk_io = ~Clk_CPU;

    seven_seg_dev      seven_seg(
                                .disp_num(disp_num),
                                .clk(clk_50mhz),
                                .clr(rst),
                                .SW(SW_OK[1:0]),
                                .Scanning(clkdiv[19:18]),
                                .SEGMENT(SEGMENT),
                                .AN(digit_anode)
                                );

    BTN_Anti_jitter     BTN_OK(
                                clk_50mhz,
                                BTN,
                                SW,
                                button_out,
                                SW_OK
                                );

    clk_div             div_clk(
                                clk_50mhz,
                                rst,
                                SW2,
                                clkdiv,
                                Clk_CPU
                                ); // Clock divider-

//++++++++++++++++++++++muliti_cycle_cpu+++++++++++++++++++++++++++++++++++++++++++
    Muliti_cycle_Cpu    MC_cpu(
                                .clk(Clk_CPU),
                                .reset(rst),
                                .MIO_ready(MIO_ready), //MIO_ready
                                // Internal signals:
                                .pc_out(pc), //Test
                                .Inst(Inst), //Test
                                .mem_w(mem_w),
                                .Addr_out(addr_bus),
                                .data_out(Cpu_data2bus),
                                .data_in(Cpu_data4bus),
                                .CPU_MIO(CPU_MIO),
                                .state(state) //Test
                                );

    Mem_B               RAM_I_D(
                                .clka(clk_m),
                                .wea(data_ram_we),
                                .addra(ram_addr),
                                .dina(ram_data_in),
                                .douta(ram_data_out)
                                ); // Addre_Bus [9 : 0] ,Data_Bus [31 : 0]

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    MIO_BUS         MIO_interface(
                                .clk(clk_50mhz),
                                .rst(rst),
                                .BTN(button_out),
                                .SW(SW_OK),
                                .mem_w(mem_w),
                                .Cpu_data2bus(Cpu_data2bus),
                                //data from CPU
                                .addr_bus(addr_bus),
                                .ram_data_out(ram_data_out),
                                .led_out(led_out),
                                .counter_out(counter_out),
                                .counter0_out(counter_OUT0),
                                .counter1_out(counter_OUT1),
                                .counter2_out(counter_OUT2),
                                .Cpu_data4bus(Cpu_data4bus),
                                //write to CPU
                                .ram_data_in(ram_data_in),
                                //from CPU write to Memory
                                .ram_addr(ram_addr),
                                //Memory Address signals
                                .data_ram_we(data_ram_we),
                                .GPIOf0000000_we(GPIOf0000000_we),
                                .GPIOe0000000_we(GPIOe0000000_we),
                                .counter_we(counter_we),
                                .Peripheral_in(Peripheral_in)
                                );

    led_Dev_IO     Device_led(
                                clk_io,
                                rst,
                                GPIOf0000000_we,
                                Peripheral_in,
                                Counter_set,
                                led_out,
                                GPIOf0
                                );

/* GPIO out use on 7-seg display & CPU state display addre=e0000000-efffffff */
    seven_seg_Dev_IO    Device_7seg(
                                .clk(clk_io),
                                .rst(rst),
                                .GPIOe0000000_we(GPIOe0000000_we),
                                .Test(SW_OK[7:5]),
                                .disp_cpudata(Peripheral_in), //CPU data output
                                .Test_data0({27'b0, counter_OUT0, 2'b0, Counter_set}),
                                .Test_data1(counter_out), //counter
                                .Test_data2(Inst), //Inst
                                .Test_data3(addr_bus), //addr_bus
                                .Test_data4(Cpu_data2bus), //Cpu_data2bus;
                                .Test_data5(Cpu_data4bus), //Cpu_data4bus;
                                .Test_data6(pc),
                                //pc;
                                .disp_num(disp_num)
                                );

    Counter_x           Counter_xx(
                                .clk(clk_io),
                                .rst(rst),
                                .clk0(clkdiv[9]),
                                .clk1(clkdiv[10]),
                                .clk2(clkdiv[10]),
                                .counter_we(counter_we),
                                .counter_val(Peripheral_in),
                                .counter_ch(Counter_set),
                                .counter0_OUT(counter_OUT0),
                                .counter1_OUT(counter_OUT1),
                                .counter2_OUT(counter_OUT2),
                                .counter_out(counter_out)
                                );

endmodule
