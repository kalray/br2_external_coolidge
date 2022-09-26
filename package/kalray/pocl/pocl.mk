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
BR_NO_CHECK_HASH_FOR += $(POCL_SOURCE)
endif
POCL_DEPENDENCIES = mppa-offload mppa-rproc mesa3d-headers
POCL_BUILD_OPTIMIZE = -O0 -g3
ifneq (y,$(filter $(BR2_OPTIMIZE_G)$(BR2_OPTIMIZE_0),y))
POCL_BUILD_OPTIMIZE = -O2
endif
POCL_CONF_OPTS = -DINSTALL_OPENCL_HEADERS:BOOL=ON \
                 -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
                 -DDEFAULT_ENABLE_ICD:BOOL=OFF \
                 -DHOST_CPU_CACHELINE_SIZE=64 \
                 -DENABLE_LLVM:BOOL=OFF \
                 -DENABLE_TESTS:BOOL=OFF \
                 -DENABLE_POCLCC:BOOL=OFF \
                 -DENABLE_EXAMPLES:BOOL=OFF \
                 -DENABLE_LOADABLE_DRIVERS:BOOL=OFF \
                 -DCMAKE_C_FLAGS="-DBUILD_MPPA $(POCL_BUILD_OPTIMIZE)" \
                 -DENABLE_HOST_CPU_DEVICES:BOOL=OFF
POCL_INSTALL_STAGING = YES

$(eval $(cmake-package))
