################################################################################
#
# machine_headers
#
################################################################################

MACHINE_HEADERS_SOURCE = machine_headers-$(MACHINE_HEADERS_CUSTOM_VERSION).tar.gz
MACHINE_HEADERS_SITE = $(BR2_KALRAY_PACKAGES_SITE)
MACHINE_HEADERS_INSTALL_STAGING = YES

define MACHINE_HEADERS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/machine/devices
	$(INSTALL) -D -m 0644 $(@D)/* $(STAGING_DIR)/usr/include/machine/devices
endef

$(eval $(generic-package))

