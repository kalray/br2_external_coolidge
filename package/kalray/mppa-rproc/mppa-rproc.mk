################################################################################
#
# mppa-rproc
#
################################################################################

MPPA_RPROC_VERSION = $(call qstrip,$(BR2_MPPA_RPROC_VERSION))
MPPA_RPROC_SITE = $(call kalray,$(1),$(MPPA_RPROC_VERSION))
MPPA_RPROC_DEPENDENCIES = kalray-makefile

BR_NO_CHECK_HASH_FOR += $(MPPA_RPROC_SOURCE)

MPPA_RPROC_OPTS = TARGET=cluster SYSTEM=linux arch=$(BR2_MARCH)
MPPA_RPROC_OPTS += KALRAY_TOOLCHAIN_DIR=$(STAGING_DIR)/opt/kalray/accesscore
MPPA_RPROC_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
MPPA_RPROC_OPTS += HOST_BACKEND=direct
ifneq (y,$(filter $(BR2_OPTIMIZE_G)$(BR2_OPTIMIZE_0),y))
MPPA_RPROC_OPTS += BUILD_TYPE=Release
endif
MPPA_RPROC_INSTALL_STAGING = YES

define MPPA_RPROC_BUILD_CMDS
	$(MAKE) -C $(@D)/src $(MPPA_RPROC_OPTS) all
endef

define MPPA_RPROC_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/src/include/mppa_rproc.h \
			      $(STAGING_DIR)/usr/include/mppa_rproc.h
	$(INSTALL) -D -m 0755 $(@D)/src/output/lib/cluster/libmppa_rproc_host.so \
			      $(STAGING_DIR)/usr/lib/libmppa_rproc_host.so
endef

define MPPA_RPROC_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/src/output/lib/cluster/libmppa_rproc_host.so \
			      $(TARGET_DIR)/usr/lib/libmppa_rproc_host.so
	$(INSTALL) -D -m 0755 $(@D)/src/output/bin/cluster-spawner \
			      $(TARGET_DIR)/usr/bin/cluster-spawner
endef

$(eval $(generic-package))
