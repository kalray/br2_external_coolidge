################################################################################
#
# machine_headers
#
################################################################################

MACHINE_HEADERS_VERSION ?= custom
MACHINE_HEADERS_SOURCE = machine_headers-$(MACHINE_HEADERS_VERSION).tar.gz
MACHINE_HEADERS_SITE = $(BR2_KALRAY_SOURCE_SITE)
MACHINE_HEADERS_SITE_METHOD = file
MACHINE_HEADERS_INSTALL_STAGING = YES

define MACHINE_HEADERS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/machine/devices
	$(INSTALL) -D -m 0644 $(MACHINE_HEADERS_SITE)/* $(STAGING_DIR)/usr/include/machine/devices
endef

$(eval $(generic-package))

