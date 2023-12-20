################################################################################
#
# dma-firmware
#
################################################################################

DMA_FIRMWARE_VERSION = $(call qstrip,$(BR2_DMA_FIRMWARE_VERSION))
DMA_FIRMWARE_SITE = $(call kalray,$(1),$(DMA_FIRMWARE_VERSION))

BR_NO_CHECK_HASH_FOR += $(DMA_FIRMWARE_SOURCE)

define DMA_FIRMWARE_BUILD_CMDS
	PATH=$(PATH):$(BR2_KALRAY_TOOLCHAIN_DIR)/bin \
		make -C $(@D) __build
endef

define DMA_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/build/*.bin $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))
