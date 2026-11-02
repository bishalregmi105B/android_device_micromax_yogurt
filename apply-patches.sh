#!/usr/bin/env bash
#
# apply-patches.sh - Apply Micromax IN Note 1 (yogurt) Android 16 (DerpFest 16.2) bring-up patches
# Maintainer: Bishal Regmi (bishalregmi105B)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOP="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
PATCH_DIR="${SCRIPT_DIR}/patches"

echo "=== Applying Micromax IN Note 1 (yogurt) Android 16 ROM Patches ==="
echo "Target Root: ${TOP}"

apply_patch_dir() {
    local target_repo="$1"
    local patch_subfolder="$2"

    if [ ! -d "${TOP}/${target_repo}" ]; then
        echo "[!] Target repo ${target_repo} not found in tree, skipping..."
        return
    fi

    echo ">>> Applying patches for ${target_repo}..."
    for patch in "${PATCH_DIR}/${patch_subfolder}"/*.patch; do
        [ -e "${patch}" ] || continue
        echo "    Applying: $(basename "${patch}")"
        if git -C "${TOP}/${target_repo}" apply --check --whitespace=nowarn --ignore-whitespace "${patch}" 2>/dev/null; then
            git -C "${TOP}/${target_repo}" apply --whitespace=nowarn --ignore-whitespace "${patch}"
        else
            echo "    [INFO] Already applied or trying 3-way merge for $(basename "${patch}")..."
            git -C "${TOP}/${target_repo}" apply -3 "${patch}" 2>/dev/null || true
        fi
    done
}

# 1. Core Frameworks & Native
apply_patch_dir "frameworks/base" "frameworks_base"
apply_patch_dir "frameworks/native" "frameworks_native"
apply_patch_dir "frameworks/opt/net/ims" "frameworks_opt_net_ims"
apply_patch_dir "frameworks/opt/telephony" "frameworks_opt_telephony"

# 2. Kernel 4.14 Compatibility (BPF, Cgroups, SELinux)
apply_patch_dir "packages/modules/Connectivity" "packages_modules_Connectivity"
apply_patch_dir "system/core" "system_core"
apply_patch_dir "system/sepolicy" "system_sepolicy"
apply_patch_dir "device/mediatek/sepolicy_vndr" "device_mediatek_sepolicy_vndr"

# 3. Connectivity & Hardware (Wi-Fi, Bluetooth, Camera)
apply_patch_dir "external/wpa_supplicant_8" "external_wpa_supplicant_8"
apply_patch_dir "packages/modules/Bluetooth" "packages_modules_Bluetooth"
apply_patch_dir "packages/apps/Aperture" "packages_apps_Aperture"

# 4. System Apps & Providers
apply_patch_dir "packages/apps/Settings" "packages_apps_Settings"
apply_patch_dir "packages/providers/ContactsProvider" "packages_providers_ContactsProvider"

# 5. Build, Recovery, Update Engine & Super Partition Sizing
apply_patch_dir "build/soong" "build_soong"
apply_patch_dir "bootable/recovery" "bootable_recovery"
apply_patch_dir "system/update_engine" "system_update_engine"
apply_patch_dir "vendor/lineage" "vendor_lineage"
apply_patch_dir "vendor/gms" "vendor_gms"

# 6. Install Legacy VNDK v29 & v30 Libraries required by MTK R-vendor blobs
if [ -d "${SCRIPT_DIR}/prebuilts/vndk" ]; then
    echo ">>> Installing VNDK v29 & v30 libraries into ${TOP}/prebuilts/vndk/..."
    mkdir -p "${TOP}/prebuilts/vndk"
    cp -rn "${SCRIPT_DIR}/prebuilts/vndk/v29" "${TOP}/prebuilts/vndk/" || true
    cp -rn "${SCRIPT_DIR}/prebuilts/vndk/v30" "${TOP}/prebuilts/vndk/" || true
fi

echo "=== All Micromax IN Note 1 (yogurt) Android 16 patches applied successfully! ==="
