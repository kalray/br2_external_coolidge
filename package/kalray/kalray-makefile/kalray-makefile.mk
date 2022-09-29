################################################################################
#
# kalray-makefile
#
################################################################################

KALRAY_MAKEFILE_SOURCE = kalray-makefile-$(KALRAY_MAKEFILE_CUSTOM_VERSION).tar.gz
KALRAY_MAKEFILE_SITE = $(BR2_KALRAY_PACKAGES_SITE)

define KALRAY_MAKEFILE_INSTALL_TARGET_CMDS
	mkdir -p $(STAGING_DIR)/opt/kalray/accesscore/share/make
	cp -r $(@D)/* $(STAGING_DIR)/opt/kalray/accesscore/share/make/
endef

$(eval $(generic-package))
