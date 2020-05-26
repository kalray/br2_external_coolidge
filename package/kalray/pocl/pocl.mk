################################################################################
#
# pocl
#
################################################################################

POCL_SITE = $(TOPDIR)/../workspace/extra_clones/csw-linux/opencl/pocl
POCL_SITE_METHOD = local
ifeq ($(BR2_POCL_CUSTOM_TARBALL),y)
undefine POCL_SITE_METHOD
POCL_TARBALL = $(call qstrip,$(BR2_POCL_CUSTOM_TARBALL_LOCATION))
POCL_SITE = $(patsubst %/,%,$(dir $(POCL_TARBALL)))
POCL_SOURCE = $(notdir $(POCL_TARBALL))
POCL_VERSION = custom
POCL_STRIP_COMPONENTS = 2
BR_NO_CHECK_HASH_FOR += $(POCL_SOURCE)
endif
POCL_DEPENDENCIES = mppa-offload mppa-rproc mesa3d-headers
POCL_CONF_OPTS = -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -DDEFAULT_ENABLE_ICD:BOOL=OFF -DHOST_CPU_CACHELINE_SIZE=64 -DOCS_AVAILABLE:BOOL=OFF -DCMAKE_C_FLAGS="-DBUILD_MPPA" -DENABLE_HOST_CPU_DEVICES:BOOL=OFF
POCL_INSTALL_STAGING = YES

$(eval $(cmake-package))
