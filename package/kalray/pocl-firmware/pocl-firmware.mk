################################################################################
#
# POCL Firmware
#
################################################################################

POCL_FIRMWARE_VERSION = $(call qstrip,$(BR2_POCL_FIRMWARE_VERSION))
POCL_FIRMWARE_SITE = $(call kalray,$(1),$(POCL_FIRMWARE_VERSION))

BR_NO_CHECK_HASH_FOR += $(POCL_FIRMWARE_SOURCE)

define POCL_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/kalray/opencl/
	if [ -z $(BR2_PACKAGE_POCL_FIRMWARE_LIST) ]; then \
		cp -a $(@D)/*.elf $(TARGET_DIR)/lib/firmware/kalray/opencl/; \
	else \
		$(foreach fw, $(call qstrip,$(BR2_PACKAGE_POCL_FIRMWARE_LIST)), \
			cp -a $(@D)/$(fw).elf $(TARGET_DIR)/lib/firmware/kalray/opencl/; \
		) \
		true; \
	fi
endef

$(eval $(generic-package))
