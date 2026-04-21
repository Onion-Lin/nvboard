#include <stdio.h>

/*
 * main.cpp - 仿真程序入口（占位）
 *
 * 说明：本仓库使用 NVBoard + Verilator 进行仿真。实际的仿真测试平台
 *（例如对顶层模块的时序驱动、波形记录与外设绑定）通常由
 * NVBoard 的脚本生成（生成文件位于 build/auto_bind.cpp）。
 * 这里的 main 仅为占位示例，真实运行时由 Makefile 调用 Verilator
 * 生成的可执行程序，该程序会链接 auto_bind.cpp 与其它生成的
 * 仿真驱动。
 */

int main() {
  printf("Hello, ysyx!\n");
  return 0;
}
