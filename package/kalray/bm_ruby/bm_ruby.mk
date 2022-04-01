################################################################################
#
# bm_ruby
#
################################################################################

BM_RUBY_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/board_mgmt/utils/bm_ruby
BM_RUBY_SITE_METHOD = local
BM_RUBY_DEPENDENCIES = ruby libmppabm
BM_RUBY_INSTALL_STAGING = YES

BM_RUBY_CFLAGS_EXTRA = -fPIC -fstack-protector-strong
BM_RUBY_INCLUDES = -I $(TARGET_DIR)/usr/include/ruby-$(RUBY_VERSION_EXT) \
                   -I $(TARGET_DIR)/usr/include/ruby-$(RUBY_VERSION_EXT)/kvx-linux-uclibc \
                   -I $(TOPDIR)/../workspace/extra_clones/csw-linux/board_mgmt/common/include
BM_RUBY_LFLAGS_EXTRA = -fstack-protector \
                       -shared \
                       -rdynamic \
                       -Wl,-export-dynamic \
                       -Wl,-Bsymbolic-functions
BM_RUBY_RELATIVE_DIR = /usr/lib/ruby/$(RUBY_VERSION_EXT)
BM_RUBY_STAGING_DIR = $(STAGING_DIR)/$(BM_RUBY_RELATIVE_DIR)
BM_RUBY_TARGET_DIR = $(TARGET_DIR)/$(BM_RUBY_RELATIVE_DIR)

define BM_RUBY_BUILD_CMDS
	$(TARGET_CC) $(BM_RUBY_CFLAGS_EXTRA) \
		     $(BM_RUBY_INCLUDES) \
		     -o $(@D)/bm_ruby_api.o \
		     -c $(@D)/src/mppabm/bm_ruby_api.c
	$(TARGET_CC) $(BM_RUBY_LFLAGS_EXTRA) \
		     -L $(TARGET_DIR)/usr/lib \
		     -o $(@D)/mppabm.so \
		     $(@D)/bm_ruby_api.o
endef

define BM_RUBY_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/lib/ruby/$(RUBY_VERSION_EXT)/mppabm
	$(INSTALL) -D -m 0755 $(@D)/lib/mppabm.rb $(BM_RUBY_STAGING_DIR)/
	$(INSTALL) -D -m 0755 $(@D)/mppabm.so $(BM_RUBY_STAGING_DIR)/mppabm
endef

define BM_RUBY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib/ruby/$(RUBY_VERSION_EXT)/mppabm
	$(INSTALL) -D -m 0755 $(@D)/lib/mppabm.rb $(BM_RUBY_TARGET_DIR)/
	$(INSTALL) -D -m 0755 $(@D)/mppabm.so $(BM_RUBY_TARGET_DIR)/mppabm
endef

$(eval $(generic-package))

