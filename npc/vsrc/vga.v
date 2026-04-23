// vga_ctrl.v - 简单的 VGA 时序生成与像素输出模块
// 输入：像素时钟 `pclk`，复位 `reset`，以及来自显存的 `vga_data`（24-bit RGB）
// 输出：当前像素地址 `h_addr`/`v_addr`，同步信号 `hsync`/`vsync`，
//       有效区信号 `valid`，以及分拆后的 `vga_r/g/b`。
module vga (
    input pclk,
    input reset,
    input [23:0] vga_data,
    output [9:0] h_addr,
    output [9:0] v_addr,
    output hsync,
    output vsync,
    output valid,
    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);

// 以下参数定义了水平/垂直时序的边界值（front porch/active/back porch/total）
parameter h_frontporch = 96;
parameter h_active = 144;
parameter h_backporch = 784;
parameter h_total = 800;

parameter v_frontporch = 2;
parameter v_active = 35;
parameter v_backporch = 515;
parameter v_total = 525;

// 像素扫描计数器
reg [9:0] x_cnt;
reg [9:0] y_cnt;
wire h_valid;
wire v_valid;

// 基于像素时钟 pclk 的计数器：横向计数 x_cnt，满后横向回零并纵向 y_cnt++
always @(posedge pclk) begin
    if(reset == 1'b1) begin
        x_cnt <= 1;
        y_cnt <= 1;
    end
    else begin
        if(x_cnt == h_total)begin
            x_cnt <= 1;
            if(y_cnt == v_total) y_cnt <= 1;
            else y_cnt <= y_cnt + 1;
        end
        else x_cnt <= x_cnt + 1;
    end
end

// 生成同步信号（hsync/vsync），注意这些表达式与具体时序参数有关
assign hsync = (x_cnt > h_frontporch);
assign vsync = (y_cnt > v_frontporch);
// 生成是否在可见区域的标志
assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
assign valid = h_valid & v_valid;
// 计算当前有效像素坐标（减去前导和同步区的偏移）
assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;
// 将 24 位像素数据分配到 R/G/B 输出
assign {vga_r, vga_g, vga_b} = vga_data;

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
    // $readmemh("vga_image.hex", vga_mem);
	$readmemh("picture.hex", vga_mem);
end

// 使用拼接的地址访问显存，注意 v_addr 在 top 中被截取为 9 位
assign vga_data = vga_mem[{h_addr, v_addr}];

endmodule