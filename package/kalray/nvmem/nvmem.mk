################################################################################
#
# nvmem
#
################################################################################

NVMEM_VERSION = $(call qstrip,$(BR2_NVMEM_VERSION))
NVMEM_SITE = $(call kalray,$(1),$(NVMEM_VERSION))

BR_NO_CHECK_HASH_FOR += $(NVMEM_SOURCE)

define NVMEM_BUILD_CMDS
	CROSS_COMPILE="$(TARGET_CROSS)" $(MAKE) -C $(@D) all
endef

define NVMEM_INSTALL_TARGET_CMDS
	DESTDIR="$(TARGET_DIR)" PREFIX="/usr" $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
