// ps2_keyboard.v - PS/2 键盘接收示例（在仿真中打印扫描码）
// 工作思路：对 ps2_clk 进行同步检测，在下降沿采样 ps2_data，
// 将位收集到 buffer，当检测到一帧（start + 8 data + parity + stop）时，
// 验证起始位/停止位/奇偶校验并在仿真终端打印接收到的扫描码。
module ps2_keyboard(clk,resetn,ps2_clk,ps2_data);
    input clk,resetn,ps2_clk,ps2_data;

    reg [9:0] buffer;        // 存放一帧的 10 位（start,data[8],parity,stop）
    reg [3:0] count;  // 已接收位计数
    reg [2:0] ps2_clk_sync; // 用于检测 ps2_clk 的边沿

    // 将异步 ps2_clk 同步到本地时钟域，形成采样沿
    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
    end

    // 当 ps2_clk 从高到低时（下降沿），开始采样数据线
    wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    always @(posedge clk) begin
        if (resetn == 0) begin // reset
            count <= 0;
        end
        else begin
            if (sampling) begin
              if (count == 4'd10) begin
                // 检查帧格式：start(0)、stop(1)、奇偶校验
                if ((buffer[0] == 0) &&  // start bit
                    (ps2_data)       &&  // stop bit
                    (^buffer[9:1])) begin      // odd  parity
                    // 在仿真中输出收到的 8 位扫描码
                    $display("receive %x", buffer[8:1]);
                end
                count <= 0;     // for next frame
              end else begin
                buffer[count] <= ps2_data;  // 存储采样到的位
                count <= count + 3'b1;
              end
            end
        end
    end

endmodule