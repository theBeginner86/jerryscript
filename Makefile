# Copyright 2014 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

TARGET ?= jerry
CROSS_COMPILE	?= arm-none-eabi-
OBJ_DIR = obj

SOURCES = \
	$(sort \
	$(wildcard ./src/*.c) \
	$(wildcard ./src/libperipherals/*.c) \
	$(wildcard ./src/libjsparser/*.c) \
	$(wildcard ./src/libecmaobjects/*.c) \
	$(wildcard ./src/liballocator/*.c) \
	$(wildcard ./src/libcoreint/*.c) )

INCLUDES = \
	-I src \
	-I src/libperipherals \
	-I src/libjsparser \
	-I src/libecmaobjects \
	-I src/liballocator \
	-I src/libcoreint

OBJS = \
	$(sort \
	$(patsubst %.c,./$(OBJ_DIR)/%.o,$(notdir $(SOURCES))))

CC  = gcc-4.9
LD  = ld
OBJDUMP	= objdump
OBJCOPY	= objcopy
SIZE	= size

CROSS_CC  = $(CROSS_COMPILE)gcc-4.9
CROSS_LD  = $(CROSS_COMPILE)ld
CROSS_OBJDUMP	= $(CROSS_COMPILE)objdump
CROSS_OBJCOPY	= $(CROSS_COMPILE)objcopy
CROSS_SIZE	= $(CROSS_COMPILE)size

# General flags
CFLAGS ?= $(INCLUDES) -std=c99 -m32 -fdiagnostics-color=always
#CFLAGS += -Wall -Wextra -Wpedantic -Wlogical-op -Winline
#CFLAGS += -Wformat-nonliteral -Winit-self -Wstack-protector
#CFLAGS += -Wconversion -Wsign-conversion -Wformat-security
#CFLAGS += -Wstrict-prototypes -Wmissing-prototypes

# Flags for MCU
#CFLAGS += -mlittle-endian -mcpu=cortex-m4  -march=armv7e-m -mthumb
#CFLAGS += -mfpu=fpv4-sp-d16 -mfloat-abi=hard
#CFLAGS += -ffunction-sections -fdata-sections

DEBUG_OPTIONS = -g3 -O0 -DDEBUG# -fsanitize=address
RELEASE_OPTIONS = -Os -Werror

DEFINES = -DMEM_HEAP_CHUNK_SIZE=256 -DMEM_HEAP_AREA_SIZE=32768

.PHONY: all debug release clean install test

all: debug

debug:
	$(CC) $(INCLUDES) $(CFLAGS) $(DEBUG_OPTIONS) $(DEFINES) $(SOURCES) \
	-o $(TARGET)

release:
	$(CC) $(INCLUDES) $(CFLAGS) $(RELEASE_OPTIONS) $(DEFINES) $(SOURCES) \
	-o $(TARGET)

clean:
	rm -f $(OBJ_DIR)/*.o *.o *~ lexer.log parser.log
	rm -f $(TARGET)
	rm -f $(TARGET).elf
	rm -f $(TARGET).bin
	rm -f $(TARGET).map
	rm -f $(TARGET).hex
	rm -f $(TARGET).lst

install:
	st-flash write $(TARGET).bin 0x08000000

test:
	./tools/jerry_test.sh
