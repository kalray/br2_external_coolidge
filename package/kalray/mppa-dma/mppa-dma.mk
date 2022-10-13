################################################################################
#
# mppa-dma
#
################################################################################

MPPA_DMA_SOURCE = mppa-dma-$(MPPA_DMA_CUSTOM_VERSION).tar.gz
MPPA_DMA_SITE = $(BR2_KALRAY_PACKAGES_SITE)
MPPA_DMA_DEPENDENCIES = kalray-makefile machine_headers

MPPA_DMA_MACHINE_HEADERS_PATH = $(STAGING_DIR)/usr/include/machine/devices

MPPA_DMA_OPTS = TARGET=cluster SYSTEM=linux arch=$(BR2_MARCH)
MPPA_DMA_OPTS += KALRAY_TOOLCHAIN_DIR=$(STAGING_DIR)/opt/kalray/accesscore
MPPA_DMA_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
ifneq (y,$(filter $(BR2_OPTIMIZE_G)$(BR2_OPTIMIZE_0),y))
MPPA_DMA_OPTS += BUILD_TYPE=Release
endif
MPPA_DMA_INSTALL_STAGING = YES

define MPPA_DMA_BUILD_CMDS
	$(MAKE) -C $(@D) TOOLCHAIN=linux \
			 DEVICE_HEADERS=$(MPPA_DMA_MACHINE_HEADERS_PATH) \
			 $(MPPA_DMA_OPTS) all V=2
endef

define MPPA_DMA_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/include/mppa_dma.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -D -m 0644 $(@D)/include/mppa_dma_pcie.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -D -m 0644 $(@D)/include/arch/linux/mppa_dma_macros.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -D -m 0644 $(MPPA_DMA_MACHINE_HEADERS_PATH)/device_inttype.h $(STAGING_DIR)/usr/include/
	$(INSTALL) -D -m 0755 $(@D)/output/lib/cluster/libmppa_dma.so $(STAGING_DIR)/usr/lib/
endef

define MPPA_DMA_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/output/lib/cluster/libmppa_dma.so $(TARGET_DIR)/usr/lib/
endef

$(eval $(generic-package))
