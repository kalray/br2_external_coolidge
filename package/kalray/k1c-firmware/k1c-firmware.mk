################################################################################
#
# k1c_firmware
#
################################################################################

# FIXME: Once firmware are available as a tar.gz on website, change the site
K1C_FIRMWARE_SITE = $(TOPDIR)/../workspace/devimage/firmware_pkg
K1C_FIRMWARE_SITE_METHOD = local

define K1C_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))
