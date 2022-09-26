################################################################################
#
# kalray-makefile
#
################################################################################

KALRAY_MAKEFILE_SITE = $(TOPDIR)/../workspace/kEnv/kvxtools/opt/kalray/accesscore/share/make
KALRAY_MAKEFILE_SITE_METHOD = local
ifeq ($(BR2_KALRAY_MAKEFILE_CUSTOM_TARBALL),y)
undefine KALRAY_MAKEFILE_SITE_METHOD
KALRAY_MAKEFILE_TARBALL = $(call qstrip,$(BR2_KALRAY_MAKEFILE_CUSTOM_TARBALL_LOCATION))
KALRAY_MAKEFILE_SITE = $(patsubst %/,%,$(dir $(KALRAY_MAKEFILE_TARBALL)))
KALRAY_MAKEFILE_SOURCE = $(notdir $(KALRAY_MAKEFILE_TARBALL))
KALRAY_MAKEFILE_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(KALRAY_MAKEFILE_SOURCE)
endif

define KALRAY_MAKEFILE_INSTALL_TARGET_CMDS
	mkdir -p $(STAGING_DIR)/opt/kalray/accesscore/share/make
	cp -r $(@D)/* $(STAGING_DIR)/opt/kalray/accesscore/share/make/
endef

$(eval $(generic-package))
