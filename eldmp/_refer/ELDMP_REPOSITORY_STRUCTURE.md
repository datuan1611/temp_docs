# ELDMP Git Repository Structure
## Cấu Trúc Repository Toàn Diện Cho Embedded Linux Device Management Platform

---

## Sơ Đồ Tổng Quan

```
eldmp/                                    ← Repo umbrella (monorepo)
├── .git/                                 ← Git history
├── .gitignore                            ← Ignore build artifacts, IDE files
├── .github/
│   └── workflows/
│       └── ci-build.yml                  ← GitHub Actions CI pipeline
│
├── LICENSE                               ← MIT / Apache 2.0 (mã nguồn mở)
├── README.md                             ← Pitch + Quick Start
├── CMakeLists.txt                        ← Build system root
│
├── docs/                                 ← Tài liệu dự án
│   ├── architecture/
│   │   ├── ARCHITECTURE.md               ← Tổng quan kiến trúc hệ thống
│   │   └── decisions/
│   │       ├── ADR-0001-soc-mcu-split.md      ← Bộ xử lý riêng Linux + MCU
│   │       ├── ADR-0002-buildroot-yocto.md   ← Dùng cả Buildroot + Yocto
│   │       ├── ADR-0003-dbus-ipc.md          ← D-Bus cho IPC
│   │       └── ADR-0004-custom-protocol.md   ← Custom protocol Linux↔MCU
│   │
│   ├── release-notes/
│   │   ├── v0.5.md                       ← FreeRTOS + LVGL milestone
│   │   ├── v1.0.md                       ← Kernel driver + systemd
│   │   ├── v1.5.md                       ← Buildroot/Yocto image
│   │   └── ... (v2.0, v2.5, v3.0, v3.5)
│   │
│   ├── learning/
│   │   ├── EMBEDDED_C_MASTERY_GUIDE.md   ← ⭐ Foundation C knowledge
│   │   ├── SETUP_GUIDE.md                ← Hướng dẫn thiết lập môi trường
│   │   ├── ARM_CORTEX_M_GUIDE.md         ← ARM Cortex-M kiến trúc
│   │   ├── LINUX_KERNEL_INTRO.md         ← Kernel fundamentals
│   │   ├── FREERTOS_BASICS.md            ← FreeRTOS cơ bản
│   │   ├── LVGL_GUIDE.md                 ← GUI nhúng
│   │   └── SYSTEMD_GUIDE.md              ← systemd & services
│   │
│   └── protocols/
│       └── ELDMP_PROTOCOL_SPEC.md        ← Linux↔MCU protocol definition
│
├── notes/                                ← Ghi chú học tập theo sprint
│   ├── sprint-0.md                       ← Environment setup learnings
│   ├── sprint-1.md                       ← Logger module
│   ├── sprint-2.md                       ← Config manager
│   ├── sprint-3.md                       ← Bare-metal MCU
│   ├── sprint-4.md                       ← FreeRTOS
│   ├── sprint-5.md                       ← LVGL
│   ├── sprint-6.md                       ← Linux Kernel & Driver
│   ├── ... (sprint-7 to sprint-16)
│   └── SPRINT_TEMPLATE.md                ← Template: Vấn đề–Kỳ vọng–Thực tế–Bài học
│
├── src/                                  ← Source code (tiến dần theo sprint)
│   ├── CMakeLists.txt
│   │
│   ├── logger/                           ← Sprint 1
│   │   ├── CMakeLists.txt
│   │   ├── include/logger.h
│   │   ├── logger.cpp
│   │   └── logger_config.json
│   │
│   ├── config/                           ← Sprint 2
│   │   ├── CMakeLists.txt
│   │   ├── include/config_manager.h
│   │   ├── config_manager.cpp
│   │   └── config.json (template)
│   │
│   ├── device/                           ← Sprint 7 (placeholder)
│   │   ├── CMakeLists.txt
│   │   └── device_info.h
│   │
│   ├── monitor/                          ← Sprint 8
│   │   ├── CMakeLists.txt
│   │   └── health_monitor.h
│   │
│   ├── ipc/                              ← Sprint 9
│   │   ├── CMakeLists.txt
│   │   └── dbus_interface.h
│   │
│   ├── driver/                           ← Sprint 6 (kernel module)
│   │   ├── CMakeLists.txt
│   │   └── gpio_driver.c
│   │
│   ├── mcu/                              ← Sprint 3-5 (firmware)
│   │   ├── CMakeLists.txt
│   │   ├── bare-metal/
│   │   │   ├── startup.c
│   │   │   └── main.c
│   │   ├── freertos/
│   │   │   └── tasks/
│   │   └── lvgl/
│   │       └── gui/
│   │
│   ├── watchdog/                         ← Sprint 11
│   │   ├── CMakeLists.txt
│   │   └── watchdog.h
│   │
│   ├── network/                          ← Sprint 14 (placeholder)
│   │   ├── CMakeLists.txt
│   │   └── network_manager.h
│   │
│   ├── ota/                              ← Sprint 15 (placeholder)
│   │   ├── CMakeLists.txt
│   │   └── ota_manager.h
│   │
│   ├── security/                         ← Sprint 16 (placeholder)
│   │   ├── CMakeLists.txt
│   │   └── tls_manager.h
│   │
│   ├── common/                           ← Shared utilities
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   ├── types.h
│   │   │   ├── error_codes.h
│   │   │   └── macros.h
│   │   └── logging.h
│   │
│   └── app/                              ← Main application / CLI
│       ├── CMakeLists.txt
│       ├── cli.cpp
│       └── main.cpp
│
├── tests/                                ← Unit & Integration tests
│   ├── CMakeLists.txt
│   ├── catch2_setup.cmake
│   │
│   ├── unit/
│   │   ├── test_logger.cpp               ← Sprint 1
│   │   ├── test_config.cpp               ← Sprint 2
│   │   └── ...
│   │
│   ├── integration/
│   │   ├── test_ipc.cpp                  ← Sprint 9
│   │   └── ...
│   │
│   └── fixtures/
│       └── sample_config.json
│
├── scripts/                              ← Build & deployment scripts
│   ├── build.sh                          ← Compile Linux side
│   ├── build-mcu.sh                      ← Compile MCU firmware
│   ├── format-code.sh                    ← Code formatting (clang-format)
│   ├── static-check.sh                   ← Static analysis (cppcheck)
│   ├── create-image.sh                   ← Build Buildroot/Yocto image
│   └── flash-mcu.sh                      ← Upload firmware to MCU
│
├── yocto/                                ← Yocto layer (Sprint 12)
│   ├── meta-eldmp/
│   │   ├── conf/
│   │   │   ├── layer.conf
│   │   │   └── machine/
│   │   ├── recipes-core/
│   │   ├── recipes-app/
│   │   │   └── eldmp_3.5.bb
│   │   └── README.md
│   └── local.conf (template)
│
├── buildroot/                            ← Buildroot config (Sprint 12)
│   ├── config                            ← menuconfig output
│   ├── rootfs_overlay/                   ← Custom files cho rootfs
│   └── README.md
│
├── device-tree/                          ← Device Tree source (Sprint 6)
│   ├── am335x-boneblack.dts              ← BeagleBone Black DT (reference)
│   └── overlays/
│       ├── eldmp-gpio.dts
│       └── eldmp-uart.dts
│
├── .clang-format                         ← Code style config
├── .gitignore                            ← Git ignore rules
├── CMakeLists.txt                        ← Root CMake
├── conanfile.txt                         ← (Optional) C++ dependency manager
└── SPRINT_ROADMAP.md                     ← Link tới chi tiết roadmap

```

