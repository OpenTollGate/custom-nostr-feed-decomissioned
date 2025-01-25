include $(TOPDIR)/rules.mk

PKG_NAME:=tollgate-module-merchant-go
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenTollGate/tollgate-module-merchant-go.git
PKG_SOURCE_VERSION:=HEAD
# You'll need to generate a new hash after first clone
PKG_MIRROR_HASH:=skip

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
# Define IPK path variable
IPK_FILE:=$(BIN_DIR)/packages/$(ARCH_PACKAGES)/custom/$(PKG_NAME)_$(PKG_VERSION)-$(PKG_RELEASE)_$(ARCH_PACKAGES).ipk

# Add this before including golang.mk
$(shell mkdir -p $(TOPDIR)/include)
$(shell cp -f $(CURDIR)/golang.mk $(TOPDIR)/include/golang.mk 2>/dev/null || true)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/golang.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=TollGate Merchant Module
	URL:=https://github.com/OpenTollGate/tollgate-module-merchant-go
	DEPENDS:=+golang
endef

define Package/$(PKG_NAME)/description
	TollGate Merchant Module implementation in Go
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_BUILD_DIR)/src
	$(CP) $(PKG_BUILD_DIR)/src/* $(PKG_BUILD_DIR)/
	cd $(PKG_BUILD_DIR) && \
	rm -f go.mod go.sum && \
	go mod init $(PKG_NAME) && \
	go mod edit -replace github.com/OpenTollgate/merchant=./ && \
	go mod tidy && \
	go get github.com/fiatjaf/khatru && \
	go get github.com/nbd-wtf/go-nostr
endef

define Build/Configure
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	GOOS=$(GO_TARGET_OS) \
	GOARCH=$(GO_TARGET_ARCH) \
	GOARM=$(GO_ARM) \
	GOMIPS=$(GO_MIPS) \
	GO386=$(GO_386) \
	CGO_ENABLED=1 \
	CC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	GOPATH=$(GOPATH) \
	go build -trimpath -ldflags "-s -w" -o $(PKG_BUILD_DIR)/tollgate-merchant main.go
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tollgate-merchant $(1)/usr/bin/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

# Print IPK path after successful compilation
PKG_FINISH:=$(shell echo "Successfully built: $(IPK_FILE)" >&2)
