################################################################################
#
# coolval 
#
################################################################################

COOLVAL_SITE = $(TOPDIR)/../linux_valid/coolval
COOLVAL_SITE_METHOD = local
COOLVAL_MODULE_SUBDIRS = src/module_tests src/k1c_dma_noc_test
COOLVAL_MODULE_MAKE_OPTS = KCFLAGS=-I$(LINUX_DIR)/drivers/dma/k1
COOLVAL_INSTALL_DIR = $(TARGET_DIR)/opt/coolval

define COOLVAL_BUILD_CMDS
	CROSS_COMPILE=$(TARGET_CROSS)  $(MAKE) -C $(@D)
endef

define COOLVAL_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/coolval $(COOLVAL_INSTALL_DIR)/run_tests
	$(INSTALL) -D -m 0755 $(COOLVAL_PKGDIR)/scripts/* $(COOLVAL_INSTALL_DIR)
endef

define COOLVAL_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(COOLVAL_PKGDIR)/S30coolval $(TARGET_DIR)/etc/init.d/
endef

$(eval $(kernel-module))
$(eval $(generic-package))
