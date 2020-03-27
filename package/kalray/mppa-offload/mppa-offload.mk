################################################################################
#
# mppa-offload
#
################################################################################

MPPA_OFFLOAD_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/mppa_offload
MPPA_OFFLOAD_SITE_METHOD = local
ifeq ($(BR2_MPPA_OFFLOAD_CUSTOM_TARBALL),y)
undefine MPPA_OFFLOAD_SITE_METHOD
MPPA_OFFLOAD_TARBALL = $(call qstrip,$(BR2_MPPA_OFFLOAD_CUSTOM_TARBALL_LOCATION))
MPPA_OFFLOAD_SITE = $(patsubst %/,%,$(dir $(MPPA_OFFLOAD_TARBALL)))
MPPA_OFFLOAD_SOURCE = $(notdir $(MPPA_OFFLOAD_TARBALL))
MPPA_OFFLOAD_VERSION = custom
MPPA_OFFLOAD_STRIP_COMPONENTS = 2
BR_NO_CHECK_HASH_FOR += $(MPPA_OFFLOAD_SOURCE)
endif
MPPA_OFFLOAD_DEPENDENCIES = mppa-rproc
MPPA_OFFLOAD_OPTS = TARGET=cluster SYSTEM=linux BUILD_TYPE=RelWithDebInfo
MPPA_OFFLOAD_OPTS += KALRAY_TOOLCHAIN_DIR=$(BR2_EXTERNAL_KVX_PATH)/support/kalray/
MPPA_OFFLOAD_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
MPPA_OFFLOAD_OPTS += HOST_BACKEND=direct
MPPA_OFFLOAD_INSTALL_STAGING = YES

define MPPA_OFFLOAD_BUILD_CMDS
	$(MAKE) -C $(@D)/libmppaoffload -f Makefile.linux $(MPPA_OFFLOAD_OPTS) all
endef

define MPPA_OFFLOAD_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/arch/linux/mppa_offload_arch.h $(STAGING_DIR)/usr/include/mppa_offload_arch.h
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/mppa_offload_common.h $(STAGING_DIR)/usr/include/mppa_offload_common.h
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/mppa_offload_host.h $(STAGING_DIR)/usr/include/mppa_offload_host.h
	$(INSTALL) -D -m 0755 $(@D)/libmppaoffload/output/lib/cluster/libmppa_offload_host.so $(STAGING_DIR)/usr/lib/libmppa_offload_host.so
endef

define MPPA_OFFLOAD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libmppaoffload/output/lib/cluster/libmppa_offload_host.so $(TARGET_DIR)/usr/lib/libmppa_offload_host.so
endef

$(eval $(generic-package))
