################################################################################
#
# kalray-makefile
#
################################################################################

KALRAY_MAKEFILE_VERSION ?= custom
KALRAY_MAKEFILE_SOURCE = kalray-makefile-$(KALRAY_MAKEFILE_VERSION).tar.gz
KALRAY_MAKEFILE_SITE = $(BR2_KALRAY_SOURCE_SITE)
KALRAY_MAKEFILE_SITE_METHOD = file

define KALRAY_MAKEFILE_INSTALL_TARGET_CMDS
	mkdir -p $(STAGING_DIR)/opt/kalray/accesscore/share/make
	cp -r $(@D)/* $(STAGING_DIR)/opt/kalray/accesscore/share/make/
endef

$(eval $(generic-package))
