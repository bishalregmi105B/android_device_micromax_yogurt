# Android 16 (DerpFest 16.2) Device Tree for Micromax IN Note 1 (`yogurt`)

Device configuration for **Micromax IN Note 1 (`E7746` / `yogurt`, MediaTek Helio G85 `MT6768`)** supporting **Android 16 QPR2 (`BP4A.251205.006`, SDK 36)**.

---

## 🔧 How It Boots & Works on Legacy 4.14 Kernel + R-Vendor Blobs

Android 16 drops legacy VNDK/FCM support and enforces strict kernel 5.4+ BPF, cgroup v2, fs-verity, and AIDL requirements. To make Android 16 boot and work with `SELinux Enforcing` on `yogurt`'s prebuilt `4.14.186` kernel and MediaTek vendor blobs, this tree and its bundled `patches/` implement the following engineering fixes:

### 1. Kernel 4.14 eBPF & Netd Bypass (`packages/modules/Connectivity`, `system/sepolicy`)
- **Problem**: `yogurt`'s 4.14 kernel lacks `CONFIG_BPF_JIT` and `CONFIG_NET_ACT_BPF`. Android 16's `NetBpfLoad` hard-aborts when kernel `< 5.4` or when BPF program verifier / map creation fails, causing an early `init` reboot loop (`reboot,bootloader,bpfloader-failed`).
- **Fix**: Patched `NetBpfLoad.cpp`, `BpfHandler.cpp`, `ClatCoordinator.cpp`, `offload.c`, and `SingleWriterBpfMap.java` to gracefully downgrade BPF failures to non-fatal warnings and allow legacy netd operation without crashing `system_server` or `network_stack`.

### 2. Cgroups & `apexd-bootstrap` (`system/core`, `rootdir/etc/fstab.mt6768`)
- **Problem**: Android 16's `libprocessgroup` requires cgroup v2 controllers not exposed by the 4.14 kernel, and `apexd-bootstrap` fails if `/metadata` (`mmcblk0p10`) or fstab flags are mismatched.
- **Fix**: Marked unsupported cgroup mounts optional in `cgroups.json` and aligned `fstab.mt6768` for `first_stage_mount`.

### 3. VINTF FCM Target Level 4 $\rightarrow$ 5 Migration (`configs/vintf/`)
- **Problem**: Android 16 removed Framework Compatibility Matrix (FCM) levels $\le 4$.
- **Fix**: Re-declared `configs/vintf/manifest.xml` at `target-level="5"` (the R-vendor lane in Android 16) and authored a 27-HAL / 62-instance [`configs/vintf/framework_compatibility_matrix.xml`](configs/vintf/framework_compatibility_matrix.xml) acknowledging all legacy MediaTek & Microtrust vendor HALs.

### 4. Fingerprint HAL (`focaltech` / `Microtrust TEEI`) Fix (`fingerprint/`, `sepolicy/`, `vendor`)
- **Problem**: Fingerprint HAL (`android.hardware.biometrics.fingerprint@2.1-service`) crashed on boot due to `vndbinder` mmap SELinux denials, `/data/vendor/focaltech` file context denials, and unhandled null notify callbacks.
- **Fix**: Added `vndbinder` & `focaltech` permissions in [`sepolicy/vendor/hal_fingerprint_default.te`](sepolicy/vendor/hal_fingerprint_default.te), hardened [`fingerprint/BiometricsFingerprint.cpp`](fingerprint/BiometricsFingerprint.cpp), and shimmed `fingerprint.default.so` + `vendor.microtrust.hardware.capi@2.0-service` in the vendor tree.

### 5. RIL, VoLTE / IMS & Wi-Fi Compatibility (`frameworks/opt/*`, `libshims/`, `vendor`)
- **Problem**: Android 16 removed `ImsServiceBase`, `TelephonyMetrics`, `SmsMessageConverter`, and `SubscriptionManager.getSimStateForSlotIndex()`, breaking MediaTek's `ImsService.apk` and `mediatek-ims-extension-plugin.jar`.
- **Fix**: Restored lightweight compatibility shims in `frameworks/opt/net/ims`, `frameworks/opt/telephony`, `frameworks/base`, whitelisted `com.android.ims` in `build/soong` boot jars, and shimmed `libmtk-ril.so` / `librilfusion.so` / `wpa_supplicant` in `vendor/micromax/yogurt`.

### 6. Graphic Buffer & Video Codec Alignment (`frameworks/native`, `configs/media/`)
- **Problem**: Buffer queue stalls on legacy MTK Gralloc/GPU blobs and corrupted video playback in WhatsApp/TikTok due to non-16x16 macroblock alignment.
- **Fix**: Patched `BLASTBufferQueue.cpp` for legacy consumer stalls, configured 16x16 alignment in [`configs/media/media_codecs_mediatek_video.xml`](configs/media/media_codecs_mediatek_video.xml), and enabled native SurfaceFlinger blurs (`ro.surface_flinger.supports_background_blur=1`).

### 7. Dynamic Partition (`super` = 4.29 GB) & Recovery OTA Sideload (`BoardConfig.mk`, `system/update_engine`)
- **Problem**: `mmcblk0p36` (`super`) is strictly `4,294,967,296` bytes (`4,290,772,992` bytes dynamic group). Android 16 + GMS overflows this limit if default reserved sizes are kept, and recovery sideload requires `boot_control_recovery` + `dynamic_partition_control_android` support.
- **Fix**: Set `BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 0` and `BOARD_PRODUCTIMAGE_PARTITION_RESERVED_SIZE := 0`, trimmed redundant GMS bloat (`vendor/gms` patch), and patched `system/update_engine` + `bootable/recovery` for seamless `adb sideload`.

---

## 🚀 How to Build

### 1. Initialize DerpFest 16.2 Repo
```bash
repo init -u https://github.com/DerpFest-AOSP/android_manifest.git -b 16.2 --git-lfs
```

### 2. Clone Device, Vendor & SELinux Trees
Copy [`local_manifests/yogurt.xml`](local_manifests/yogurt.xml) to `.repo/local_manifests/yogurt.xml`, or clone directly:
```bash
git clone https://github.com/bishalregmi105B/android_device_micromax_yogurt -b sixteen device/micromax/yogurt
git clone https://github.com/bishalregmi105B/android_vendor_micromax_yogurt -b sixteen vendor/micromax/yogurt
git clone https://github.com/bishalregmi105B/android_device_mediatek_sepolicy_vndr -b sixteen device/mediatek/sepolicy_vndr
git clone https://github.com/LineageOS/android_hardware_mediatek -b lineage-23.2 hardware/mediatek
```

### 3. Apply AOSP & VNDK Compatibility Patches
Run the automated patch script included in this device tree:
```bash
bash device/micromax/yogurt/apply-patches.sh
```
*(This applies all 18 AOSP/ROM patch sets in [`patches/`](patches/) and installs the required VNDK v29/v30 libraries from [`prebuilts/vndk/`](prebuilts/vndk/) into `prebuilts/vndk/`.)*

### 4. Compile the ROM
```bash
source build/envsetup.sh
lunch derp_yogurt-bp4a-user
m derp
```
