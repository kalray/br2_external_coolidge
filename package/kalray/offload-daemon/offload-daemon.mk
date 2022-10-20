################################################################################
#
# offload-daemon
#
################################################################################

OFFLOAD_DAEMON_VERSION = $(call qstrip,$(BR2_OFFLOAD_DAEMON_VERSION))
OFFLOAD_DAEMON_SITE = $(call kalray,$(1),$(OFFLOAD_DAEMON_VERSION))
OFFLOAD_DAEMON_INSTALL_STAGING = YES
OFFLOAD_DAEMON_DEPENDENCIES = mppa-rproc libevent libdaemon json-c kalray-makefile

BR_NO_CHECK_HASH_FOR += $(OFFLOAD_DAEMON_SOURCE)

OFFLOAD_DAEMON_OPTS = TARGET=cluster arch=$(BR2_MARCH)
OFFLOAD_DAEMON_OPTS += KALRAY_TOOLCHAIN_DIR=$(STAGING_DIR)/opt/kalray/accesscore
OFFLOAD_DAEMON_OPTS += LINUX_TOOLCHAIN_PREFIX=$(TARGET_CROSS)
OFFLOAD_DAEMON_OPTS += PKG_CONFIG=$(PKG_CONFIG_HOST_BINARY)

define OFFLOAD_DAEMON_BUILD_CMDS
	$(MAKE) -C $(@D) $(OFFLOAD_DAEMON_OPTS) all
endef

define OFFLOAD_DAEMON_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0644 $(@D)/src/include/libmopd.h $(STAGING_DIR)/usr/include/libmopd.h
	$(INSTALL) -D -m 0644 $(@D)/src/include/mopd_common.h $(STAGING_DIR)/usr/include/mopd_common.h
	$(INSTALL) -D -m 0755 $(@D)/output/lib/cluster/libmopd.so $(STAGING_DIR)/usr/lib/libmopd.so
endef

define OFFLOAD_DAEMON_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/output/bin/kvx-mopd $(TARGET_DIR)/usr/sbin/kvx-mopd
	$(INSTALL) -D -m 0755 $(@D)/output/lib/cluster/libmopd.so $(TARGET_DIR)/usr/lib/libmopd.so
endef

$(eval $(generic-package))
