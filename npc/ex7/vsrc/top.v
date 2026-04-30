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
   
    wire ready;
    wire overflow;

    //键盘
    ps2_keyboard keyboard(
        .clk(clk),
        .clrn(switch_i[12]),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .ready(ready),
        .overflow(overflow),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .seg4(seg4),
        .seg5(seg5)
    );



    uart my_uart(
    .tx(uart_tx),
    .rx(uart_rx)
);

endmodule
