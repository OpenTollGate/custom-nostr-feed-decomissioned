#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

ifneq ($(__golang_mk_inc),1)
__golang_mk_inc=1

# Explicitly define architectures
GO_ARCH_DEPENDS:=@(aarch64||arm||i386||i686||mips||mips64||mipsel||mips64el||powerpc64||x86_64)

ifeq ($(DUMP),)
GO_VERSION_MAJOR_MINOR:=$(shell go version | sed -E 's/.*go([0-9]+[.][0-9]+).*/\1/')
endif

# Architecture-specific settings
GO_ARM:=$(if $(CONFIG_arm),$(if $(CONFIG_HAS_FPU),7,$(if $(CONFIG_GOARM_5),5,$(if $(CONFIG_GOARM_6),6,7))))
GO_MIPS:=$(if $(CONFIG_mips),softfloat,)
GO_MIPS64:=$(if $(CONFIG_mips64),$(if $(CONFIG_MIPS_FP_64),hardfloat,softfloat),)
GO_386:=$(if $(CONFIG_i386),$(if $(CONFIG_CPU_TYPE_PENTIUM4),387,sse2),)

# Target architecture mapping
GO_TARGET_ARCH:=$(subst \
    aarch64,arm64,$(subst \
    x86_64,amd64,$(subst \
    i386,386,$(ARCH))))

GO_TARGET_OS:=linux

# Build flags
GO_PKG_LDFLAGS:=-s -w

# Architecture-specific compile settings
ifeq ($(GO_TARGET_ARCH),mips)
    GO_COMPILE_FLAGS:= \
        GOOS=$(GO_TARGET_OS) \
        GOARCH=$(GO_TARGET_ARCH) \
        GOMIPS=softfloat \
        CGO_ENABLED=0
else ifeq ($(GO_TARGET_ARCH),arm64)
    GO_COMPILE_FLAGS:= \
        GOOS=$(GO_TARGET_OS) \
        GOARCH=$(GO_TARGET_ARCH) \
        CGO_ENABLED=1 \
        CC=$(TARGET_CC) \
        CXX=$(TARGET_CXX)
else
    GO_COMPILE_FLAGS:= \
        GOOS=$(GO_TARGET_OS) \
        GOARCH=$(GO_TARGET_ARCH) \
        CGO_ENABLED=1 \
        CC=$(TARGET_CC) \
        CXX=$(TARGET_CXX)
endif

# Package build settings
GO_PKG_BUILD_PKG?=$(GO_PKG)/...
GO_PKG_WORK_DIR_NAME:=.go_work
GO_PKG_WORK_DIR:=$(PKG_BUILD_DIR)/$(GO_PKG_WORK_DIR_NAME)
GO_PKG_BUILD_DIR:=$(GO_PKG_WORK_DIR)/build

endif # __golang_mk_inc
