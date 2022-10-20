################################################################################
#
# kalray-makefile
#
################################################################################

KALRAY_MAKEFILE_VERSION = $(call qstrip,$(BR2_KALRAY_MAKEFILE_VERSION))
KALRAY_MAKEFILE_SITE = $(call kalray,$(1),$(KALRAY_MAKEFILE_VERSION))

BR_NO_CHECK_HASH_FOR += $(KALRAY_MAKEFILE_SOURCE)

define KALRAY_MAKEFILE_INSTALL_TARGET_CMDS
	mkdir -p $(STAGING_DIR)/opt/kalray/accesscore/share/make
	cp -r $(@D)/* $(STAGING_DIR)/opt/kalray/accesscore/share/make/
endef

$(eval $(generic-package))
