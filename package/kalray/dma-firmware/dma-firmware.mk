################################################################################
#
# dma-firmware
#
################################################################################

ifeq ($(BR2_DMA_FIRMWARE_COMPILE_FROM_SOURCE),y)

DMA_FIRMWARE_SITE = $(TOPDIR)/../dma_firmware
DMA_FIRMWARE_SITE_METHOD = local

define DMA_FIRMWARE_BUILD_CMDS
	PATH=$(PATH):$(TOPDIR)/../workspace/kEnv/kvxtools/opt/kalray/accesscore/bin \
		make -C $(@D) __build
endef

define DMA_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(BASE_DIR)/../../devimage/dma-firmware/
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/build/*.bin $(TARGET_DIR)/lib/firmware/
	# TODO: This copy is needed for build.rb to find the binaries to create
	#       the "custom tarball" for step 2. This will later be removed
	#       when the new build structure is in place.
	cp -a $(@D)/build/*.bin $(BASE_DIR)/../../devimage/dma-firmware/
endef

else

DMA_FIRMWARE_TARBALL = $(call qstrip,$(BR2_DMA_FIRMWARE_CUSTOM_TARBALL_LOCATION))
DMA_FIRMWARE_SITE = $(patsubst %/,%,$(dir $(DMA_FIRMWARE_TARBALL)))
DMA_FIRMWARE_SOURCE = $(notdir $(DMA_FIRMWARE_TARBALL))
DMA_FIRMWARE_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(DMA_FIRMWARE_SOURCE)

define DMA_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

endif

$(eval $(generic-package))
