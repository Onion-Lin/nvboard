// top.v - 演示用顶层模块（连接 NVBoard 的外设与显示）
// 端口说明：
// - 时钟/复位/按键/拨码开关用于交互
// - PS/2 和 UART 提供两种输入通道
// - VGA 输出显示图像，数码管和 LED 显示辅助信息
module top(
    input clk,
    input rst,
    input [4:0] btn,
    input [7:0] sw,
    input ps2_clk,
    input ps2_data,
    input uart_rx,
    output uart_tx,
    output [15:0] ledr,
    output VGA_CLK,
    output VGA_HSYNC,
    output VGA_VSYNC,
    output VGA_BLANK_N,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output [7:0] seg0,
    output [7:0] seg1,
    output [7:0] seg2,
    output [7:0] seg3,
    output [7:0] seg4,
    output [7:0] seg5,
    output [7:0] seg6,
    output [7:0] seg7
);

// LED 显示模块：左侧流水灯 + 根据开关/按键控制
led my_led(
    .clk(clk),
    .rst(rst),
    .btn(btn),
    .sw(sw),
    .ledr(ledr)
);

// VGA 像素时钟直接使用系统时钟（若需更精确时钟，可替换）
assign VGA_CLK = clk;

wire [9:0] h_addr;
wire [9:0] v_addr;
wire [23:0] vga_data;


// VGA 控制器：生成时序并输出 RGB 数据
vga_ctrl my_vga_ctrl(
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

// PS/2 键盘接收：采样并打印扫描码到终端
ps2_keyboard my_keyboard(
    .clk(clk),
    .resetn(~rst),
    .ps2_clk(ps2_clk),
    .ps2_data(ps2_data)
);


// 数码管显示：显示流水 0-7
seg my_seg(
    .clk(clk),
    .rst(rst),
    .o_seg0(seg0),
    .o_seg1(seg1),
    .o_seg2(seg2),
    .o_seg3(seg3),
    .o_seg4(seg4),
    .o_seg5(seg5),
    .o_seg6(seg6),
    .o_seg7(seg7)
);

// vmem：VGA 显示用的显存，使用 $readmemh 从 resource/picture.hex 加载图像数据
vmem my_vmem(
    .h_addr(h_addr),
    .v_addr(v_addr[8:0]),
    .vga_data(vga_data)
);

// UART：示例中为简单回环或终端连接
uart my_uart(
    .tx(uart_tx),
    .rx(uart_rx)
);

endmodule

module vmem(
    input [9:0] h_addr,
    input [8:0] v_addr,
    output [23:0] vga_data
);


// vga 内存声明：24-bit RGB，每个地址映射一个像素。
// 数组大小 524288 = 2^19，索引使用 {h_addr, v_addr} 组合以适配地址宽度。
reg [23:0] vga_mem [524287:0];

initial begin
    // 从工程的 resource 目录加载预先生成的图像数据（hex 格式）
    $readmemh("resource/picture.hex", vga_mem);
end

// 使用拼接的地址访问显存，注意 v_addr 在 top 中被截取为 9 位
assign vga_data = vga_mem[{h_addr, v_addr}];

endmodule
