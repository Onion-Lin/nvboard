#include <nvboard.h>
#include <Vtop.h>

// 主程序（用于 NVBoard + Verilator 的示例）
// 说明：
// - `nvboard.h` 提供 NVBoard 的 GUI / 绑定接口
// - `Vtop.h` 与 `TOP_NAME` 来自 Verilator 生成的顶层模型
// 程序流程：绑定引脚 -> 初始化 NVBoard -> 复位 -> 进入仿真循环

static TOP_NAME dut;

// 声明：自动生成的绑定函数（由 scripts/auto_pin_bind.py 生成到 build/auto_bind.cpp）
void nvboard_bind_all_pins(TOP_NAME* top);

// 推进模拟一拍（上/下沿各一次 eval）
static void single_cycle() {
  dut.clk = 0; dut.eval();
  dut.clk = 1; dut.eval();
}

// 通过多拍单周期实现简单复位
static void reset(int n) {
  dut.rst = 1;            // 断言复位
  while (n -- > 0) single_cycle();
  dut.rst = 0;            // 取消复位
}

int main() {
  // 将 DUT 的引脚绑定到 NVBoard 的 UI 控件
  nvboard_bind_all_pins(&dut);
  // 初始化 NVBoard（创建窗口、初始化回调等）
  nvboard_init();

  // 复位若干周期以让 DUT 进入初始状态
  reset(10);

  // 主循环：更新 UI（处理按键/终端等），然后推进一拍仿真
  while(1) {
    nvboard_update();
    single_cycle();
  }
}
