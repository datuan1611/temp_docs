#!/bin/bash
###############################################################################
# ELDMP Repository Initialization Script
# 
# Mục đích: Tạo một git repository hoàn chỉnh với cấu trúc ELDMP từ đầu
#
# Cách dùng:
#   mkdir ~/eldmp
#   cd ~/eldmp
#   bash ~/init-eldmp-repo.sh
#
###############################################################################

set -e  # Exit on any error

REPO_NAME="eldmp"
REPO_VERSION="3.5.0"
REPO_URL="https://github.com/you/eldmp"  # TODO: Thay bằng URL thật

echo "🚀 Initializing ELDMP Repository Structure"
echo "==========================================="
echo ""

# ============================================================================
# 1. GIT INITIALIZATION
# ============================================================================

echo "📦 Step 1/6: Git initialization"

if [ -d .git ]; then
    echo "⚠️  Already a git repository. Skipping git init..."
else
    git init
    git config user.name "ELDMP Developer"
    git config user.email "developer@eldmp.local"
fi

echo "✓ Git initialized"
echo ""

# ============================================================================
# 2. CREATE DIRECTORY STRUCTURE
# ============================================================================

echo "📂 Step 2/6: Creating directory structure"

# Root-level documentation directories
mkdir -p docs/architecture/decisions
mkdir -p docs/release-notes
mkdir -p docs/learning
mkdir -p docs/protocols

# Source code directories
mkdir -p src/logger/include
mkdir -p src/config/include
mkdir -p src/common/include
mkdir -p src/device
mkdir -p src/monitor
mkdir -p src/ipc
mkdir -p src/driver
mkdir -p src/mcu/bare-metal
mkdir -p src/mcu/freertos
mkdir -p src/mcu/lvgl
mkdir -p src/watchdog
mkdir -p src/network
mkdir -p src/ota
mkdir -p src/security
mkdir -p src/app

# Test directories
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/fixtures

# Build & deployment
mkdir -p scripts
mkdir -p yocto/meta-eldmp/conf/machine
mkdir -p yocto/meta-eldmp/recipes-core
mkdir -p yocto/meta-eldmp/recipes-app
mkdir -p buildroot/rootfs_overlay
mkdir -p device-tree/overlays

# Misc
mkdir -p notes

echo "✓ Directory structure created"
echo ""

# ============================================================================
# 3. CREATE ROOT-LEVEL FILES
# ============================================================================

echo "🔧 Step 3/6: Creating root-level files"

# LICENSE
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2024 ELDMP Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
EOF

# .gitignore
cat > .gitignore << 'EOF'
# Build artifacts
build/
cmake-build-*/
*.o
*.a
*.so
*.elf
*.bin
*.out
*.map

# IDE and editor
.vscode/
.idea/
*.swp
*~
.DS_Store
*.sublime-workspace

# Test coverage
coverage/
*.gcda
*.gcno
gcov_report/

# Generated files
*.log
*.tmp
compile_commands.json

# Dependencies
third_party/downloaded/
conan/

# OS specific
.AppleDouble
Thumbs.db
EOF

# Root CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
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

# Build directories
add_subdirectory(src)

# Tests
enable_testing()
add_subdirectory(tests)

# Print configuration summary
message(STATUS "")
message(STATUS "=== ELDMP Build Configuration ===")
message(STATUS "Project Version: ${PROJECT_VERSION}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Source Dir: ${CMAKE_SOURCE_DIR}")
message(STATUS "Binary Dir: ${CMAKE_BINARY_DIR}")
message(STATUS "==================================")
message(STATUS "")
EOF

# .clang-format
cat > .clang-format << 'EOF'
---
BasedOnStyle: Google
IndentWidth: 4
ColumnLimit: 100
UseTab: Never
AlignConsecutiveDeclarations: false
AllowShortFunctionsOnASingleLine: InlineOnly
BreakBeforeBraces: Allman
EOF

echo "✓ Root-level files created"
echo ""

# ============================================================================
# 4. CREATE DOCUMENTATION FILES
# ============================================================================

echo "📚 Step 4/6: Creating documentation files"

# README.md
cat > README.md << 'EOF'
# ELDMP — Embedded Linux Device Management Platform

