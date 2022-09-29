################################################################################
#
# mppa-offload
#
################################################################################

MPPA_OFFLOAD_SOURCE = mppa-offload-$(MPPA_OFFLOAD_CUSTOM_VERSION).tar.gz
MPPA_OFFLOAD_SITE = $(BR2_KALRAY_PACKAGES_SITE)
MPPA_OFFLOAD_INSTALL_STAGING = YES
MPPA_OFFLOAD_DEPENDENCIES = offload-daemon kalray-makefile

MPPA_OFFLOAD_OPTS = TARGET=cluster SYSTEM=linux arch=$(BR2_MARCH)
MPPA_OFFLOAD_OPTS += KALRAY_TOOLCHAIN_DIR=$(STAGING_DIR)/opt/kalray/accesscore
MPPA_OFFLOAD_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
MPPA_OFFLOAD_OPTS += HOST_BACKEND=direct
ifneq (y,$(filter $(BR2_OPTIMIZE_G)$(BR2_OPTIMIZE_0),y))
MPPA_OFFLOAD_OPTS += BUILD_TYPE=Release
endif

define MPPA_OFFLOAD_BUILD_CMDS
	$(MAKE) -C $(@D)/libmppaoffload -f Makefile.linux $(MPPA_OFFLOAD_OPTS) all
endef

define MPPA_OFFLOAD_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/arch/linux/mppa_offload_arch.h $(STAGING_DIR)/usr/include/mppa_offload_arch.h
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/mppa_offload_common.h $(STAGING_DIR)/usr/include/mppa_offload_common.h
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/mppa_offload_host.h $(STAGING_DIR)/usr/include/mppa_offload_host.h
	$(INSTALL) -D -m 0644 $(@D)/libmppaoffload/include/mppa_offload_cmd.h $(STAGING_DIR)/usr/include/mppa_offload_cmd.h
	$(INSTALL) -D -m 0755 $(@D)/libmppaoffload/output/lib/cluster/libmppa_offload_host.so $(STAGING_DIR)/usr/lib/libmppa_offload_host.so
endef

define MPPA_OFFLOAD_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/libmppaoffload/output/lib/cluster/libmppa_offload_host.so $(TARGET_DIR)/usr/lib/libmppa_offload_host.so
endef

$(eval $(generic-package))
