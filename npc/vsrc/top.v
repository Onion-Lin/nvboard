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

    //alu单元
    alu alu0(
        .A(switch_i[11:8]),
        .B(switch_i[15:12]),
        .op(button[2:0]),
        .out(led[3:0])
    );

    // assign seg_mem[0] = switch_i[3:0];
    // assign seg_mem[1] = switch_i[7:4];

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

    assign seg6 = 8'b11111101;
    assign seg7 = 8'b11111101;
    //数码管显示初始化
    // generate
    //     for (genvar i = 6; i < 8; i++) begin : seg_gen
    //         seg7 seg_inst ( 
    //             .in (seg_mem[i]),
    //             .out({seg7, seg6, seg5, seg4, seg3, seg2, seg1, seg0}[i*8 +: 8])
    //         );
    //     end
    // endgenerate

    uart my_uart(
    .tx(uart_tx),
    .rx(uart_rx)
);

// VGA 像素时钟直接使用系统时钟（若需更精确时钟，可替换）
assign VGA_CLK = clk;

wire [9:0] h_addr;
wire [9:0] v_addr;
wire [23:0] vga_data;


// VGA 控制器：生成时序并输出 RGB 数据
vga my_vga_ctrl(
    .pclk(clk),
    .reset(rst),
    .vga_data(vga_data),
    .h_addr(h_addr),
    .v_addr(v_addr),
    .hsync(VGA_HSYNC),
    .vsync(VGA_VSYNC),
    .valid(VGA_BLANK_N),
    .vga_r(VGA_R),
    .vga_g(VGA_G),
    .vga_b(VGA_B)
);
// vmem：VGA 显示用的显存，使用 $readmemh 从 resource/picture.hex 加载图像数据
vmem my_vmem(
    .h_addr(h_addr),
    .v_addr(v_addr[8:0]),
    .vga_data(vga_data)
);
endmodule