---

## Chi Tiết Từng Thư Mục & Mục Đích

### 🔧 Root Level Files

#### `.gitignore`
```
# Build artifacts
build/
cmake-build-*/
*.o
*.a
*.so
*.out

# IDE
.vscode/
.idea/
*.swp
*~

# Generated
*.log
.DS_Store

# Test
coverage/
*.gcda
*.gcno

# Dependencies
third_party/downloaded/
```

#### `LICENSE`
```
MIT License hoặc Apache 2.0
- Cho phép người khác dùng, modify, redistribute
- Tín hiệu portfolio: "code for others to use"
```

#### `README.md`
```markdown
# ELDMP — Embedded Linux Device Management Platform

**Status:** [![CI Build](badge-url)](github-actions)

## Mô Tả Ngắn
Platform IoT/công nghiệp embedded hoàn chỉnh, từ MCU firmware → Linux kernel → cloud sync.
**Bức tranh tổng thể:** STM32 Nucleo (RTOS+GUI) ↔ BeagleBone Black (Linux) ↔ Cloud

## Năng Lực Thể Hiện
- ✓ Firmware MCU: bare-metal → FreeRTOS → LVGL GUI
- ✓ Linux Kernel: custom driver + Device Tree
- ✓ systemd services: multiprocess IPC (D-Bus)
- ✓ Image build: Buildroot + Yocto
- ✓ Protocol: custom Linux↔MCU protocol với CRC/retry
- ✓ OTA: signed update với rollback
- ✓ Security: TLS, signed packages

## Quick Start
```bash
# Clone & setup
git clone https://github.com/you/eldmp.git
cd eldmp
./scripts/build.sh