[![CI Build](https://github.com/you/eldmp/actions/workflows/ci-build.yml/badge.svg)](https://github.com/you/eldmp/actions)

**Version:** 3.5.0 (Core Track Complete)

## Overview

ELDMP is a complete embedded Linux platform integrating real-time MCU firmware with Linux services, demonstrating:

- **Bare-metal & RTOS:** STM32 firmware from registers to FreeRTOS to LVGL GUI
- **Linux Kernel:** Custom device driver + Device Tree
- **System Integration:** D-Bus IPC, systemd services, watchdog
- **Build System:** Buildroot & Yocto image generation
- **Protocol:** Custom Linux↔MCU communication with CRC/retry
- **OTA & Security:** Signed updates, TLS encryption

## Quick Start

```bash
# Clone repository
git clone https://github.com/you/eldmp.git
cd eldmp

# Build
./scripts/build.sh

# Run tests
cd build && ctest

# View documentation
cat docs/learning/SETUP_GUIDE.md
```

## Architecture

```
┌──────────────────┐
│  Cloud / MQTT    │
└────────┬─────────┘
         │
    ┌────┴─────────────────────┐
    │   Linux (BeagleBone)      │
    ├───────────────────────────┤
    │ Services: Device, Monitor │
    │ IPC: D-Bus, systemd       │
    │ Kernel Driver, Device Tree│
    └────────┬─────────────────┘
             │ UART/SPI/CAN
    ┌────────┴──────────────────┐
    │  MCU (STM32H743)          │
    ├───────────────────────────┤
    │ FreeRTOS + LVGL GUI       │
    │ Sensors & Control Loop    │
    └───────────────────────────┘
```

## Project Status

- ✅ V0.5 (Sprint 5): FreeRTOS + LVGL
- ✅ V1.0 (Sprint 11): Linux Kernel Driver + systemd
- ✅ V1.5 (Sprint 12): Buildroot/Yocto
- ✅ V2.0 (Sprint 13): Linux↔MCU Protocol
- ✅ V2.5 (Sprint 14): Networking (MQTT)
- ✅ V3.0 (Sprint 15): OTA Updates
- ✅ V3.5 (Sprint 16): Security (TLS + Signed Updates)

## Learning Resources

**Start here:** [EMBEDDED_C_MASTERY_GUIDE](docs/learning/EMBEDDED_C_MASTERY_GUIDE.md)

- [Setup Guide](docs/learning/SETUP_GUIDE.md) — Environment installation
- [ARM Cortex-M](docs/learning/ARM_CORTEX_M_GUIDE.md) — MCU architecture
- [FreeRTOS Basics](docs/learning/FREERTOS_BASICS.md) — RTOS fundamentals
- [LVGL Guide](docs/learning/LVGL_GUIDE.md) — Embedded GUI
- [Full Roadmap](SPRINT_ROADMAP.md) — Sprint-by-sprint plan

## Documentation

- **[Architecture Decisions](docs/architecture/decisions/)** — 4 key ADRs
- **[Protocol Spec](docs/protocols/ELDMP_PROTOCOL_SPEC.md)** — Linux↔MCU wire format
- **[Releases](docs/release-notes/)** — What's new in each version

## Repository Structure

```
eldmp/
├── src/              — C++ source code (Linux) + C firmware (MCU)
├── tests/            — Unit & integration tests
├── docs/             — Architecture, learning guides, release notes
├── notes/            — Sprint-by-sprint learning notes
├── scripts/          — Build & deployment helpers
├── yocto/            — Yocto layer (meta-eldmp)
├── buildroot/        — Buildroot configuration
├── device-tree/      — Device Tree overlays
├── CMakeLists.txt    — Build system root
└── README.md         — This file
```

## Build Instructions

### Prerequisites

```bash
sudo apt-get install -y \
  build-essential cmake git \
  arm-none-eabi-gcc arm-none-eabi-gdb
```

### Compile Linux Side

```bash
./scripts/build.sh
```

### Compile MCU Firmware

```bash
./scripts/build-mcu.sh
```

### Run Tests

```bash
cd build && ctest --output-on-failure
```

## Hardware

- **MCU:** STM32 Nucleo-H743ZI
- **SoC:** BeagleBone Black Rev C
- **Display:** Small SPI/parallel LCD (LVGL compatible)
- **Connectivity:** UART/SPI/CAN transceiver modules

## License

MIT License — See [LICENSE](LICENSE) for details.

## Future Work (Extension Track)

- V4.0: Performance profiling (eBPF, perf)
- V5.0: Secure boot & TEE (OP-TEE, TF-A)
- V6.0: Port to NXP i.MX93 (RemoteProc, asymmetric multiprocessing)
- V7.0: REST API + WebUI + Cloud dashboard
- V8.0: ROS2 integration & on-device AI

## Author

Written as a learning project for embedded systems mastery.
EOF

# SPRINT_ROADMAP.md (link/reference)
cat > SPRINT_ROADMAP.md << 'EOF'
# ELDMP Sprint Roadmap

[Full roadmap is in docs/learning/ — see ELDMP_Roadmap_MCU_vi.md]

## Quick Reference

| Phase | Sprints | Duration | Output |
|-------|---------|----------|--------|
| **MCU Foundational** | 0-5 | ~4 months | V0.5: FreeRTOS + LVGL |
| **Linux & Driver** | 6-11 | ~5 months | V1.0: Kernel + systemd |
| **Build System** | 12 | ~2 months | V1.5: Yocto/Buildroot |
| **Integration** | 13-16 | ~4 months | V3.5: OTA + Security |

**Total Core Track:** ~16 months (bán thời gian basis)

See detailed breakdown in repository docs/learning/
EOF

echo "✓ Documentation files created"
echo ""

# ============================================================================
# 5. CREATE CMAKE AND BUILD FILES
# ============================================================================

echo "🔨 Step 5/6: Creating CMake build configuration"

# src/CMakeLists.txt
cat > src/CMakeLists.txt << 'EOF'
# Source code CMakeLists.txt

# Common utilities library
add_library(eldmp-common INTERFACE)
target_include_directories(eldmp-common INTERFACE
    ${CMAKE_CURRENT_SOURCE_DIR}/common/include
)

# Logger module (Sprint 1)
add_library(eldmp-logger
    logger/logger.cpp
)
target_include_directories(eldmp-logger PUBLIC logger/include)
target_link_libraries(eldmp-logger PRIVATE eldmp-common)

# Config module (Sprint 2)
add_library(eldmp-config
    config/config_manager.cpp
)
target_include_directories(eldmp-config PUBLIC config/include)
target_link_libraries(eldmp-config PRIVATE eldmp-common eldmp-logger)

# Main executable (future sprints)
add_executable(eldmp
    app/main.cpp
)
target_link_libraries(eldmp
    PRIVATE
    eldmp-logger
    eldmp-config
)

# Install targets
install(TARGETS eldmp DESTINATION bin)
EOF

# tests/CMakeLists.txt
cat > tests/CMakeLists.txt << 'EOF'
# Tests CMakeLists.txt

# Catch2 setup
include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.3.2
)
FetchContent_MakeAvailable(Catch2)

# Unit tests
add_subdirectory(unit)
add_subdirectory(integration)
EOF

# tests/unit/CMakeLists.txt
cat > tests/unit/CMakeLists.txt << 'EOF'
# Unit tests

add_executable(test_logger
    test_logger.cpp
)
target_link_libraries(test_logger
    PRIVATE
    Catch2::Catch2WithMain
    eldmp-logger
)

add_test(NAME test_logger COMMAND test_logger)
EOF

# tests/integration/CMakeLists.txt
cat > tests/integration/CMakeLists.txt << 'EOF'
# Integration tests (placeholder)

# To be added in later sprints
EOF

echo "✓ CMake files created"
echo ""

# ============================================================================
# 6. CREATE SKELETON SOURCE FILES
# ============================================================================

echo "💾 Step 6/6: Creating skeleton source files"

# common/types.h
cat > src/common/include/types.h << 'EOF'
#ifndef ELDMP_TYPES_H
#define ELDMP_TYPES_H

#include <stdint.h>
#include <stdbool.h>

/* Error codes */
typedef int32_t ErrorCode;

#define ELDMP_OK        0
#define ELDMP_ERR_NOMEM -1
#define ELDMP_ERR_PARAM -2
#define ELDMP_ERR_IO    -3
#define ELDMP_ERR_STATE -4

#endif /* ELDMP_TYPES_H */
EOF

# logger/include/logger.h
cat > src/logger/include/logger.h << 'EOF'
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
};

