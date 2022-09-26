################################################################################
#
# nvmem
#
################################################################################

ifeq ($(BR2_NVMEM_CUSTOM_TARBALL),y)
NVMEM_VERSION = custom
NVMEM_TARBALL = $(call qstrip,$(BR2_NVMEM_CUSTOM_TARBALL_LOCATION))
NVMEM_SITE = $(patsubst %/,%,$(dir $(NVMEM_TARBALL)))
NVMEM_SOURCE = $(notdir $(NVMEM_TARBALL))
BR_NO_CHECK_HASH_FOR += $(NVMEM_SOURCE)
else
NVMEM_SITE = $(TOPDIR)/../nvmem
NVMEM_SITE_METHOD = local
endif

define NVMEM_BUILD_CMDS
	CROSS_COMPILE="$(TARGET_CROSS)" $(MAKE) -C $(@D) all
endef

define NVMEM_INSTALL_TARGET_CMDS
	DESTDIR="$(TARGET_DIR)" PREFIX="/usr" $(MAKE) -C $(@D) install
endef

$(eval $(generic-package))
