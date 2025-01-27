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
GO_MIPS:=$(if $(CONFIG_mips),$(if $(CONFIG_MIPS_FP_32),hardfloat,softfloat),)
GO_MIPS64:=$(if $(CONFIG_mips64),$(if $(CONFIG_MIPS_FP_64),hardfloat,softfloat),)
GO_386:=$(if $(CONFIG_i386),$(if $(CONFIG_CPU_TYPE_PENTIUM4),387,sse2),)

# Target architecture mapping
GO_TARGET_ARCH:=$(subst \
    aarch64,arm64,$(subst \
    x86_64,amd64,$(subst \
    i386,386,$(subst \
    mipsel,mipsle,$(subst \
    mips64el,mips64le,$(subst \
    powerpc64,ppc64,$(ARCH)))))))

GO_TARGET_OS:=linux

# Host settings
GO_HOST_ARCH:=$(shell go env GOHOSTARCH)
GO_HOST_OS:=$(shell go env GOHOSTOS)
GO_HOST_TARGET_SAME:=$(if $(and $(findstring $(GO_TARGET_ARCH),$(GO_HOST_ARCH)),$(findstring $(GO_TARGET_OS),$(GO_HOST_OS))),1)
GO_HOST_TARGET_DIFFERENT:=$(if $(GO_HOST_TARGET_SAME),,1)

# Build flags
GO_STRIP_ARGS:=--strip-unneeded --remove-section=.comment --remove-section=.note
GO_PKG_GCFLAGS:=
GO_PKG_LDFLAGS:=-s -w

# Remove the PIE mode for MIPS architecture
ifeq ($(GO_TARGET_ARCH),mips)
  GO_LDFLAGS:=-extldflags -static
  GO_CUSTOM_FLAGS:=
else
  GO_LDFLAGS:=-extldflags -static
  GO_CUSTOM_FLAGS:=-buildmode pie
endif

# Package build settings
GO_PKG_BUILD_PKG?=$(GO_PKG)/...
GO_PKG_WORK_DIR_NAME:=.go_work
GO_PKG_WORK_DIR:=$(PKG_BUILD_DIR)/$(GO_PKG_WORK_DIR_NAME)
GO_PKG_BUILD_DIR:=$(GO_PKG_WORK_DIR)/build
GO_PKG_CACHE_DIR:=$(GO_PKG_WORK_DIR)/cache
GO_PKG_TMP_DIR:=$(GO_PKG_WORK_DIR)/tmp
GO_PKG_BUILD_BIN_DIR:=$(GO_PKG_BUILD_DIR)/bin$(if $(GO_HOST_TARGET_DIFFERENT),/$(GO_TARGET_OS)_$(GO_TARGET_ARCH))

# Build paths
GO_BUILD_DIR_PATH:=$(firstword $(subst :, ,$(GOPATH)))
GO_BUILD_PATH:=$(if $(GO_PKG),$(GO_BUILD_DIR_PATH)/src/$(GO_PKG))

# Architecture-specific compile flags
GO_COMPILE_FLAGS:= \
    GOOS=$(GO_TARGET_OS) \
    GOARCH=$(GO_TARGET_ARCH) \
    GO386=$(GO_386) \
    GOARM=$(GO_ARM) \
    GOMIPS=$(GO_MIPS) \
    GOMIPS64=$(GO_MIPS64) \
    CGO_ENABLED=1 \
    CC=$(TARGET_CC) \
    CXX=$(TARGET_CXX) \
    GOPATH=$(GOPATH)

endif # __golang_mk_inc
