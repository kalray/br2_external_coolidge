################################################################################
#
# mppa-rproc
#
################################################################################

MPPA_RPROC_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/mppa_rproc
MPPA_RPROC_SITE_METHOD = local
ifeq ($(BR2_MPPA_RPROC_CUSTOM_TARBALL),y)
undefine MPPA_RPROC_SITE_METHOD
MPPA_RPROC_TARBALL = $(call qstrip,$(BR2_MPPA_RPROC_CUSTOM_TARBALL_LOCATION))
MPPA_RPROC_SITE = $(patsubst %/,%,$(dir $(MPPA_RPROC_TARBALL)))
MPPA_RPROC_SOURCE = $(notdir $(MPPA_RPROC_TARBALL))
MPPA_RPROC_VERSION = custom
MPPA_RPROC_STRIP_COMPONENTS = 2
BR_NO_CHECK_HASH_FOR += $(MPPA_RPROC_SOURCE)
endif
MPPA_RPROC_OPTS = TARGET=cluster SYSTEM=linux 
MPPA_RPROC_OPTS += KALRAY_TOOLCHAIN_DIR=$(BR2_EXTERNAL_KVX_PATH)/support/kalray/
MPPA_RPROC_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
MPPA_RPROC_OPTS += HOST_BACKEND=direct
MPPA_RPROC_INSTALL_STAGING = YES

define MPPA_RPROC_BUILD_CMDS
	$(MAKE) -C $(@D)/lib $(MPPA_RPROC_OPTS) all
endef

define MPPA_RPROC_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/lib/include/mppa_rproc.h $(STAGING_DIR)/usr/include/mppa_rproc.h
	$(INSTALL) -D -m 0755 $(@D)/lib/output/lib/cluster/libmppa_rproc_host.so $(STAGING_DIR)/usr/lib/libmppa_rproc_host.so
endef

define MPPA_RPROC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/output/lib/cluster/libmppa_rproc_host.so $(TARGET_DIR)/usr/lib/libmppa_rproc_host.so
endef

$(eval $(generic-package))
