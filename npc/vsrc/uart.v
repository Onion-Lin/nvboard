// 简易 UART 模块（示例）：直接将 `rx` 回环到 `tx`。
// 在该 demo 中，UART 用作终端 I/O 的占位/回环实现。
module uart (
  output tx,
  input rx
);
  // 将接收的数据直接连回发送端（loopback）
  assign tx = rx;
endmodule