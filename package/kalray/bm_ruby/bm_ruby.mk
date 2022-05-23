################################################################################
#
# bm_ruby
#
################################################################################

BM_RUBY_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/board_mgmt/utils/bm_ruby
BM_RUBY_SITE_METHOD = local
BM_RUBY_DEPENDENCIES = ruby libmppabm
BM_RUBY_INSTALL_STAGING = YES

ifeq ($(BR2_BM_RUBY_CUSTOM_TARBALL),y)
undefine BM_RUBY_SITE_METHOD
BM_RUBY_TARBALL = $(call qstrip,$(BR2_BM_RUBY_CUSTOM_TARBALL_LOCATION))
BM_RUBY_SITE = $(patsubst %/,%,$(dir $(BM_RUBY_TARBALL)))
BM_RUBY_SOURCE = $(notdir $(BM_RUBY_TARBALL))
BM_RUBY_VERSION = custom
BR_NO_CHECK_HASH_FOR += $(BM_RUBY_SOURCE)
endif

BM_RUBY_CFLAGS_EXTRA = -fPIC -fstack-protector-strong
BM_RUBY_INCLUDES = -I$(BUILD_DIR)/ruby-$(RUBY_VERSION)/include \
                   -I$(BUILD_DIR)/ruby-$(RUBY_VERSION)/.ext/include/kvx-linux-uclibc \
                   -I$(BR2_KALRAY_TOOLCHAIN_DIR)/include
BM_RUBY_LFLAGS_EXTRA = -fstack-protector \
                       -shared \
                       -rdynamic \
                       -Wl,-export-dynamic \
                       -Wl,-Bsymbolic-functions \
                       -lruby \
                       -lmppabm \
                       -lpthread \
                       -ldl \
                       -lcrypt \
                       -lm

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

