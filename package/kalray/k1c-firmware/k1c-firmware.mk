################################################################################
#
# k1c_firmware
#
################################################################################

# FIXME: Once firmware are available as a tar.gz on website, change the site
K1C_FIRMWARE_SITE = $(TOPDIR)/../workspace/devimage/firmware_pkg
K1C_FIRMWARE_SITE_METHOD = local

ifeq ($(BR2_K1C_FIRMWARE_CUSTOM_TARBALL),y)
undefine K1C_FIRMWARE_SITE_METHOD
K1C_FIRMWARE_TARBALL = $(call qstrip,$(BR2_K1C_FIRMWARE_CUSTOM_TARBALL_LOCATION))
K1C_FIRMWARE_SITE = $(patsubst %/,%,$(dir $(K1C_FIRMWARE_TARBALL)))
K1C_FIRMWARE_SOURCE = $(notdir $(K1C_FIRMWARE_TARBALL))
K1C_FIRMWARE_VERSION = custom
K1C_FIRMWARE_STRIP_COMPONENTS = 2
BR_NO_CHECK_HASH_FOR += $(K1C_FIRMWARE_SOURCE)
endif

define K1C_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))
