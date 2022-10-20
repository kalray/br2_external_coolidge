################################################################################
#
# kalray-linux-utils
#
################################################################################

KALRAY_LINUX_UTILS_VERSION = $(call qstrip,$(BR2_KALRAY_LINUX_UTILS_VERSION))
KALRAY_LINUX_UTILS_SITE = $(call kalray,$(1),$(KALRAY_LINUX_UTILS_VERSION))
KALRAY_LINUX_UTILS_DEPENDENCIES = dtc kalray-makefile

BR_NO_CHECK_HASH_FOR += $(KALRAY_LINUX_UTILS_SOURCE)

KALRAY_LINUX_UTILS_OPTS = KALRAY_TOOLCHAIN_DIR=$(STAGING_DIR)/opt/kalray/accesscore
KALRAY_LINUX_UTILS_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS) arch=$(BR2_MARCH)

define KALRAY_LINUX_UTILS_BUILD_CMDS
	$(MAKE) -C $(@D)/dump_fsbl_dtb $(KALRAY_LINUX_UTILS_OPTS) all
endef

define KALRAY_LINUX_UTILS_INSTALL_TARGET_CMDS
	$(MAKE) -C $(@D)/dump_fsbl_dtb prefix=$(TARGET_DIR) $(KALRAY_LINUX_UTILS_OPTS) install
endef

$(eval $(generic-package))
