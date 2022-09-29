################################################################################
#
# libbmccom
#
################################################################################

LIBBMCCOM_SOURCE = libbmccom-$(LIBBMCCOM_CUSTOM_VERSION).tar.gz
LIBBMCCOM_SITE = $(BR2_KALRAY_PACKAGES_SITE)
LIBBMCCOM_INSTALL_STAGING = YES
LIBBMCCOM_DEPENDENCIES = i2c-tools

define LIBBMCCOM_BUILD_CMDS
	$(MAKE) -C $(@D) CC="$(TARGET_CC)" LD="$(TARGET_LD)" all
endef

define LIBBMCCOM_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libbmccom.so $(STAGING_DIR)/usr/lib/libbmccom.so
endef

define LIBBMCCOM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libbmccom.so $(TARGET_DIR)/usr/lib/libbmccom.so
	$(INSTALL) -D -m 0755 $(@D)/bmccom $(TARGET_DIR)/usr/bin/bmccom
endef

$(eval $(generic-package))