# Run tests
ctest

# View docs
open docs/learning/SETUP_GUIDE.md
```

## Hạn Chế / Phạm Vi
- Hướng tập trung: RTOS + Linux nhúng, không real-time Linux (ưu tiên V4.0)
- Platform: BeagleBone Black + STM32H743
- Mục tiêu: Education + Portfolio, không production-grade (nhưng architecture solid)

## Roadmap
- V0.5 (tháng 4): FreeRTOS + LVGL
- V1.0 (tháng 9): Linux kernel + systemd
- V1.5 (tháng 11): Buildroot/Yocto image
- V2.0 (tháng 13): Protocol & integration
- V3.5 (tháng 17): OTA + Security

[Xem chi tiết roadmap](SPRINT_ROADMAP.md)

## Tài Liệu Chính
- **[Architecture Decision Records](docs/architecture/decisions/)** — 4 ADR quan trọng
- **[Learning Guide](docs/learning/)** — Từ C basics → Embedded Linux
- **[Protocol Spec](docs/protocols/ELDMP_PROTOCOL_SPEC.md)** — Linux↔MCU wire format
- **[Roadmap](SPRINT_ROADMAP.md)** — Chi tiết sprint + learning resource

## License
MIT — Mở cho mọi người
```

#### `.github/workflows/ci-build.yml`
```yaml
name: CI Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install dependencies
        run: sudo apt-get install -y cmake build-essential
      - name: Configure
        run: mkdir build && cd build && cmake ..
      - name: Build
        run: cd build && make
      - name: Test
        run: cd build && ctest --output-on-failure
      - name: Warnings check
        run: cd build && make 2>&1 | grep -i warning || true
```

---

### 📚 `docs/` — Tài Liệu Dự Án

#### `docs/learning/EMBEDDED_C_MASTERY_GUIDE.md` ⭐
**Mục đích:** Foundation C knowledge trước khi bắt đầu ELDMP
- 6 chương: Memory → Pointers → Bitwise → Data structures → Defensive C
- 43 section với code example
- **Bắt đầu đọc ở:** Sprint 0, trước khi viết một dòng code
- **Tham khảo lại:** Mỗi sprint có phần "C skills needed"

