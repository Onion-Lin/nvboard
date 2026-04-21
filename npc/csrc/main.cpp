// 简化并修正的 Verilator + NVBoard 示例主程序
#define VCD_TRACE 1
#include <verilated.h>
#include <verilated_vcd_c.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "Vtop.h"
#include <nvboard.h>

// 顶层模型实例指针（TOP_NAME 由 Makefile 的 -D 宏定义）
static TOP_NAME* top = nullptr;
static VerilatedVcdC* tfp = nullptr;
static vluint64_t sim_time = 0;

// 声明：自动生成的绑定函数（由 scripts/auto_pin_bind.py 生成到 build/auto_bind.cpp）
void nvboard_bind_all_pins(TOP_NAME* top);

// 推进模拟一拍（下沿 + 上沿）
  static void single_cycle() {
  top->clk = 0; top->eval(); sim_time++;
  top->clk = 1; top->eval(); sim_time++;
}

// 简单复位函数
static void reset_n(int n) {
  top->rst = 1;
  while (n-- > 0) single_cycle();
  top->rst = 0;
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);

  top = new TOP_NAME;
  
//初始化波性文件
#if VCD_TRACE
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  tfp->open("wave.vcd");
#endif

  // 绑定并初始化 NVBoard
  nvboard_bind_all_pins(top);
  nvboard_init();
  reset_n(10);

  //开始仿真
  while (!Verilated::gotFinish()) {
    nvboard_update();
    single_cycle();
    #if VCD_TRACE
      if (tfp) tfp->dump(sim_time);
    #endif
  }

  //输出波型
  #if VCD_TRACE
    if (tfp) { tfp->close(); delete tfp; }
  #endif

  top->final();
  delete top;
  return 0;
}