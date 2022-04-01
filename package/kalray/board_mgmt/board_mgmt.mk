################################################################################
#
# board_mgmt
#
################################################################################

BOARD_MGMT_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/board_mgmt/utils
BOARD_MGMT_SITE_METHOD = local
BOARD_MGMT_DEPENDENCIES = bm_ruby libmppabm
BOARD_MGMT_INSTALL_STAGING = YES

define BOARD_MGMT_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/kvx-board-diag $(STAGING_DIR)/usr/bin/
endef

define BOARD_MGMT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/kvx-board-diag $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))

