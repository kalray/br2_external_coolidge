################################################################################
#
# ODP notification module
#
################################################################################

KVX_ODP_NOTIF_SITE         = $(BR2_EXTERNAL_KVX_PATH)/projects/kvx_odp_notif
KVX_ODP_NOTIF_SITE_METHOD  = local

define KVX_ODP_NOTIF_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/kvx-conf-odp $(TARGET_DIR)/usr/bin/kvx-conf-odp
endef

$(eval $(kernel-module))
$(eval $(generic-package))
