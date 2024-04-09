################################################################################
#
# phy-eth-firmware
#
################################################################################

PHY_ETH_FIRMWARE_VERSION = $(call qstrip,$(BR2_PHY_ETH_FIRMWARE_VERSION))
PHY_ETH_FIRMWARE_SITE = $(call kalray,$(1),$(PHY_ETH_FIRMWARE_VERSION))

BR_NO_CHECK_HASH_FOR += $(PHY_ETH_FIRMWARE_SOURCE)

define PHY_ETH_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/$(BR2_MARCH)/*.bin $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))
