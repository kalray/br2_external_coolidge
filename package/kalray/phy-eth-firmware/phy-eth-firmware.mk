################################################################################
#
# phy-eth-firmware
#
################################################################################

PHY_ETH_FIRMWARE_VERSION = $(call qstrip,$(BR2_PHY_ETH_FIRMWARE_VERSION))
PHY_ETH_FIRMWARE_SITE = $(call kalray,$(1),$(PHY_ETH_FIRMWARE_VERSION))

BR_NO_CHECK_HASH_FOR += $(PHY_ETH_FIRMWARE_SOURCE)

ifeq ($(BR2_PHY_ETH_FIRMWARE_COMPILE_FROM_SOURCE),y)

define PHY_ETH_FIRMWARE_BUILD_CMDS
	CROSS_COMPILE="$(TARGET_CROSS)" make -C $(@D) __build
endef

define PHY_ETH_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(BASE_DIR)/../../devimage/phy-eth-firmware/
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
	# TODO: This copy is needed for build.rb to find the binaries to create
	#       the "custom tarball" for step 2. This will later be removed
	#       when the new build structure is in place.
	cp -a $(@D)/*.bin $(BASE_DIR)/../../devimage/phy-eth-firmware/
endef

else

define PHY_ETH_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

endif

$(eval $(generic-package))
