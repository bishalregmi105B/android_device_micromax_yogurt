#
# Copyright (C) 2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/micromax/yogurt

# Build
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_USES_BUILD_COPY_HEADERS := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_ENFORCE_SYSPROP_OWNER := true

# Assert
TARGET_OTA_ASSERT_DEVICE := E7746,E6746,yogurt

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a75

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := E7746_64
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 480

# Init
# 2026-10-25 migrated per DerpFest/Soong config semantics
# (was: TARGET_INIT_VENDOR_LIB := //$(DEVICE_PATH):libinit_mt6768 — legacy
# make var, now triggers $(error) in vendor/lineage/config/BoardConfigSoong.mk.
# The soong libinit extension lives at system/core/init/Android.bp:241.)
$(call soong_config_set,libinit,vendor_init_lib,//$(DEVICE_PATH):libinit_mt6768)
TARGET_RECOVERY_DEVICE_MODULES := libinit_mt6768

# Kernel
BOARD_BOOTIMG_HEADER_VERSION := 2
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.selinux=enforcing
BOARD_KERNEL_PAGESIZE := 2048
BOARD_RAMDISK_OFFSET := 0x07c08000
BOARD_KERNEL_TAGS_OFFSET := 0x0bc08000
# [A17 campaign 2026-11-03] offsets declared explicitly per spec §4. Values are
# the DF13-proven geometry: base 0x40078000 + standard MTK gz layout with
# tags/dtb riding 0x0bc00000. Nothing changed relative to the A16 manifest.
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_DTB_OFFSET := 0x0bc08000
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_KERNEL_IMAGE_NAME := Image.gz
# [wall-31 LK triage, 2026-10-31 -> A17 2026-11-03] Do NOT embed a dtb in
# boot.img. DF13 proven image (1174b140, sha of its kernel = dc676212 identical
# to ours) ships second_size=0 and is the ONLY image that ever reached YOGURT's
# LK kernel stage post-flash. Our A16 boot.img (2a7f59ace, same kernel bytes,
# only ramdisk/dtb-embed differ) never reached the kernel in any boot attempt.
# DF13 geometry parity until the device-side LK question (system-exec-branch
# crash, image-agnostic) is closed by user-side flash ladder: image bytes can
# only be exonerated against the one proven-good frame.
BOARD_INCLUDE_DTB_IN_BOOTIMG := false
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo.img
TARGET_KERNEL_CONFIG := yogurt_defconfig
TARGET_KERNEL_SOURCE := kernel/micromax/yogurt
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_CLANG_VERSION := r353983c1
TARGET_KERNEL_LLVM_BINUTILS := false

# Kernel - Phase 2 SOURCE build (A17 campaign, kicked 2026-11-03). Master
# prompt §4 mandates a native-eBPF 4.14 rebuild for Android 17: NetBpfLoad on
# A17 hard-aborts (reboot,bootloader,bpfloader-failed) unless the kernel ships
# BPF_JIT/NET_ACT_BPF (A16 used userspace downgrades against the prebuilt
# blob instead; A17 lift requires the kernel fix). yogurt_defconfig gains the
# eBPF Kconfig block; fork branch seventeen carries it + the FocalTech EINT
# rising fix. clang iterates at cmdline r353983c1 (kernel-pinned; fetch the
# prebuilt dir if absent, wall-10 lesson). Filesystem fallback is one flip:
# TARGET_FORCE_PREBUILT_KERNEL := true with the proof-blacked blob intact.
TARGET_FORCE_PREBUILT_KERNEL := false
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilts/kernel
BOARD_INCLUDE_DTB_IN_BOOTIMG :=
BOARD_KERNEL_SEPARATED_DTBO :=
endif

# Partitions
BOARD_FLASH_BLOCK_SIZE := 131072 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_CACHEIMAGE_PARTITION_SIZE := 452984832
BOARD_USERDATAIMAGE_PARTITION_SIZE := 25384959488
# [build-ledger wall 27, 2026-10-30] DF16-lite super geometry: scoped to the
# E7746's REAL physical super (mmcblk0p36 = 4,294,967,296 B exactly). The old
# 9,126,805,504 B values copied the official DF16.2 image budget, which does
# not exist on this hardware (wall-26 side-load verdict: liblp aborts with
# "Not enough free space to expand partition: system" once content-derived
# fs sizes -- product 2,756,288,512 + system 2,661,220,352 + vendor
# 589,488,128 ~= 6.0 GB -- are allocated into 4.0 GB of physical space).
# New budget (measured DF16.2 content sizes minus core-GMS trim, vendor/gms
# product fs ~2.49 GB -> ~0.9 GB; see vendor/gms/common/common-vendor.mk):
#   super            = 4,294,967,296  (real partition)
#   group max        = 4,290,772,992  (super - 4 MiB liblp metadata headroom)
#   per-partition reserve: 256 MiB -> 64 MiB (content-derived fs sizes must
#   all fit the group together; system 2.48 GB + product ~0.96 GB + vendor
#   0.59 GB ~= 4.05 GB <= 4.29 GB, ~0.37 GB slack).
BOARD_SUPER_PARTITION_SIZE := 4294967296
BOARD_SUPER_PARTITION_GROUPS := micromax_dynamic_partitions
BOARD_MICROMAX_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    product \
    system \
    vendor

BOARD_MICROMAX_DYNAMIC_PARTITIONS_SIZE := 4290772992
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 0
BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 0
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product

# Metadata
BOARD_ROOT_EXTRA_FOLDERS += metadata
BOARD_USES_METADATA_PARTITION := true

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Platform
TARGET_BOARD_PLATFORM := mt6768

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6768
BOARD_INCLUDE_RECOVERY_DTBO := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Security patch level
VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 3

# Sepolicy
include device/mediatek/sepolicy_vndr/SEPolicy.mk

# 2026-10-25 Lineage/DerpFest config chain (BootConfigSoong/Kernel) — required
# so the soong lineageVarsPlugin registers KERNEL_*, TARGET_KERNEL_* vars used
# by vendor/lineage/build/soong generated_kernel_includes. Pinned ***
BOARD_USES_FULL_RECOVERY_IMAGE := false  # stock E7746: separate recovery.img (DF13 OTA proof)
TARGET_KERNEL_NO_GCC := true             # A16 prebuilts have no gcc-4.9; headers_install = host tools
ifeq ($(LINEAGE_BUILD),)
include vendor/lineage/config/BoardConfigLineage.mk
include device/lineage/sepolicy/common/sepolicy.mk
endif
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
TARGET_USING_LEGACY_SELINUX := true

# HIDL
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xml
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/configs/vintf/manifest.xml

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := $(DEVICE_PATH)
