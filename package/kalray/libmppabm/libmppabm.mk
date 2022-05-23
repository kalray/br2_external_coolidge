################################################################################
#
# libmppabm
#
################################################################################

LIBMPPABM_SITE = $(TOPDIR)/../workspace/kEnv/kvxtools/libmppabm
LIBMPPABM_SITE_METHOD = local
LIBMPPABM_INSTALL_STAGING = YES

ifeq ($(BR2_LIBMPPABM_CUSTOM_TARBALL),y)
undefine LIBMPPABM_SITE_METHOD
LIBMPPABM_TARBALL = $(call qstrip,$(BR2_LIBMPPABM_CUSTOM_TARBALL_LOCATION))
LIBMPPABM_SITE = $(patsubst %/,%,$(dir $(LIBMPPABM_TARBALL)))
LIBMPPABM_SOURCE = $(notdir $(LIBMPPABM_TARBALL))
LIBMPPABM_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(LIBMPPABM_SOURCE)
endif

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
