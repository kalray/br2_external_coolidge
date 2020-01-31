################################################################################
#
# mppa-rproc
#
################################################################################

MPPA_RPROC_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/mppa_rproc
MPPA_RPROC_SITE_METHOD = local
MPPA_RPROC_OPTS = TARGET=cluster SYSTEM=linux 
MPPA_RPROC_OPTS += K1_TOOLCHAIN_DIR=$(BR2_EXTERNAL_K1C_PATH)/support/kalray/
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
