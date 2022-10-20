include $(BR2_EXTERNAL_KVX_PATH)/tarball_versions.mk
include $(sort $(wildcard $(BR2_EXTERNAL_KVX_PATH)/package/kalray/*/*.mk))
