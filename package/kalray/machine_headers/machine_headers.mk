################################################################################
#
# machine_headers
#
################################################################################


MACHINE_HEADERS_SITE = $(TOPDIR)/../workspace/kEnv/kvxtools/opt/kalray/accesscore/kvx-elf/include/machine/devices
MACHINE_HEADERS_SITE_METHOD = local
MACHINE_HEADERS_INSTALL_STAGING = YES

ifeq ($(BR2_MACHINE_HEADERS_CUSTOM_TARBALL),y)
undefine MACHINE_HEADERS_SITE_METHOD
MACHINE_HEADERS_TARBALL = $(call qstrip,$(BR2_MACHINE_HEADERS_CUSTOM_TARBALL_LOCATION))
MACHINE_HEADERS_SITE = $(patsubst %/,%,$(dir $(MACHINE_HEADERS_TARBALL)))
MACHINE_HEADERS_SOURCE = $(notdir $(MACHINE_HEADERS_TARBALL))
MACHINE_HEADERS_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(MACHINE_HEADERS_SOURCE)
endif

define MACHINE_HEADERS_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/include/machine/devices
	$(INSTALL) -D -m 0644 $(MACHINE_HEADERS_SITE)/* $(STAGING_DIR)/usr/include/machine/devices
endef

$(eval $(generic-package))

