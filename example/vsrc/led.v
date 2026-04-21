// led.v - 简单的流水灯模块，结合拨码开关与按键实现交互
module led(
  input clk,
  input rst,
  input [4:0] btn,
  input [7:0] sw,
  output [15:0] ledr
);
  // 用于产生慢速流水效果的计数器与寄存器
  reg [31:0] count;
  reg [7:0] led;
  always @(posedge clk) begin
    if (rst) begin
      led <= 1;    // 初始一个灯亮
      count <= 0;
    end
    else begin
      // 当计数到 0 时左移一位实现流水效果
      if (count == 0) led <= {led[6:0], led[7]};
      // 计数器在达到阈值后清零，阈值决定流水速度
      count <= (count >= 5000000 ? 32'b0 : count + 1);
    end
  end

  // 输出组成：高位为部分移动灯，中间位受按键影响（异或），低位直接由拨码开关控制
  assign ledr = {led[7:5], led[4:0] ^ btn, sw};
endmodule
