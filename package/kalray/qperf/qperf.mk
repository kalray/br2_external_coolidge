################################################################################
#
# qperf-dpdk
#
################################################################################

QPERF_VERSION = 0.4.11
QPERF_SITE = $(call github,linux-rdma,qperf,v$(QPERF_VERSION))
QPERF_INSTALL_STAGING = YES
QPERF_DEPENDENCIES += host-autoconf host-pkgconf
QPERF_CONF_ENV += CFLAGS="$(TARGET_CFLAGS)"
QPERF_PRE_CONFIGURE_HOOKS += QPERF_RUN_AUTOGEN

define QPERF_RUN_AUTOGEN
	cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

$(eval $(autotools-package))
