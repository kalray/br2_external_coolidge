################################################################################
#
# POCL Firmware
#
################################################################################

POCL_FIRMWARE_VERSION = $(call qstrip,$(BR2_POCL_FIRMWARE_VERSION))
POCL_FIRMWARE_SITE = $(call kalray,$(1),$(POCL_FIRMWARE_VERSION))
POCL_FIRMWARE_PATH_PREFIX =
ifneq ($(BR2_MARCH),"kv3-1")
POCL_FIRMWARE_PATH_PREFIX = $(BR2_MARCH)/
endif
POCL_FIRMWARE_PATH = $(TARGET_DIR)/lib/firmware/kalray/opencl/$(POCL_FIRMWARE_PATH_PREFIX)

BR_NO_CHECK_HASH_FOR += $(POCL_FIRMWARE_SOURCE)

define POCL_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(POCL_FIRMWARE_PATH)
	if [ -z $(BR2_PACKAGE_POCL_FIRMWARE_LIST) ]; then \
		cp -a $(@D)/$(POCL_FIRMWARE_PATH_PREFIX)*.elf $(POCL_FIRMWARE_PATH); \
	else \
		$(foreach fw, $(call qstrip,$(BR2_PACKAGE_POCL_FIRMWARE_LIST)), \
			cp -a $(@D)/$(POCL_FIRMWARE_PATH_PREFIX)$(fw).elf $(POCL_FIRMWARE_PATH); \
		) \
		true; \
	fi
endef

$(eval $(generic-package))
