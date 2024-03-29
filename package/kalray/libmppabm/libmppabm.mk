################################################################################
#
# libmppabm
#
################################################################################

LIBMPPABM_VERSION = $(call qstrip,$(BR2_BOARD_MGMT_VERSION))
LIBMPPABM_SITE = $(call kalray,board_mgmt,$(LIBMPPABM_VERSION))
LIBMPPABM_SOURCE = board_mgmt-$(LIBMPPABM_VERSION).tar.gz
LIBMPPABM_INSTALL_STAGING = YES
LIBMPPABM_DEPENDENCIES = udev

define LIBMPPABM_BUILD_CMDS
	$(MAKE) O=$(@D)/output -C $(@D) CC="$(TARGET_CC)" LD="$(TARGET_LD)" WITH_MPSSE_IF=0 mppabm
endef

define LIBMPPABM_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/output/lib/libmppabm.so $(STAGING_DIR)/usr/lib/libmppabm.so
endef

define LIBMPPABM_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/output/lib/libmppabm.so $(TARGET_DIR)/usr/lib/libmppabm.so
endef

$(eval $(generic-package))
