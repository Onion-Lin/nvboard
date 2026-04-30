module top(
    input  clk,
    input  rst,
    input  [15:0] switch_i,
    input  [4:0]  button,
    input ps2_data,
    input ps2_clk,
    input uart_rx,
    output uart_tx,
    output [15:0] led,
    output [7:0]  seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7,
    output VGA_CLK,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B
);
    reg [7:0] regist; 

    lfsr8 lfsr0(
        .clk(button[0]),
        .rst(button[1]),
        .opt(regist)
    );
    
    seg7 sege0({3'd0,regist[0]},seg7);
    seg7 sege1({3'd0,regist[1]},seg6);
    seg7 sege2({3'd0,regist[2]},seg5);
    seg7 sege3({3'd0,regist[3]},seg4);
    seg7 sege4({3'd0,regist[4]},seg3);
    seg7 sege5({3'd0,regist[5]},seg2);
    seg7 sege6({3'd0,regist[6]},seg1);
    seg7 sege7({3'd0,regist[7]},seg0);

endmodule
