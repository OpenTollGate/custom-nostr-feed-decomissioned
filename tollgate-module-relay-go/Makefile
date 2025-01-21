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
endef

define Build/Configure
endef

define Build/Compile
	cd $(PKG_BUILD_DIR) && \
	GOOS=linux \
	GOARCH=$(GOARCH) \
	GOPATH=$(GOPATH) \
	CGO_ENABLED=1 \
	go build -o $(PKG_BUILD_DIR)/tollgate-relay
endef

define Package/tollgate-module-relay-go/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tollgate-relay $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tollgate-module-relay-go))
