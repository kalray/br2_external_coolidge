################################################################################
#
# board_mgmt
#
################################################################################

BOARD_MGMT_SOURCE = board_mgmt-$(BOARD_MGMT_CUSTOM_VERSION).tar.gz
BOARD_MGMT_SITE = $(BR2_KALRAY_PACKAGES_SITE)
BOARD_MGMT_DEPENDENCIES = bm_ruby libmppabm readline ncurses
BOARD_MGMT_INSTALL_STAGING = YES

# Overwrite linker flags of the Makefile to pass ncurses instead of termcap
# because in Buildroot all the libtermcap functions are implemented by
# libncurses
BOARD_MGMT_LFLAGS_EXTRA ="kvx-board-mgmt-lflags := -L$(TARGET_DIR)/usr/lib \
                                                   -lmppabm \
                                                   -lreadline \
                                                   -lncurses"
BOARD_FLASH_LFLAGS_EXTRA ="kvx-board-flash-lflags := -L$(TARGET_DIR)/usr/lib \
                                                     -lmppabm"

define BOARD_MGMT_BUILD_CMDS
	$(MAKE) O=$(@D)/output -C $(@D) CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		WITH_MPSSE_IF=0 $(BOARD_MGMT_LFLAGS_EXTRA) kvx-board-mgmt
	$(MAKE) O=$(@D)/output -C $(@D) CC="$(TARGET_CC)" LD="$(TARGET_LD)" \
		WITH_MPSSE_IF=0 $(BOARD_FLASH_LFLAGS_EXTRA) kvx-board-flash
endef

define BOARD_MGMT_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 0755 $(@D)/utils/kvx-board-diag $(STAGING_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/utils/kvx-board-image $(STAGING_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/utils/kvx-board-cfg-merge $(STAGING_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/output/bin/kvx-board-mgmt $(STAGING_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/output/bin/kvx-board-flash $(STAGING_DIR)/usr/bin/
endef

define BOARD_MGMT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/utils/kvx-board-diag $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/utils/kvx-board-image $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/utils/kvx-board-cfg-merge $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/output/bin/kvx-board-mgmt $(TARGET_DIR)/usr/bin/
	$(INSTALL) -D -m 0755 $(@D)/output/bin/kvx-board-flash $(TARGET_DIR)/usr/bin/
endef

$(eval $(generic-package))