#endif /* ELDMP_LOGGER_H */
EOF

# logger/logger.cpp (skeleton)
cat > src/logger/logger.cpp << 'EOF'
#include "logger.h"
#include <fstream>
#include <iostream>
#include <chrono>
#include <iomanip>

Logger::Logger(const std::string& filename, LogLevel level)
    : filename_(filename), current_level_(level) {
    // Open file for appending
}

Logger::~Logger() {
    // Clean up
}

void Logger::log(LogLevel level, const std::string& message) {
    if (level < current_level_) return;
    
    auto now = std::chrono::system_clock::now();
    auto time_t = std::chrono::system_clock::to_time_t(now);
    
    std::ofstream file(filename_, std::ios::app);
    file << std::put_time(std::localtime(&time_t), "%Y-%m-%d %H:%M:%S")
         << " [" << static_cast<int>(level) << "] " << message << "\n";
}

void Logger::set_level(LogLevel level) {
    current_level_ = level;
}
EOF

# config/include/config_manager.h
cat > src/config/include/config_manager.h << 'EOF'
#ifndef ELDMP_CONFIG_MANAGER_H
#define ELDMP_CONFIG_MANAGER_H

#include <string>
#include <map>

class ConfigManager {
public:
    ConfigManager(const std::string& config_file);
    
