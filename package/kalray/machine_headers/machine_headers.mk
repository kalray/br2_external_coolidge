################################################################################
#
# machine_headers
#
################################################################################

MACHINE_HEADERS_VERSION = $(call qstrip,$(BR2_MACHINE_HEADERS_VERSION))
MACHINE_HEADERS_SITE = $(call kalray,$(1),$(MACHINE_HEADERS_VERSION))
MACHINE_HEADERS_INSTALL_STAGING = YES

BR_NO_CHECK_HASH_FOR += $(MACHINE_HEADERS_SOURCE)

define MACHINE_HEADERS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/machine/devices
	$(INSTALL) -D -m 0644 $(@D)/* $(STAGING_DIR)/usr/include/machine/devices
endef

$(eval $(generic-package))

