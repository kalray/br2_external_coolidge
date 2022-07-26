################################################################################
#
# mppa-dma
#
################################################################################

MPPA_DMA_WORKSPACE_PATH = $(TOPDIR)/../workspace
MPPA_DMA_SITE = $(MPPA_DMA_WORKSPACE_PATH)/extra_clones/csw-linux/mppa_dma/libs/mppa
MPPA_DMA_MACHINE_HEADERS_PATH = $(STAGING_DIR)/usr/include/machine
MPPA_DMA_SITE_METHOD = local
ifeq ($(BR2_MPPA_DMA_CUSTOM_TARBALL),y)
undefine MPPA_DMA_SITE_METHOD
MPPA_DMA_TARBALL = $(call qstrip,$(BR2_MPPA_DMA_CUSTOM_TARBALL_LOCATION))
MPPA_DMA_SITE = $(patsubst %/,%,$(dir $(MPPA_DMA_TARBALL)))
MPPA_DMA_SOURCE = $(notdir $(MPPA_DMA_TARBALL))
MPPA_DMA_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(MPPA_DMA_SOURCE)
endif
MPPA_DMA_OPTS = TARGET=cluster SYSTEM=linux arch=$(BR2_MARCH)
MPPA_DMA_OPTS += KALRAY_TOOLCHAIN_DIR=$(BR2_EXTERNAL_KVX_PATH)/support/kalray/
MPPA_DMA_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
ifneq (y,$(filter $(BR2_OPTIMIZE_G)$(BR2_OPTIMIZE_0),y))
MPPA_DMA_OPTS += BUILD_TYPE=Release
endif
MPPA_DMA_INSTALL_STAGING = YES

define MPPA_DMA_BUILD_CMDS
	$(MAKE) -C $(@D) TOOLCHAIN=linux \
			 MACHINE_HEADERS=$(MPPA_DMA_MACHINE_HEADERS_PATH) \
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
