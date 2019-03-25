################################################################################
#
# l2_firmware 
#
################################################################################

L2_FIRMWARE_SITE = $(TOPDIR)/../l2_firmware
L2_FIRMWARE_SITE_METHOD = local
L2_FIRMWARE_DEPENDENCIES = linux

define L2_FIRMWARE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) BUILDROOT_BUILD=1 O=build vmlinux=$(LINUX_DIR)/vmlinux OBJCOPY=$(TARGET_OBJCOPY) build/bin/l2_cache_bin
endef

define L2_FIRMWARE_INSTALL_TARGET_CMDS
	$(INSTALL) -D $(@D)/build/bin/l2_cache_bin $(TARGET_DIR)/bin/
endef

$(eval $(generic-package))
