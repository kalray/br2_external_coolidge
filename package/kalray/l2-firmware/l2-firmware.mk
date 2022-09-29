################################################################################
#
# l2-firmware
#
################################################################################

L2_FIRMWARE_VERSION = custom
L2_FIRMWARE_SOURCE = l2-firmware-$(L2_FIRMWARE_CUSTOM_VERSION).tar.gz
L2_FIRMWARE_SITE = $(BR2_KALRAY_PACKAGES_SITE)

ifeq ($(BR2_L2_FIRMWARE_COMPILE_FROM_SOURCE),y)

ACCESSCORE_PATH=$(TOPDIR)/../workspace/kEnv/kvxtools/opt/kalray/accesscore

define L2_FIRMWARE_BUILD_CMDS
	# TODO: Needs fixing. It should reference an accesscore environment
	#       bundled as a buildroot package (installed in
	#       $(HOST_DIR)/opt/kalray/accesscore). But it's not clear what is
	#       really needed from the "real" accesscore to build the L2 cache
	#       firmware. A br2_external accesscore build receipe needs to be
	#       created to copy all the necessary components to build the L2
	#       cache firmware. For now we reference the accesscore environment
	#       in the workspace.
	PATH=$(PATH):$(ACCESSCORE_PATH)/bin \
	KALRAY_TOOLCHAIN_DIR=$(ACCESSCORE_PATH) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	arch=${BR2_MARCH} \
	make -C $(@D) O=$(@D) __build
endef

define L2_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(BASE_DIR)/../../devimage/l2-firmware/bin
	# TODO: This copy is needed for build.rb to find the binaries to create
	#       the "custom tarball" for step 2. This will later be removed
	#       when the new build structure is in place.
	cp -a $(@D)/bin/l2_cache_bin $(BASE_DIR)/../../devimage/l2-firmware/bin/
endef

endif

$(eval $(generic-package))
