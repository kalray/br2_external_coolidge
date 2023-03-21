################################################################################
#
# MPPA cluster helpers
#
################################################################################

MPPA_HELPER_LIBS_VERSION = $(call qstrip,$(BR2_MPPA_HELPER_LIBS_VERSION))
MPPA_HELPER_LIBS_SITE = $(call kalray,$(1),$(MPPA_HELPER_LIBS_VERSION))
MPPA_HELPER_LIBS_INSTALL_STAGING = YES
MPPA_HELPER_LIBS_DEPENDENCIES += mppa-rproc kalray-makefile

BR_NO_CHECK_HASH_FOR += $(MPPA_HELPER_LIBS_SOURCE)

MPPA_HELPER_LIBS_OPTS  = KALRAY_TOOLCHAIN_DIR=$(BR2_KALRAY_TOOLCHAIN_DIR)
MPPA_HELPER_LIBS_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
MPPA_HELPER_LIBS_OPTS += arch=$(BR2_MARCH)

MPPA_HELPER_LIBS_COS_OPTS += PREFIX=$(STAGING_DIR)/cluster/

MPPA_HELPER_LIBS_HAS_MODULE := 0

ifeq ($(BR2_MPPA_LOAD_MONITOR),y)
MPPA_HELPER_LIBS_DEPENDENCIES += ncurses
define MPPA_LOAD_MONITOR_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_OPTS) -C $(@D)/linux/mppa_load_monitor/
endef
define MPPA_LOAD_MONITOR_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_OPTS) -C $(@D)/linux/mppa_load_monitor/ DESTDIR=$(TARGET_DIR)/usr/bin/ install
endef
endif

ifeq ($(BR2_MPPA_PROFILER),y)
define MPPA_PROFILER_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_OPTS) -C $(@D)/linux/mppa_profiler/
endef
define MPPA_PROFILER_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_OPTS) -C $(@D)/linux/mppa_profiler/ DESTDIR=$(TARGET_DIR)/usr/bin/ install
endef
endif

ifeq ($(BR2_MPPA_LINK_MONITOR),y)
define MPPA_LINK_MONITOR_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_OPTS) -C $(@D)/linux/mppa_link_monitor/
endef
define MPPA_LINK_MONITOR_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_OPTS) -C $(@D)/linux/mppa_link_monitor/ DESTDIR=$(TARGET_DIR)/usr/bin/ install
endef
endif

ifeq ($(BR2_PACKAGE_MPPA_SHMEM_KERNEL),y)
	MPPA_HELPER_LIBS_MODULE_SUBDIRS += linux/mppa_shmem
	MPPA_HELPER_LIBS_HAS_MODULE := 1
endif


define MPPA_HELPER_LIBS_BUILD_CMDS
	#$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/dma_memcpy 
	#$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/libperfs 
	#$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/shmem
	#$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/profiler 
	#$(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/load_mon 
	$(MPPA_LOAD_MONITOR_BUILD)
	$(MPPA_PROFILER_BUILD)
	$(MPPA_LINK_MONITOR_BUILD)
endef

define MPPA_HELPER_LIBS_INSTALL_STAGING_CMDS
	# $(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/dma_memcpy install
	# $(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/libperfs install
	# $(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/shmem install
	# $(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/profiler install
	# $(TARGET_MAKE_ENV) $(MAKE) $(MPPA_HELPER_LIBS_COS_OPTS) -C $(@D)/cos/load_mon install
endef

define MPPA_HELPER_LIBS_INSTALL_TARGET_CMDS
	$(MPPA_LOAD_MONITOR_INSTALL_TARGET)
	$(MPPA_PROFILER_INSTALL_TARGET)
	$(MPPA_LINK_MONITOR_INSTALL_TARGET)
endef

ifeq ($(MPPA_HELPER_LIBS_HAS_MODULE),1)
$(eval $(kernel-module))
endif
$(eval $(generic-package))