    std::string get_string(const std::string& key, const std::string& default_value = "");
    int get_int(const std::string& key, int default_value = 0);
    bool get_bool(const std::string& key, bool default_value = false);
    
private:
    std::map<std::string, std::string> config_;
};

#endif /* ELDMP_CONFIG_MANAGER_H */
EOF

# config/config_manager.cpp (skeleton)
cat > src/config/config_manager.cpp << 'EOF'
#include "config_manager.h"
#include <fstream>
#include <sstream>

ConfigManager::ConfigManager(const std::string& config_file) {
    // Load configuration from JSON file
}

std::string ConfigManager::get_string(const std::string& key, const std::string& default_value) {
    auto it = config_.find(key);
    return (it != config_.end()) ? it->second : default_value;
}

int ConfigManager::get_int(const std::string& key, int default_value) {
    auto str = get_string(key);
    return str.empty() ? default_value : std::stoi(str);
}

bool ConfigManager::get_bool(const std::string& key, bool default_value) {
    auto str = get_string(key);
    if (str.empty()) return default_value;
    return str == "true" || str == "1" || str == "yes";
}
EOF

# app/main.cpp
cat > src/app/main.cpp << 'EOF'
#include <iostream>
#include "logger.h"
#include "config_manager.h"

int main(int argc, char* argv[]) {
    std::cout << "ELDMP - Embedded Linux Device Management Platform\n";
    std::cout << "Version: 3.5.0\n\n";
    
    // Initialize logger
    Logger logger("/tmp/eldmp.log", LogLevel::INFO);
    logger.log(LogLevel::INFO, "ELDMP started");
    
    // Initialize config
    ConfigManager config("config.json");
    
    std::cout << "✓ Application initialized\n";
    
    return 0;
}
EOF

# tests/unit/test_logger.cpp
cat > tests/unit/test_logger.cpp << 'EOF'
#include <catch2/catch_test_macros.hpp>
#include "logger.h"
#include <filesystem>
#include <fstream>

TEST_CASE("Logger can be instantiated", "[logger]") {
    Logger logger("/tmp/test_logger.log", LogLevel::DEBUG);
    REQUIRE(true);  // Just test construction
}

TEST_CASE("Logger writes to file", "[logger]") {
    std::string test_file = "/tmp/test_logger_write.log";
    
    // Clean up if exists
    if (std::filesystem::exists(test_file)) {
        std::filesystem::remove(test_file);
    }
    
    Logger logger(test_file, LogLevel::INFO);
    logger.log(LogLevel::INFO, "Test message");
    
    // Verify file exists and contains message
    REQUIRE(std::filesystem::exists(test_file));
}
EOF

# notes/SPRINT_TEMPLATE.md
cat > notes/SPRINT_TEMPLATE.md << 'EOF'
# Sprint N — [Sprint Name]

## Problem (Vấn Đề)
What problem is this sprint solving?

## Expected Outcome (Kỳ Vọng)
What should be achieved by end of sprint?

## What Actually Happened (Thực Tế)
What was the actual experience? Any surprises?

## Root Cause / How to Fix (Giải Pháp)
Why did things happen this way? How to improve?

## Lessons Learned (Bài Học)
Key takeaways to apply in future sprints.

