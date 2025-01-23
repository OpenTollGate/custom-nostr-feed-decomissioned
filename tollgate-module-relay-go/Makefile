include $(TOPDIR)/rules.mk

PKG_NAME:=tollgate-module-relay-go
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/OpenTollGate/tollgate-module-relay-go.git
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

define Package/tollgate-module-relay-go
	SECTION:=net
	CATEGORY:=Network
	TITLE:=TollGate Relay Module
	URL:=https://github.com/OpenTollGate/tollgate-module-relay-go
	DEPENDS:=+golang
endef

define Package/tollgate-module-relay-go/description
	TollGate Relay Module implementation in Go
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_BUILD_DIR)/src
	$(CP) $(PKG_BUILD_DIR)/src/* $(PKG_BUILD_DIR)/
	cd $(PKG_BUILD_DIR) && \
	rm -f go.mod go.sum && \
	go mod init tollgate-module-relay-go && \
	go mod edit -replace github.com/OpenTollgate/relay=./ && \
	go mod tidy && \
	go get github.com/fiatjaf/khatru && \
	go get github.com/nbd-wtf/go-nostr
endef

define Build/Configure
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	GOOS=linux \
	GOARCH=arm64 \
	GOARM=$(GO_ARM) \
	GOMIPS=$(GO_MIPS) \
	GO386=$(GO_386) \
	CGO_ENABLED=1 \
	CC=$(TARGET_CC) \
	CXX=$(TARGET_CXX) \
	GOPATH=$(GOPATH) \
	go build -trimpath -ldflags "-s -w" -o $(PKG_BUILD_DIR)/tollgate-relay main.go
endef

define Package/tollgate-module-relay-go/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tollgate-relay $(1)/usr/bin/
endef

# Add custom target to print IPK path
#define Package/tollgate-module-relay-go/postinst
#	echo "Package compiled successfully!"
#	echo "IPK file location: $(IPK_FILE)"
#endef

$(eval $(call BuildPackage,tollgate-module-relay-go))

# Print IPK path after successful compilation
PKG_FINISH:=$(shell echo "Successfully built: $(IPK_FILE)" >&2)