#### `docs/learning/SETUP_GUIDE.md`
```markdown
# Environment Setup Guide (Sprint 0)

## Yêu cầu hệ thống
- Ubuntu 20.04+ / Debian 11+
- 4GB RAM, 2GB disk space
- Internet connection

## Installation Steps

### 1. Toolchain cơ bản
\`\`\`bash
sudo apt-get update
sudo apt-get install -y \
  build-essential cmake git \
  gcc g++ gdb make \
  arm-none-eabi-gcc arm-none-eabi-gdb \
  valgrind cppcheck clang-format
\`\`\`

### 2. Optional: IDE Setup
- VS Code extensions: C++, CMake, ARM Assembly
- CLion (commercial)

### 3. Verify
\`\`\`bash
cmake --version
arm-none-eabi-gcc --version
\`\`\`
```

#### `docs/learning/ARM_CORTEX_M_GUIDE.md`
- NVIC, exception model, SysTick
- STM32 specific (register map)
- Dùng cho Sprint 3

#### `docs/learning/FREERTOS_BASICS.md`
- Task, queue, semaphore, mutex
- Dùng cho Sprint 4

#### `docs/learning/LVGL_GUIDE.md`
- Widget, event loop, driver integration
- Dùng cho Sprint 5

#### `docs/architecture/ARCHITECTURE.md`
```markdown
# System Architecture

## High-Level Diagram
\`\`\`
Application Layer
  ↓
D-Bus IPC
  ↓
systemd services (Device, Monitor, etc.)
  ↓
Linux kernel + custom driver
  ↓
Hardware (GPIO, UART, SPI, CAN)
  ↓
STM32 MCU (FreeRTOS + GUI)
\`\`\`

## Layering Strategy
- **User space:** Modern C++17, systemd units
- **Kernel space:** Custom driver, Device Tree
- **Firmware:** C, FreeRTOS, LVGL

## Data Flow
1. MCU: sensor → ISR → FreeRTOS queue → LCD display
2. Linux: D-Bus poll → process → MQTT publish
3. Protocol: custom UART/SPI/CAN message format with CRC
```

#### `docs/architecture/decisions/ADR-0001-soc-mcu-split.md`
```markdown
# ADR-0001: Separate SoC (Linux) and MCU (RTOS)

**Status:** Accepted

**Context:**
Could use single ARM SoC (A53, A72) for everything.
But loose real-time guarantee for time-critical tasks.

**Decision:**
Use two processors:
- BeagleBone Black (A8) for Linux services, networking
- STM32H743 (M7) for deterministic control, GUI

**Consequences:**
- ✓ Deterministic timing for control loop (MCU)
- ✓ Rich OS features for services (Linux)
- ✗ More complex integration (protocol, synchronization)
- ✗ More hardware to manage

**Alternatives Considered:**
- Single SoC (simpler, but lose real-time guarantees)
- Real-Time Linux (overhead, complexity not justified for learning)
```

---

### 📝 `notes/` — Ghi Chú Học Tập

#### `notes/SPRINT_TEMPLATE.md`
```markdown
# Sprint N — [Tên Sprint]

## Vấn Đề (Problem)
Cái gì cần được giải quyết ở sprint này?

## Kỳ Vọng (Expected Outcome)
Sau sprint này, bạn sẽ biết/làm được gì?

## Thực Tế (What Actually Happened)
Vấn đề nào phát sinh? Mất thời gian ở đâu?

## Root Cause / Cách Sửa
Tại sao vấn đề xảy ra? Giải pháp?

## Bài Học (Lessons Learned)
Những gì học được để áp dụng sprint tiếp theo?

## Tài Liệu Tham Khảo Sử Dụng
- Chương X của sách Y
- Source code Z (repo, line number)
- StackOverflow post, datasheet, etc.

## Commit Hash
Các commit chính của sprint này

## Thời Lượng Thực Tế
- Planned: X giờ
- Actual: Y giờ
- Chênh lệch: vì sao?
```

