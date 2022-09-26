################################################################################
#
# POCL firmware
#
################################################################################

POCL_FIRMWARE_SITE = $(TOPDIR)/../workspace/devimage/pocl_firmware_pkg
POCL_FIRMWARE_SITE_METHOD = local

ifeq ($(BR2_POCL_FIRMWARE_CUSTOM_TARBALL),y)
undefine POCL_FIRMWARE_SITE_METHOD
POCL_FIRMWARE_TARBALL = $(call qstrip,$(BR2_POCL_FIRMWARE_CUSTOM_TARBALL_LOCATION))
POCL_FIRMWARE_SITE = $(patsubst %/,%,$(dir $(POCL_FIRMWARE_TARBALL)))
POCL_FIRMWARE_SOURCE = $(notdir $(POCL_FIRMWARE_TARBALL))
POCL_FIRMWARE_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(POCL_FIRMWARE_SOURCE)
endif

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
