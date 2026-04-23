# Makefile for building the NVBoard example with Verilator
# 使用前请设置环境变量 `NVBOARD_HOME` 指向 nvboard 仓库根目录
# 说明：
# - `TOPNAME` 指定顶层模块名（对应 Verilog 中的 module 名称）
# - `NXDC_FILES` 指定约束文件（用于自动绑定引脚）
TOPNAME = top
NXDC_FILES = constr/top.nxdc
INC_PATH ?=

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# constraint file
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
CSRCS += $(SRC_AUTO_BIND)

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS) -DTOP_NAME=V$(TOPNAME)

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(TOPNAME) $^ \
		$(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
		--Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

all: default

run: sim
	@$^

sim:$(BIN)
	$(call git_commit, "sim RTL") 
	@$^
	
lint:
	@verilator --lint-only $(VSRCS)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default all clean run

# Helper: generate vga hex file from an image
IMAGE_SRC ?=
IMAGE_OUT ?= vga_image.hex

gen-image:
ifneq ($(strip $(IMAGE_SRC)),)
	python3 tools/convert_to_hex.py $(IMAGE_SRC) $(IMAGE_OUT)
else
	$(error IMAGE_SRC is not set. Usage: make gen-image IMAGE_SRC=path/to/img.png)
endif

.PHONY: gen-image