#### `notes/sprint-0.md` (ví dụ)
```markdown
# Sprint 0 — Environment Setup & Repository Structure

## Vấn Đề
Cần tạo một git repository structure rõ ràng, scalable, phù hợp
cho một dự án embedded kéo dài 16 sprint.

## Kỳ Vọng
- Git repo hoạt động, CI pipeline hoạt động
- CMake build system chạy được
- Folder structure clear, không confusing
- Có README, LICENSE, first commit

## Thực Tế
- Setup git + CMake + GitHub Actions: 1.5 giờ
- Tổ chức folder structure: 2 giờ (cân nhắc nhiều design decision)
- Viết README + documentation skeleton: 1.5 giờ
- Tổng: 5 giờ (expected 4 giờ)

## Root Cause
- Quyết định về folder layout phải consistent với roadmap
  (nên phát triển sprint-wise, không tất cả folder cùng lúc)
- GitHub Actions YAML syntax debugging: 30 phút

## Bài Học
1. Folder structure nên flexible: mỗi sprint thêm thư mục khi cần
   (không tạo tất cả từ đầu)
2. CMake modular từ đầu: mỗi module có CMakeLists.txt riêng
3. Documentation = priority, không optional (README là marketing)

## Commit Hash
- abc1234: Initial repo structure
- def5678: Add CMake build system
- ghi9012: Add CI workflow
```

---

### 🧪 `tests/` — Kiểm Thử

#### `tests/CMakeLists.txt`
```cmake
# Tests root CMakeLists.txt

include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.0.0
)
FetchContent_MakeAvailable(Catch2)

# Add unit tests
add_subdirectory(unit)

# Add integration tests
add_subdirectory(integration)

enable_testing()
```

#### `tests/unit/test_logger.cpp`
```cpp
#include <catch2/catch.hpp>
#include "logger.h"
#include <fstream>
#include <filesystem>

TEST_CASE("Logger writes to file", "[logger]") {
    Logger logger("/tmp/test.log", LogLevel::DEBUG);
    
    logger.log(LogLevel::INFO, "Test message");
    
    // Verify file contains message
    std::ifstream file("/tmp/test.log");
    std::string line;
    std::getline(file, line);
    REQUIRE(line.find("Test message") != std::string::npos);
}

TEST_CASE("Logger rotation works", "[logger][rotation]") {
    // Create small buffer to test rotation
    Logger logger("/tmp/test_rotate.log", LogLevel::DEBUG, 256);  // 256 bytes
    
    // Write many messages to trigger rotation
    for (int i = 0; i < 100; i++) {
        logger.log(LogLevel::INFO, "Message " + std::to_string(i));
    }
    
    // Verify rotated files exist
    REQUIRE(std::filesystem::exists("/tmp/test_rotate.log.1"));
}
```

---

### 🛠️ `scripts/` — Build & Deployment

#### `scripts/build.sh`
```bash
#!/bin/bash
set -e  # Exit on error

echo "🔨 Building ELDMP (Linux side)"

# Check dependencies
for cmd in cmake gcc g++ arm-none-eabi-gcc; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Missing: $cmd"
        exit 1
    fi
done

# Clean build directory
[ -d build ] && rm -rf build
mkdir build && cd build

# Configure with release
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_TESTS=ON ..

# Build
make -j$(nproc)

# Run tests
ctest --output-on-failure

echo "✅ Build successful!"
echo "📦 Output: build/src/app/eldmp"
```

#### `scripts/build-mcu.sh`
```bash
#!/bin/bash
set -e

echo "🔨 Building MCU firmware (STM32H743)"

# STM32CubeIDE project build or direct GCC
cd src/mcu

# Build bare-metal
echo "Building bare-metal..."
arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb \
    -DSTM32H743xx \
    -I./include \
    -c bare-metal/main.c -o /tmp/main.o
    
# Link
arm-none-eabi-gcc -Wl,--script=linker.ld /tmp/main.o -o eldmp.elf

# Generate binary
arm-none-eabi-objcopy -O binary eldmp.elf eldmp.bin

echo "✅ MCU build successful!"
echo "📦 Output: src/mcu/eldmp.bin"
```

