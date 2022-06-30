################################################################################
#
# phy-eth-firmware
#
################################################################################

ifeq ($(PHY_ETH_FIRMWARE_OVERRIDE_SRCDIR),)

PHY_ETH_FIRMWARE_SITE = $(TOPDIR)/../phy_eth_firmware
PHY_ETH_FIRMWARE_SITE_METHOD = local

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

PHY_ETH_FIRMWARE_TARBALL = $(call qstrip,$(BR2_PHY_ETH_FIRMWARE_CUSTOM_TARBALL_LOCATION))
PHY_ETH_FIRMWARE_SITE = $(patsubst %/,%,$(dir $(PHY_ETH_FIRMWARE_TARBALL)))
PHY_ETH_FIRMWARE_SOURCE = $(notdir $(PHY_ETH_FIRMWARE_TARBALL))
PHY_ETH_FIRMWARE_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(PHY_ETH_FIRMWARE_SOURCE)

define PHY_ETH_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

endif

$(eval $(generic-package))
