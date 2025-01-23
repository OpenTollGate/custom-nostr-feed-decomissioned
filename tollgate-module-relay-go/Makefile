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

# Go specific configurations
GO_PKG:=github.com/OpenTollGate/tollgate-module-relay-go
GO_PKG_SOURCE_ONLY:=1
GO_CMD:=$(STAGING_DIR_HOST)/go/bin/go
export GOROOT:=$(STAGING_DIR_HOST)/go
export PATH:=$(STAGING_DIR_HOST)/go/bin:$(PATH)
export GOPATH:=$(PKG_BUILD_DIR)/gopath
export GO111MODULE:=on
export GOPROXY:=direct

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/golang.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=TollGate Relay Module
	URL:=https://github.com/OpenTollGate/tollgate-module-relay-go
	DEPENDS:=+golang
	PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	TollGate Relay Module implementation in Go
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	
	# Create necessary directories
	mkdir -p $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)/src
	
	# Copy source files
	$(CP) $(PKG_BUILD_DIR)/src/* $(PKG_BUILD_DIR)/
	
	# Initialize Go modules
	cd $(PKG_BUILD_DIR) && \
		rm -f go.mod go.sum && \
		$(GO_CMD) mod init $(PKG_NAME) && \
		$(GO_CMD) mod edit -replace github.com/OpenTollgate/relay=./ && \
		$(GO_CMD) mod tidy && \
		$(GO_CMD) get github.com/fiatjaf/khatru && \
		$(GO_CMD) get github.com/nbd-wtf/go-nostr
endef

define Build/Configure
	# This space intentionally left blank
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
	$(GO_CMD) build -trimpath \
		-ldflags "-s -w \
			-X main.Version=$(PKG_VERSION) \
			-X main.BuildTime=$(shell date -u '+%Y-%m-%d_%I:%M:%S%p') \
			-X main.GitHash=$(PKG_SOURCE_VERSION)" \
		-o $(PKG_BUILD_DIR)/tollgate-relay \
		main.go
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tollgate-relay $(1)/usr/bin/
	
	# Add init script if needed
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_BIN) ./files/tollgate-relay.init $(1)/etc/init.d/tollgate-relay
	
	# Add configuration if needed
	#$(INSTALL_DIR) $(1)/etc/config
	#$(INSTALL_CONF) ./files/tollgate-relay.config $(1)/etc/config/tollgate-relay
endef

# Optional: Add configuration files
define Package/$(PKG_NAME)/conffiles
#/etc/config/tollgate-relay
endef

# Post-installation message
define Package/$(PKG_NAME)/postinst
#!/bin/sh
echo "Package $(PKG_NAME) installed successfully!"
echo "IPK file location: $(IPK_FILE)"
exit 0
endef

# Pre-removal script
define Package/$(PKG_NAME)/prerm
#!/bin/sh
echo "Removing $(PKG_NAME)..."
exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

# Print build success message and IPK location
PKG_FINISH:=$(shell echo "Successfully built: $(IPK_FILE)" >&2)