#### `scripts/flash-mcu.sh`
```bash
#!/bin/bash

# Flash using ST-Link or OpenOCD
FIRMWARE="src/mcu/eldmp.bin"

if [ ! -f "$FIRMWARE" ]; then
    echo "❌ Firmware not found: $FIRMWARE"
    echo "Run: ./scripts/build-mcu.sh first"
    exit 1
fi

echo "📤 Flashing MCU with $FIRMWARE"

# Using openocd
openocd -f interface/stlink.cfg -f target/stm32h7x.cfg \
    -c "program $FIRMWARE 0x08000000 verify reset exit"

echo "✅ Flash successful!"
```

---

### 🔨 `CMakeLists.txt` — Root Build Configuration

```cmake
cmake_minimum_required(VERSION 3.16)
project(eldmp VERSION 3.5.0 LANGUAGES C CXX)

# C++ Standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler Flags
add_compile_options(-Wall -Wextra -Wpedantic)
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    add_compile_options(-O2)
else()
    add_compile_options(-O0 -g)
endif()

# Subdirectories
add_subdirectory(src)
add_subdirectory(tests)

# Documentation target (optional)
find_package(Doxygen)
if(DOXYGEN_FOUND)
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in
        ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY
    )
    add_custom_target(docs
        ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
    )
endif()

# Print summary
message(STATUS "ELDMP Version: ${PROJECT_VERSION}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
```

---

### 📦 `src/` — Source Code Organization

#### `src/CMakeLists.txt`
```cmake
# Main source CMakeLists.txt

# Common library
add_library(eldmp-common OBJECT
    common/logging.h
    common/types.h
    common/error_codes.h
)
target_include_directories(eldmp-common PUBLIC common/include)

# Logger module
add_library(eldmp-logger
    logger/logger.cpp
)
target_include_directories(eldmp-logger PUBLIC logger/include)
target_link_libraries(eldmp-logger PRIVATE eldmp-common)

# Config module
add_library(eldmp-config
    config/config_manager.cpp
)
target_include_directories(eldmp-config PUBLIC config/include)
target_link_libraries(eldmp-config PRIVATE eldmp-common)

# Main executable (later sprints)
add_executable(eldmp
    app/main.cpp
    app/cli.cpp
)
target_link_libraries(eldmp
    PRIVATE
    eldmp-logger
    eldmp-config
)
```

#### `src/common/types.h`
```c
#ifndef ELDMP_TYPES_H
#define ELDMP_TYPES_H

#include <stdint.h>
#include <stdbool.h>

/* Return codes */
typedef int32_t ErrorCode;

#define ELDMP_OK        0
#define ELDMP_ERR_NOMEM -1
#define ELDMP_ERR_PARAM -2
#define ELDMP_ERR_IO    -3

/* Common data types */
typedef struct {
    uint32_t timestamp_ms;
    uint16_t sensor_id;
    float    value;
} SensorReading;

#endif /* ELDMP_TYPES_H */
```

#### `src/logger/include/logger.h`
```cpp
#ifndef ELDMP_LOGGER_H
#define ELDMP_LOGGER_H

#include <string>
#include <memory>

enum class LogLevel {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
};

class Logger {
public:
    Logger(const std::string& filename, LogLevel level = LogLevel::INFO);
    ~Logger();
    
    void log(LogLevel level, const std::string& message);
    void set_level(LogLevel level);
    
private:
    std::string filename_;
    LogLevel current_level_;
    uint32_t file_size_;
};

#endif /* ELDMP_LOGGER_H */
```

---

### 🌳 `yocto/` — Yocto Build Layer (Sprint 12)

