################################################################################
#
# nvmem
#
################################################################################

NVMEM_SOURCE = nvmem-$(NVMEM_CUSTOM_VERSION).tar.gz
NVMEM_SITE = $(BR2_KALRAY_PACKAGES_SITE)

define NVMEM_BUILD_CMDS
	CROSS_COMPILE="$(TARGET_CROSS)" $(MAKE) -C $(@D) all
endef

define NVMEM_INSTALL_TARGET_CMDS
	DESTDIR="$(TARGET_DIR)" PREFIX="/usr" $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
