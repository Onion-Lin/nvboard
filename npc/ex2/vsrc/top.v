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
    // reg [3:0] seg_mem [7:0];

    //流水灯
    light light0(
        .clk(clk),
        .rst(rst),
        .led(led[15:7])
    );

    //编码器
    encode8_3 encode0(
        .in(switch_i[7:0]),
        .out(led[6:4])
    );

endmodule
