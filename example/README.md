# NVBoard + Verilator 示例工程（新手教程）

## 简介
本示例演示如何使用 Verilator 在 NVBoard GUI 中仿真一个简单的顶层模块，包含 LED、数码管、VGA、PS/2 键盘和 UART 等外设。通过本教程你可以快速运行示例、观察仿真结果，并学习如何基于此模板制作自己的项目。

## 演示功能（运行后可交互）
- 左侧 8 个 LED：流水灯效果
- 右侧 8 个拨码开关（`sw`）：控制对应 LED 的亮灭
- 按键（`btn`）：使部分 LED 显示取反效果（异或）
- 八位数码管：循环显示数字 0-7
- VGA（窗口左下角）：展示 `resource/picture.hex` 中的图像
- PS/2 键盘：仿真中在终端打印按键扫描码
- UART：终端回环（`rx` -> `tx`），可在 NVBoard 的 UART 终端中输入并看到回显

## 前提条件（在 Linux 上）
建议安装下列工具：
```bash
sudo apt update
sudo apt install -y verilator git build-essential python3 python3-pip
```
如果 NVBoard 的 GUI 出现问题，可能还需安装 SDL/GL 相关库：
```bash
sudo apt install -y libsdl2-dev libgl1-mesa-dev
```

## 获取 NVBoard 并设置环境变量
如果你还没有 NVBoard 仓库：
```bash
git clone https://github.com/NJU-ProjectN/nvboard.git ~/nvboard
export NVBOARD_HOME=~/nvboard
# 建议将上面的 export 写入 ~/.bashrc 或 ~/.zshrc
```

## 快速构建与运行
在本示例目录下执行：
```bash
cd example
make run
```
`make` 会调用 Verilator 并使用 NVBoard 的脚本生成绑定代码并启动仿真窗口。

## 项目结构说明（关键文件）
- `vsrc/`：Verilog 源码（顶层 `top.v` 与外设模块）
- `csrc/`：仿真 C++ 源（`main.cpp`）用于驱动 Verilator 模型与 NVBoard
- `resource/`：资源文件，例如 `picture.hex`（VGA 使用）
- `constr/top.nxdc`：引脚约束，用于自动生成绑定代码
- `Makefile`：构建规则（会引用 `$(NVBOARD_HOME)/scripts/nvboard.mk`）

## 如何替换 VGA 图片（生成 `resource/picture.hex`）
该示例的显存寻址使用横坐标 10 位 + 纵坐标 9 位（共 19 位），显存大小为 524288 像素（1024×512）。
要替换图片，请将图像缩放到 `1024x512`，并导出为每行一个像素的 24-bit RGB hex（格式 `RRGGBB`）。示例 Python 脚本（需安装 Pillow）：

```python
# tools/png2hex.py
from PIL import Image
im = Image.open('input.png').convert('RGB').resize((1024,512))
with open('resource/picture.hex','w') as f:
   for y in range(512):
      for x in range(1024):
         r,g,b = im.getpixel((x,y))
         f.write('{:02x}{:02x}{:02x}\n'.format(r,g,b))
```

运行：
```bash
pip3 install pillow
python3 tools/png2hex.py
```

## 如何基于此模板创建你自己的项目（简要步骤）
1. 复制本目录作为新项目模板。
2. 在 `vsrc/` 中实现或修改你的外设模块，并修改 `vsrc/top.v` 将它们连接在一起。
3. 更新 `constr/top.nxdc`（如需要在 NVBoard 中绑定新的引脚）。
4. 设置 `NVBOARD_HOME` 并运行 `make run` 进行仿真调试。

## 常见问题与排查
- 报错找不到 `NVBOARD_HOME`：确认环境变量已导出且路径正确。
- Verilator 找不到或报错：运行 `verilator --version` 来确认安装并在 PATH 中。
- GUI/终端异常：检查 SDL/GL 等依赖库是否缺失（如 `libsdl2-dev`）。

## 下一步建议
- 我可以帮你把 `tools/png2hex.py` 添加到仓库的 `tools/` 下。
- 我也可以尝试在当前环境运行 `make run`（请先确认 `NVBOARD_HOME`）。

---
说明：本示例基于 NVBoard 项目结构编写，若需更深的定制或疑难排查，我可以继续协助。

