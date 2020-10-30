################################################################################
#
# kalray-linux-utils
#
################################################################################

KALRAY_LINUX_UTILS_SITE = $(TOPDIR)/../kalray_linux_utils
KALRAY_LINUX_UTILS_SITE_METHOD = local
ifeq ($(BR2_KALRAY_LINUX_UTILS_CUSTOM_TARBALL),y)
undefine KALRAY_LINUX_UTILS_SITE_METHOD
KALRAY_LINUX_UTILS_TARBALL = $(call qstrip,$(BR2_KALRAY_LINUX_UTILS_CUSTOM_TARBALL_LOCATION))
KALRAY_LINUX_UTILS_SITE = $(patsubst %/,%,$(dir $(KALRAY_LINUX_UTILS_TARBALL)))
KALRAY_LINUX_UTILS_SOURCE = $(notdir $(KALRAY_LINUX_UTILS_TARBALL))
KALRAY_LINUX_UTILS_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(KALRAY_LINUX_UTILS_SOURCE)
endif
KALRAY_LINUX_UTILS_DEPENDENCIES = dtc

KALRAY_LINUX_UTILS_OPTS = KALRAY_TOOLCHAIN_DIR=$(BR2_EXTERNAL_KVX_PATH)/support/kalray/
KALRAY_LINUX_UTILS_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)

define KALRAY_LINUX_UTILS_BUILD_CMDS
	$(MAKE) -C $(@D)/dump_fsbl_dtb $(KALRAY_LINUX_UTILS_OPTS) all
endef

define KALRAY_LINUX_UTILS_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D)/dump_fsbl_dtb prefix=$(TARGET_DIR) $(KALRAY_LINUX_UTILS_OPTS) install
endef

$(eval $(generic-package))
