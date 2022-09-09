################################################################################
#
# POCL Firmware
#
################################################################################

POCL_FIRMWARE_VERSION ?= custom
POCL_FIRMWARE_SOURCE = pocl-$(POCL_VERSION).tar.gz
POCL_FIRMWARE_SITE = $(BR2_KALRAY_SOURCE_SITE)
POCL_FIRMWARE_SITE_METHOD = file

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
