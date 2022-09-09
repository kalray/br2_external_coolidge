################################################################################
#
# ODP shared memories module
#
################################################################################

ODP_VERSION ?= custom
ODP_SOURCE = odp-$(ODP_VERSION).tar.gz
ODP_SITE = $(BR2_KALRAY_SOURCE_SITE)
ODP_SITE_METHOD = file
ODP_INSTALL_STAGING = YES
ODP_DEPENDENCIES += mppa-rproc kalray-makefile

ODP_OPTS  = KALRAY_TOOLCHAIN_DIR=$(BR2_KALRAY_TOOLCHAIN_DIR)
ODP_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
ODP_OPTS += arch=$(BR2_MARCH)

ODP_HAS_MODULE := 0

ifeq ($(BR2_PACKAGE_KVX_ODP_NOTIF),y)
	ODP_MODULE_SUBDIRS += linux/kvx_odp_notif
	ODP_HAS_MODULE := 1
endif

ifeq ($(BR2_PACKAGE_KVX_VIRTIONET_MQ),y)
	ODP_MODULE_SUBDIRS += linux/kvx_virtionet_mq
	ODP_HAS_MODULE := 1
# VIRTIO_NET_MQ needs VIRTIO_NET to be enabled in kernel.
define ODP_LINUX_CONFIG_FIXUPS
	$(call KCONFIG_ENABLE_OPT,CONFIG_VIRTIO_NET)
endef
define KVX_VIRTIONET_MQ_INSTALL_TARGET
	$(INSTALL) -D -m 0755 $(@D)/linux/kvx_virtionet_mq/09-kvx-vnet.rules $(TARGET_DIR)/etc/udev/rules.d/09-kvx-vnet.rules
endef
endif

ifeq ($(BR2_ODP_LOAD_MONITOR),y)
ODP_DEPENDENCIES += ncurses
define ODP_LOAD_MONITOR_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)/linux/odp_load_monitor/
endef
define ODP_LOAD_MONITOR_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)/linux/odp_load_monitor/ DESTDIR=$(TARGET_DIR)/usr/bin/ install
endef
endif

ifeq ($(BR2_ODP_PROFILER),y)
define ODP_PROFILER_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)/linux/odp_profiler/
endef
define ODP_PROFILER_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)/linux/odp_profiler/ DESTDIR=$(TARGET_DIR)/usr/bin/ install
endef
endif

ifeq ($(BR2_ODP_LINK_MONITOR),y)
define ODP_LINK_MONITOR_BUILD
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)/linux/odp_link_monitor/
endef
define ODP_LINK_MONITOR_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)/linux/odp_link_monitor/ DESTDIR=$(TARGET_DIR)/usr/bin/ install
endef
endif

ifeq ($(BR2_PACKAGE_KVX_ODP_SHMEM),y)
	ODP_MODULE_SUBDIRS += linux/kvx_odp_shmem
	ODP_HAS_MODULE := 1
endif

ifneq ($(BR2_ODP_SYSCALL_SUPPORT),y)
	ODP_OPTS += IGNORE=libsyscall
endif

define ODP_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D)
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) DEBUG=1
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) build-linux-tests
	$(ODP_LOAD_MONITOR_BUILD)
	$(ODP_PROFILER_BUILD)
	$(ODP_LINK_MONITOR_BUILD)
endef

define  ODP_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(STAGING_DIR)/cluster/ install
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(STAGING_DIR)/cluster/ install-internal-headers
endef

ifeq ($(BR2_ODP_TESTSUITE),y)
define ODP_TESTSUITE_INSTALL_TARGET
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(TARGET_DIR)/lib/firmware/odp/test/ install-firmware-tests
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(TARGET_DIR)/lib/firmware/odp/test/dbg/ DEBUG=1 install-firmware-tests
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(TARGET_DIR)/usr/share/odp/test/scripts install-linux-scripts
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(TARGET_DIR)/usr/share/odp/test/bin install-linux-tests
endef
endif

define  ODP_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/linux/kvx_odp_notif/kvx-conf-odp $(TARGET_DIR)/usr/bin/kvx-conf-odp
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(TARGET_DIR)/lib/firmware/odp/ install-firmware-utils
	$(TARGET_MAKE_ENV) $(MAKE) $(ODP_OPTS) -C $(@D) ODP_INSTALL_DIR=$(TARGET_DIR)/usr/share/odp/scripts/ install-scripts-utils
	$(KVX_VIRTIONET_MQ_INSTALL_TARGET)
	$(ODP_TESTSUITE_INSTALL_TARGET)
	$(ODP_LOAD_MONITOR_INSTALL_TARGET)
	$(ODP_PROFILER_INSTALL_TARGET)
	$(ODP_LINK_MONITOR_INSTALL_TARGET)
endef

ifeq ($(ODP_HAS_MODULE),1)
$(eval $(kernel-module))
endif
$(eval $(generic-package))
