################################################################################
#
# libmppabm
#
################################################################################

LIBMPPABM_SITE = $(TOPDIR)/../workspace/kEnv/kvxtools/libmppabm
LIBMPPABM_SITE_METHOD = local
LIBMPPABM_INSTALL_STAGING = YES

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