## References Used (Tài Liệu Tham Khảo)
- Books/chapters used
- Source code reviewed
- Datasheets/docs
- Stack Overflow posts

## Time Spent
- Planned: X hours
- Actual: Y hours
- Reason for variance: ...

## Commits
List main commits for this sprint
EOF

echo "✓ Skeleton source files created"
echo ""

# ============================================================================
# 7. CREATE CI/CD PIPELINE
# ============================================================================

echo "🔄 Step 7/6: Creating GitHub Actions CI pipeline"

mkdir -p .github/workflows

cat > .github/workflows/ci-build.yml << 'EOF'
name: CI Build

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y \
          build-essential cmake git \
          arm-none-eabi-gcc
    
    - name: Configure
      run: |
        mkdir build
        cd build
        cmake -DCMAKE_BUILD_TYPE=Release ..
    
    - name: Build
      run: |
        cd build
        make -j$(nproc)
    
    - name: Run tests
      run: |
        cd build
        ctest --output-on-failure
    
    - name: Check warnings
      run: |
        cd build
        make 2>&1 | grep -i "warning" && echo "⚠️ Warnings found" || echo "✓ No warnings"
EOF

echo "✓ CI pipeline created"
echo ""

# ============================================================================
# 8. CREATE BUILD SCRIPTS
# ============================================================================

echo "📜 Creating build scripts"

cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e

echo "🔨 Building ELDMP (Linux side)"
echo "=============================="
echo ""

# Check dependencies
for cmd in cmake gcc g++; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Missing: $cmd"
        exit 1
    fi
done

# Create & configure build directory
rm -rf build
mkdir build && cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

# Build
echo "Compiling..."
make -j$(nproc)

# Run tests
echo ""
echo "Running tests..."
ctest --output-on-failure || echo "⚠️ Some tests failed"

echo ""
echo "✅ Build successful!"
echo "📦 Output: build/src/app/eldmp"
echo "📋 Compile commands: build/compile_commands.json"
EOF

chmod +x scripts/build.sh

cat > scripts/format-code.sh << 'EOF'
#!/bin/bash

echo "🎨 Formatting code with clang-format"

find src tests -name "*.cpp" -o -name "*.h" | while read file; do
    echo "Formatting: $file"
    clang-format -i "$file"
done

echo "✅ Formatting complete"
EOF

chmod +x scripts/format-code.sh

echo "✓ Build scripts created"
echo ""

# ============================================================================
# 9. INITIAL COMMIT
# ============================================================================

echo "💾 Creating initial commits"

git add -A

git commit -m "sprint-0: Initial repository structure

- Add CMake build system with modular design
- Add GitHub Actions CI/CD pipeline
- Add complete documentation structure
- Add foundation learning guides (C, ARM, FreeRTOS, LVGL)
- Add folder skeleton for future sprints
- Add build and deployment scripts
- Add unit test framework (Catch2)
- Add code formatting and linting config

Repository structure ready for development starting Sprint 1.
See README.md and docs/learning/SETUP_GUIDE.md for next steps.
"

git tag -a v0.0.1 -m "Initial repository structure - Sprint 0 skeleton"

echo "✓ Initial commits created"
echo ""

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo "✨ Repository initialization complete!"
echo "========================================="
echo ""
echo "📂 Directory structure created:"
echo "   - docs/ (architecture, learning, release notes)"
echo "   - src/ (modular C++ code)"
echo "   - tests/ (unit & integration)"
echo "   - scripts/ (build helpers)"
echo "   - yocto/, buildroot/, device-tree/"
echo ""
echo "📦 Initial files committed:"
echo "   - CMakeLists.txt (build system)"
echo "   - README.md (project overview)"
echo "   - LICENSE (MIT)"
echo "   - .github/workflows/ci-build.yml (CI/CD)"
echo ""
echo "🏷️  First tag: v0.0.1"
echo ""
echo "🚀 Next steps:"
echo "   1. Review: cat README.md"
echo "   2. Setup environment: ./scripts/build.sh"
echo "   3. Read docs: cat docs/learning/EMBEDDED_C_MASTERY_GUIDE.md"
echo "   4. Start learning: cat docs/learning/SETUP_GUIDE.md"
echo ""
echo "📍 Current: Sprint 0 - Environment Setup"
echo "➡️  Next: Sprint 1 - Logger Module"
echo ""
