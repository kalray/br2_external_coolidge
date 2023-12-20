################################################################################
#
# phy-eth-firmware
#
################################################################################

PHY_ETH_FIRMWARE_VERSION = $(call qstrip,$(BR2_PHY_ETH_FIRMWARE_VERSION))
PHY_ETH_FIRMWARE_SITE = $(call kalray,$(1),$(PHY_ETH_FIRMWARE_VERSION))

BR_NO_CHECK_HASH_FOR += $(PHY_ETH_FIRMWARE_SOURCE)

define PHY_ETH_FIRMWARE_BUILD_CMDS
	CROSS_COMPILE="$(TARGET_CROSS)" make -C $(@D) __build
endef

define PHY_ETH_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))
