################################################################################
#
# kvx_firmware
#
################################################################################

# FIXME: Once firmware are available as a tar.gz on website, change the site
KVX_FIRMWARE_SITE = $(TOPDIR)/../workspace/devimage/firmware_pkg
KVX_FIRMWARE_SITE_METHOD = local

ifeq ($(BR2_KVX_FIRMWARE_CUSTOM_TARBALL),y)
undefine KVX_FIRMWARE_SITE_METHOD
KVX_FIRMWARE_TARBALL = $(call qstrip,$(BR2_KVX_FIRMWARE_CUSTOM_TARBALL_LOCATION))
KVX_FIRMWARE_SITE = $(patsubst %/,%,$(dir $(KVX_FIRMWARE_TARBALL)))
KVX_FIRMWARE_SOURCE = $(notdir $(KVX_FIRMWARE_TARBALL))
KVX_FIRMWARE_VERSION = custom
KVX_FIRMWARE_STRIP_COMPONENTS = 2
BR_NO_CHECK_HASH_FOR += $(KVX_FIRMWARE_SOURCE)
endif

define KVX_FIRMWARE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/lib/firmware/
	cp -a $(@D)/*.bin $(TARGET_DIR)/lib/firmware/
endef

$(eval $(generic-package))
