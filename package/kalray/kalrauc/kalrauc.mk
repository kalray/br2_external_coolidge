################################################################################
#
# kalrauc
#
################################################################################

KALRAUC_VERSION = custom
KALRAUC_SITE_METHOD = file
KALRAUC_SITE = $(patsubst %/,%,$(dir $(KALRAUC_TARBALL)))
KALRAUC_TARBALL = $(call qstrip,$(BR2_KALRAUC_CUSTOM_TARBALL_LOCATION))
KALRAUC_SOURCE = $(notdir $(KALRAUC_TARBALL))
KALRAUC_LICENSE = LGPL-2.1
KALRAUC_LICENSE_FILES = COPYING
KALRAUC_DEPENDENCIES = host-pkgconf openssl libglib2 dbus
BR_NO_CHECK_HASH_FOR += $(KALRAUC_SOURCE)

ifeq ($(BR2_PACKAGE_KALRAUC_NETWORK),y)
KALRAUC_CONF_OPTS += --enable-network
KALRAUC_DEPENDENCIES += libcurl
else
KALRAUC_CONF_OPTS += --disable-network
endif

ifeq ($(BR2_PACKAGE_KALRAUC_JSON),y)
KALRAUC_CONF_OPTS += --enable-json
KALRAUC_DEPENDENCIES += json-glib
else
KALRAUC_CONF_OPTS += --disable-json
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
# configure uses pkg-config --variable=systemdsystemunitdir systemd
KALRAUC_DEPENDENCIES += systemd
endif

define KALRAUC_INSTALL_INIT_SYSTEMD
	mkdir $(TARGET_DIR)/usr/lib/systemd/system/rauc.service.d
	printf '[Install]\nWantedBy=multi-user.target\n' \
		>$(TARGET_DIR)/usr/lib/systemd/system/rauc.service.d/buildroot-enable.conf
endef

HOST_KALRAUC_DEPENDENCIES = \
	host-pkgconf \
	host-openssl \
	host-libglib2 \
	host-squashfs \
	$(if $(BR2_PACKAGE_HOST_LIBP11),host-libp11)
HOST_KALRAUC_CONF_OPTS += \
	--disable-network \
	--disable-json \
	--disable-service \
	--without-dbuspolicydir

$(eval $(autotools-package))
$(eval $(host-autotools-package))
