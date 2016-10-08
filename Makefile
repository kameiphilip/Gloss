###############################################################################
# Generic Loader for Operating System Software (GLOSS)                        #
# Makefile                                                                    #
#                                                                             #
# Copyright 2015-2016 - Adrian J. Collado           <acollado@polaritech.com> #
# All Rights Reserved                                                         #
#                                                                             #
# This file is licensed under the MIT license, see the LICENSE file in the    #
# root of this project for more information. If this file was not distributed #
# with the source of this project, see http://choosealicense.com/licenses/mit #
###############################################################################

.PHONY: all
all: all-debug

###############################################################################
# Defaults                                                                    #
###############################################################################
MAKEFILE += --no-builtin-rules
.SUFFIXES:

CC := gcc
CXX := g++

-include User/UserSpecific.mk

###############################################################################
# Root Targets                                                                #
###############################################################################

.PHONY: debug
debug: all-debug

.PHONY: develop
develop: all-develop

.PHONY: release
release: all-release

.PHONY: all-debug
all-debug: CPPFLAGS += -g -D DEBUG -D DEVELOP
all-debug: BootHD BootFD BootCD BootPXE

.PHONY: all-develop
all-develop: CPPFLAGS += -g -D DEVELOP
all-develop: BootHD BootFD BootCD BootPXE

.PHONY: all-release
all-release: CPPFLAGS +=
all-release: BootHD BootFD BootCD BootPXE

.PHONY: clean
clean:
	@rm -rf Build/

.PHONY: rebuild
rebuild: clean all

###############################################################################
# Rules                                                                       #
###############################################################################
define _RULES
Build/Objects/%.c.o: %.c Makefile
	@echo "  Compiling $$(<F)  ->  $$(@F)"
	@mkdir -p $$(@D)
	@$$(CC) $$(CPPFLAGS) $$(CFLAGS) -MD -c -o $$@ $$<
Build/Objects/%.cpp.o: %.cpp Makefile
	@echo "  Compiling $$(<F)  ->  $$(@F)"
	@mkdir -p $$(@D)
	@$$(CXX) $$(CPPFLAGS) $$(CXXFLAGS) -MD -c -o $$@ $$<
Build/Objects/%.asm.o: ASFLAGS += -x assembler-with-cpp
Build/Objects/%.asm.o: %.asm Makefile
	@echo "  Assembling $$(<F)  ->  $$(@F)"
	@mkdir -p $$(@D)
	@$$(CC) $$(CPPFLAGS) $$(ASFLAGS) -MD -c -o $$@ $$<
endef

###############################################################################
# Projects                                                                    #
###############################################################################
.PHONY: BootHD
BootHD: CPPFLAGS += -D _DV_HD
BootHD: BootHD-FAT32

.PHONY: BootFD
BootFD:

.PHONY: BootCD
BootCD:

.PHONY: BootPXE
BootPXE:

###############################################################################
# Targeted Projects                                                           #
###############################################################################
.PHONY: BootHD-FAT32
BootHD-FAT32: CPPFLAGS += -D _FS_F32
BootHD-FAT32: BootHD-FAT32-x86_64
.PHONY: BootHD-FAT32-x86_64
BootHD-FAT32-x86_64: CC := x86_64-elf-gcc
BootHD-FAT32-x86_64: CXX := x86_64-elf-g++
BootHD-FAT32-x86_64: Build/Binaries/x86_64/HDF32.sys Build/Binaries/x86_64/HDF32BS.sys

Build/Binaries/x86_64/HDF32.sys: CPPFLAGS += -D _FS_F32
Build/Binaries/x86_64/HDF32.sys: OBJDIR := F32
Build/Binaries/x86_64/HDF32.sys: $(OBJ_HDF32)

###############################################################################
# Rules                                                                       #
###############################################################################
Build/Objects/%.c.o: %.c Makefile
	@echo "  Compiling $$(<F)  ->  $$(@F)"
	@mkdir -p $$(@D)
	@$$(CC) $$(CPPFLAGS) $$(CFLAGS) -MD -c -o $$@ $$<
Build/Objects/%.cpp.o: %.cpp Makefile
	@echo "  Compiling $$(<F)  ->  $$(@F)"
	@mkdir -p $$(@D)
	@$$(CXX) $$(CPPFLAGS) $$(CXXFLAGS) -MD -c -o $$@ $$<
Build/Objects/%.asm.o: ASFLAGS += -x assembler-with-cpp
Build/Objects/%.asm.o: %.asm Makefile
	@echo "  Assembling $$(<F)  ->  $$(@F)"
	@mkdir -p $$(@D)
	@$$(CC) $$(CPPFLAGS) $$(ASFLAGS) -MD -c -o $$@ $$<

define FILES
OBJ_$1 += $$(addprefix Build/Objects/,$$(addsuffix .o,$$(shell find -L $1/Arch/$2/Source -type f -name '*.c' -or -name '*.cpp' -or -name '*.asm' 2>&1 | grep -v find)))
OBJ_$1 += $$(addprefix Build/Objects/,$$(addsuffix .o,$$(shell find -L $1/Source -type f -name '*.c' -or -name '*.cpp' 2>&1 | grep -v find)))
endef

FINDARCH := -type f -name '*.c' -or -name '*.cpp' -or -name '*.asm'
FINDSRC := -type f -name '*.c' -or -name '*.cpp'

OBJ_HD := $(shell find -L HD/Arch/x86_64/Source $(FINDARCH) 2>&1 | grep -v find | sed 's/HD\/Arch\/x86_64\/Source\//Build\/Objects\/HD\/Arch\/x86_64\//g' | sed '/.*/&.o/g')
OBJ_HD += $(shell find -L HD/Source $(FINDSRC) 2>&1 | grep -v find | sed 's/HD\/Source\//Build\/Objects\/HD\/x86_64\//g' | sed '/.*/&

$(eval $(call FILES,HD,x86_64))
$(eval $(call FILES
