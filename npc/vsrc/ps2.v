module ps2_keyboard(
    // 输入
    input clk, clrn,        // 系统时钟 / 异步复位(低有效)
    input ps2_clk, ps2_data, // PS/2 总线信号（键盘发出）

    // 输出  
    output reg ready,        // FIFO 非空标志
    output reg overflow,      // FIFO 溢出标志
    output reg [7:0] seg0,
    output reg [7:0] seg1,
    output reg [7:0] seg2,
    output reg [7:0] seg3,
    output reg [7:0] seg4,
    output reg [7:0] seg5
);

    reg [3:0] ps2_clk_sync;
    wire sampling;
    always @(posedge clk) begin
        ps2_clk_sync <= {ps2_clk_sync[2:0], ps2_clk};
    end

    assign sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

    reg [9:0] buffer;        // ps2_data bits
    reg isbreak;
    reg [9:0] old;
    reg [7:0] fifo[7:0];     // data fifo
    reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
    reg [3:0] count;  // count ps2_data bits
    reg [7:0] keynum;      // 按键计数器
    reg [7:0] data;       // 当前可读的扫描码


    wire fifo_full = ((1 + w_ptr) == r_ptr);

    //变量定义，三段式状态机状态
    reg [1:0] state,next_state;
    localparam IDLE = 2'b00, RECEIVE = 2'b01, WAIT = 2'b10;

    //组合逻辑：状态转移段
    always @(*) begin
        next_state = state; //默认保持当前状态
        case (state)
            IDLE:begin
              if (!ps2_data) begin
                next_state = RECEIVE;
              end
            end 
            RECEIVE: begin
              //count <= 0;
              if (count == 4'd9) begin
                next_state = WAIT;
              end
            end
            WAIT: begin
              if (sampling) begin
                next_state = IDLE;
              end
            end
            default: next_state = IDLE;
        endcase    
    end
    //时序逻辑：状态转移段
    always @(posedge clk) begin
        if (!clrn) begin
          state <= IDLE;
        end else begin
          state <= next_state;
        end
    end

    //时序逻辑：输出段
    always @(posedge clk) begin
      if (!clrn) begin
        count <= 0;
        buffer <= 0;
        data <= 0;
        w_ptr <= 0;
        r_ptr <= 0;
        ready <= 0;
        overflow <= 0;
        keynum <= 0;
        isbreak <= 0;
      end else begin
        case (state)
          IDLE: begin
            count <= 0;
          end
          RECEIVE: begin
            //将数据读入缓冲区
              if (sampling) begin
              count <= count + 1;
              buffer <= {ps2_data, buffer[9:1]};
            end
          end
          WAIT: begin
            if (buffer[7:0] == 8'hf0) begin
              isbreak <= 1;
            end else if (isbreak) begin
                isbreak <= 0;
            end else begin
              //奇校验，结束位校验
              count <= 0;
              if (buffer[9] && ^buffer[8:0] && !isbreak && old!=buffer) begin
                fifo[w_ptr] <= buffer[7:0];
                keynum <= keynum + 1;
                w_ptr <= w_ptr + 1;
                if (fifo_full) overflow <= 1;
                else ready <= 1;
              end
              old <= buffer;
            end
            
          end
          default: begin end
        endcase

        if (ready) begin
          data <= fifo[r_ptr];
          r_ptr <= r_ptr + 1;
          if (buffer[7:0] == 8'hf0) begin
            // keynum <= keynum + 1;
            ready <= 0;
          end
        end
      end
    end


  reg [7:0] ascii_code;
  asciiswicher ascii(
    .key_code(data),
    .ascii_code(ascii_code)
  );

  seg7 seg0_inst(
    .in(ascii_code[3:0]),
    .out(seg0)
  );
  seg7 seg1_inst(
    .in(ascii_code[7:4]),
    .out(seg1)
  );
  seg7 seg2_inst(
    .in(data[3:0]),
    .out(seg2)
  );
  seg7 seg3_inst(
    .in(data[7:4]),
    .out(seg3)
  );
  seg7 seg4_inst(
    .in(keynum[3:0]),
    .out(seg4)
  );
  seg7 seg5_inst(
    .in(keynum[7:4]),
    .out(seg5)
  );
  
endmodule


module asciiswicher(
    input [7:0] key_code,
    output reg [7:0] ascii_code
);
  always @(*) begin
      case (key_code)
          // 数字键
          8'h16: ascii_code = 8'h31;  // 1
          8'h1E: ascii_code = 8'h32;  // 2
          8'h26: ascii_code = 8'h33;  // 3
          8'h25: ascii_code = 8'h34;  // 4
          8'h2E: ascii_code = 8'h35;  // 5
          8'h36: ascii_code = 8'h36;  // 6
          8'h3D: ascii_code = 8'h37;  // 7
          8'h3E: ascii_code = 8'h38;  // 8
          8'h46: ascii_code = 8'h39;  // 9
          8'h45: ascii_code = 8'h30;  // 0
          
          // 字母键(大写)
          8'h1C: ascii_code = 8'h41;  // A
          8'h32: ascii_code = 8'h42;  // B
          8'h21: ascii_code = 8'h43;  // C
          8'h23: ascii_code = 8'h44;  // D
          8'h24: ascii_code = 8'h45;  // E
          8'h2B: ascii_code = 8'h46;  // F
          8'h34: ascii_code = 8'h47;  // G
          8'h33: ascii_code = 8'h48;  // H
          8'h43: ascii_code = 8'h49;  // I
          8'h3B: ascii_code = 8'h4A;  // J
          8'h42: ascii_code = 8'h4B;  // K
          8'h4B: ascii_code = 8'h4C;  // L
          8'h3A: ascii_code = 8'h4D;  // M
          8'h31: ascii_code = 8'h4E;  // N
          8'h44: ascii_code = 8'h4F;  // O
          8'h4D: ascii_code = 8'h50;  // P
          8'h15: ascii_code = 8'h51;  // Q
          8'h2D: ascii_code = 8'h52;  // R
          8'h1B: ascii_code = 8'h53;  // S
          8'h2C: ascii_code = 8'h54;  // T
          8'h3C: ascii_code = 8'h55;  // U
          8'h2A: ascii_code = 8'h56;  // V
          8'h1D: ascii_code = 8'h57;  // W
          8'h22: ascii_code = 8'h58;  // X
          8'h35: ascii_code = 8'h59;  // Y
          8'h1A: ascii_code = 8'h5A;  // Z
          
          
          default: ascii_code = 8'h00;  // 未知键
      endcase
  end
endmodule