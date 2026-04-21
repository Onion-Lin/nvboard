// seg.v - 八位数码管滚动显示示例
// 通过预定义的 8 个段码（segs）循环显示数字 0-7
module seg(
  input clk,
  input rst,
  output [7:0] o_seg0,
  output [7:0] o_seg1,
  output [7:0] o_seg2,
  output [7:0] o_seg3,
  output [7:0] o_seg4,
  output [7:0] o_seg5,
  output [7:0] o_seg6,
  output [7:0] o_seg7
);

// 预定义 8 个要显示的段码（每个字节对应一个数码管的 a..g,dp）
wire [7:0] segs [7:0];
assign segs[0] = 8'b11111101;
assign segs[1] = 8'b01100000;
assign segs[2] = 8'b11011010;
assign segs[3] = 8'b11110010;
assign segs[4] = 8'b01100110;
assign segs[5] = 8'b10110110;
assign segs[6] = 8'b10111110;
assign segs[7] = 8'b11100000;

parameter CLK_NUM = 5000000; // 控制刷新速度的计数阈值

reg [31:0] count;
reg [2:0] offset; // 当前显示的起始索引

// 基于计数器周期性地移动 offset，从而实现滚动效果
always @(posedge clk) begin
  if(rst) begin count <= 0; offset <= 0; end
  else begin
    if(count == CLK_NUM) begin offset <= offset + 1; end
    count <= (count == CLK_NUM) ? 0 : count + 1;
  end
end

// 将当前 offset 的 8 个段码输出到 8 个数码管
assign o_seg0 = ~segs[offset + 3'd0];
assign o_seg1 = ~segs[offset + 3'd1];
assign o_seg2 = ~segs[offset + 3'd2];
assign o_seg3 = ~segs[offset + 3'd3];
assign o_seg4 = ~segs[offset + 3'd4];
assign o_seg5 = ~segs[offset + 3'd5];
assign o_seg6 = ~segs[offset + 3'd6];
assign o_seg7 = ~segs[offset + 3'd7];

endmodule