#### `yocto/meta-eldmp/conf/layer.conf`
```
BBPATH .= ":${LAYERDIR}"

BBFILES += "${LAYERDIR}/recipes-*/*/*.bb"

BBFILE_COLLECTIONS += "eldmp"
BBFILE_PATTERN_eldmp = "^${LAYERDIR}/"
BBFILE_PRIORITY_eldmp = "7"

LAYERDEPENDS_eldmp = "core"
LAYER_CONF_VERSION = "2"
```

#### `yocto/meta-eldmp/recipes-app/eldmp_3.5.bb`
```bitbake
SUMMARY = "ELDMP - Embedded Linux Device Management Platform"
HOMEPAGE = "https://github.com/you/eldmp"
LICENSE = "MIT"

SRC_URI = "git://github.com/you/eldmp.git;branch=main"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

DEPENDS = "cmake-native"

do_compile() {
    cd ${S}
    mkdir -p build
    cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/build/src/app/eldmp ${D}${bindir}/
}
```

---

### 🎛️ `device-tree/` — Device Tree Overlays (Sprint 6)

#### `device-tree/overlays/eldmp-gpio.dts`
```dts
/dts-v1/;
/plugin/;

/ {
    fragment@0 {
        target = <&am33xx_pinmux>;
        __overlay__ {
            eldmp_gpio_pins: eldmp_gpio_pins {
                pinctrl-single,pins = <
                    0x15c 0x27  /* GPIO1_27 (LED1) */
                    0x158 0x27  /* GPIO1_26 (LED2) */
                    0x154 0x27  /* GPIO1_25 (Button) */
                >;
            };
        };
    };

    fragment@1 {
        target-path = "/";
        __overlay__ {
            eldmp_gpio {
                compatible = "eldmp,gpio-device";
                pinctrl-names = "default";
                pinctrl-0 = <&eldmp_gpio_pins>;
                status = "okay";
            };
        };
    };
};
```

---

## 🎯 Sprint 0 Checklist: Thiết Lập Repository

**Definition of Done:**

- [ ] Git repo initialized, README.md written
- [ ] CMake build system works (cmake .., make)
- [ ] CI pipeline (GitHub Actions) runs successfully
- [ ] First few folders created (logger, config skeleton)
- [ ] All documentation templates in place
- [ ] LICENSE + `.gitignore` committed
- [ ] First tag: `v0.0.1` (skeleton commit)
- [ ] Each developer can clone → build → test ✓

**Commit message pattern:**
```
sprint-0: Initial repository structure

- Add CMake build system
- Add CI workflow (GitHub Actions)
- Add documentation skeleton
- Add learning guides for foundation C knowledge
- Add folder structure for future sprints
```

---

## 🚀 Từ Đây Về Sau: Cách Phát Triển Incrementally

**Mỗi sprint:**

1. Tạo thư mục module mới trong `src/` (khi cần)
2. Thêm CMakeLists.txt cho module
3. Implement code
4. Thêm unit tests trong `tests/unit/`
5. Viết ghi chú học tập trong `notes/sprint-N.md`
6. Commit, tag version (v0.5, v1.0, ...)
7. Update `docs/release-notes/vX.Y.md`

**Folder không bao giờ bị xoá:** tất cả module được giữ nguyên, build cùng nhau
(không bao giờ "đạt tới" V0.5 rồi xoá folder MCU)

---

## 📚 Liên Kết Trong Documentation

Tất cả file `.md` nên có hyperlinks tới nhau:

```markdown
## Learning Path
1. [EMBEDDED_C_MASTERY_GUIDE](../learning/EMBEDDED_C_MASTERY_GUIDE.md) ← Start here
2. [SETUP_GUIDE](../learning/SETUP_GUIDE.md) ← Environment
3. [ARM_CORTEX_M_GUIDE](../learning/ARM_CORTEX_M_GUIDE.md) ← Before Sprint 3
4. [FREERTOS_BASICS](../learning/FREERTOS_BASICS.md) ← Before Sprint 4
5. [Roadmap](../../SPRINT_ROADMAP.md) ← Overall plan
```

---

**END: Repository Structure Guide**
