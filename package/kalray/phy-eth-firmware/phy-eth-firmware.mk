################################################################################
#
# phy-eth-firmware
#
################################################################################

PHY_ETH_FIRMWARE_VERSION = custom
PHY_ETH_FIRMWARE_SOURCE = $(notdir $(PHY_ETH_FIRMWARE_TARBALL))
PHY_ETH_FIRMWARE_SITE = $(BR2_KALRAY_SOURCE_SITE)
PHY_ETH_FIRMWARE_SITE_METHOD = file

ifeq ($(BR2_PACKAGE_PHY_ETH_FIRMWARE_COMPILE_FROM_SOURCE),y)

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
