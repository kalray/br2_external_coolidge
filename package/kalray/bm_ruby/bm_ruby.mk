################################################################################
#
# bm_ruby
#
################################################################################

BM_RUBY_VERSION ?= custom
BM_RUBY_SOURCE = bm_ruby-$(BM_RUBY_VERSION).tar.gz
BM_RUBY_SITE = $(BR2_KALRAY_SOURCE_SITE)
BM_RUBY_SITE_METHOD = file
BM_RUBY_INSTALL_STAGING = YES
BM_RUBY_DEPENDENCIES = ruby libmppabm

BM_RUBY_CFLAGS_EXTRA = -fPIC -fstack-protector-strong
BM_RUBY_INCLUDES = -I$(BUILD_DIR)/ruby-$(RUBY_VERSION)/include \
                   -I$(BR2_KALRAY_TOOLCHAIN_DIR)/include

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
BM_RUBY_INCLUDES +=-I$(BUILD_DIR)/ruby-$(RUBY_VERSION)/.ext/include/kvx-linux-uclibc
else ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
BM_RUBY_INCLUDES +=-I$(BUILD_DIR)/ruby-$(RUBY_VERSION)/.ext/include/kvx-linux-musl
endif

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
		     -o $(@D)/utils/bm_ruby/bm_ruby_api.o \
		     -c $(@D)/utils/bm_ruby/src/mppabm/bm_ruby_api.c
	$(TARGET_CC) $(BM_RUBY_LFLAGS_EXTRA) \
		     -L $(TARGET_DIR)/usr/lib \
		     -o $(@D)/utils/bm_ruby/mppabm.so \
		     $(@D)/utils/bm_ruby/bm_ruby_api.o
endef

define BM_RUBY_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/lib/ruby/$(RUBY_VERSION_EXT)/mppabm
	$(INSTALL) -D -m 0755 $(@D)/utils/bm_ruby/lib/mppabm.rb $(BM_RUBY_STAGING_DIR)/
	$(INSTALL) -D -m 0755 $(@D)/utils/bm_ruby/mppabm.so $(BM_RUBY_STAGING_DIR)/mppabm
endef

define BM_RUBY_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib/ruby/$(RUBY_VERSION_EXT)/mppabm
	$(INSTALL) -D -m 0755 $(@D)/utils/bm_ruby/lib/mppabm.rb $(BM_RUBY_TARGET_DIR)/
	$(INSTALL) -D -m 0755 $(@D)/utils/bm_ruby/mppabm.so $(BM_RUBY_TARGET_DIR)/mppabm
endef

$(eval $(generic-package))

