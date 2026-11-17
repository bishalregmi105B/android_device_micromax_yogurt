/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include "Memtrack.h"

#include <unistd.h>

#include <cstdint>
#include <cstdio>
#include <memory>

namespace aidl {
namespace android {
namespace hardware {
namespace memtrack {

namespace {

constexpr const char* kMaliMemoryUsagePath = "/proc/mali/memory_usage";

int64_t readMaliGlMemoryBytes(int pid) {
    std::unique_ptr<FILE, decltype(&std::fclose)> fp(std::fopen(kMaliMemoryUsagePath, "r"),
                                                     &std::fclose);
    if (!fp) {
        return 0;
    }

    const int64_t pageSize = sysconf(_SC_PAGESIZE);
    int64_t matchedBytes = 0;
    char line[256];

    while (std::fgets(line, sizeof(line), fp.get()) != nullptr) {
        if (pid == 0) {
            unsigned long long totalPages = 0;
            unsigned long long totalBytes = 0;
            int fields = std::sscanf(line, " Total %llu(%llu bytes)", &totalPages, &totalBytes);
            if (fields == 2) {
                return static_cast<int64_t>(totalBytes);
            }
            if (fields == 1) {
                return static_cast<int64_t>(totalPages) * pageSize;
            }
        } else {
            int linePid = 0;
            long long usedPages = 0;
            if (std::sscanf(line, " %d %lld", &linePid, &usedPages) == 2 && linePid == pid &&
                usedPages > 0) {
                matchedBytes += static_cast<int64_t>(usedPages) * pageSize;
            }
        }
    }

    return matchedBytes;
}

}  // namespace

ndk::ScopedAStatus Memtrack::getMemory(int pid, MemtrackType type,
                                       std::vector<MemtrackRecord>* _aidl_return) {
    if (pid < 0) {
        return ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    _aidl_return->clear();

    // libmemtrack fails the entire memtrack_proc_get() query if any type returns an error,
    // so return an empty record list for categories without procfs accounting on 4.14.
    if (type != MemtrackType::GL) {
        return ndk::ScopedAStatus::ok();
    }

    const int64_t glBytes = readMaliGlMemoryBytes(pid);
    if (glBytes > 0) {
        MemtrackRecord record = {
                .flags = MemtrackRecord::FLAG_SMAPS_UNACCOUNTED | MemtrackRecord::FLAG_PRIVATE |
                         MemtrackRecord::FLAG_DEDICATED,
                .sizeInBytes = glBytes,
        };
        _aidl_return->push_back(record);
    }

    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Memtrack::getGpuDeviceInfo(std::vector<DeviceInfo>* _aidl_return) {
    _aidl_return->clear();
    DeviceInfo gpu = {
            .id = 0,
            .name = "Mali-G52 MC2",
    };
    _aidl_return->push_back(std::move(gpu));
    return ndk::ScopedAStatus::ok();
}

}  // namespace memtrack
}  // namespace hardware
}  // namespace android
}  // namespace aidl
