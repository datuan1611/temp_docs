# ELDMP Repository Visual Guide & Quick Reference

## 🎯 Repository Hierarchy (Full Tree)

```
eldmp/
│
├── 📄 Root Configuration Files
│   ├── README.md                    ← START HERE: Project overview, quick start
│   ├── CMakeLists.txt               ← Build system root configuration
│   ├── LICENSE                      ← MIT license (mã nguồn mở)
│   ├── SPRINT_ROADMAP.md            ← Link to full roadmap
│   ├── .gitignore                   ← Git ignore patterns
│   └── .clang-format                ← Code style configuration
│
├── 🔧 .github/
│   └── workflows/
│       └── ci-build.yml             ← GitHub Actions CI pipeline
│
├── 📚 docs/                         ← Complete documentation
│   ├── architecture/
│   │   ├── ARCHITECTURE.md          ← System design overview
│   │   └── decisions/               ← Architecture Decision Records
│   │       ├── ADR-0001-soc-mcu-split.md
│   │       ├── ADR-0002-buildroot-yocto.md
│   │       ├── ADR-0003-dbus-ipc.md
│   │       └── ADR-0004-custom-protocol.md
│   │
│   ├── learning/                    ← FOUNDATION KNOWLEDGE (必読)
│   │   ├── EMBEDDED_C_MASTERY_GUIDE.md   ⭐ START HERE FIRST
│   │   ├── SETUP_GUIDE.md                ← Environment setup
│   │   ├── ARM_CORTEX_M_GUIDE.md         ← ARM CPU fundamentals
│   │   ├── FREERTOS_BASICS.md            ← Real-time kernel
│   │   ├── LVGL_GUIDE.md                 ← Embedded GUI
│   │   ├── LINUX_KERNEL_INTRO.md         ← Kernel basics
│   │   └── SYSTEMD_GUIDE.md              ← systemd & services
│   │
│   ├── release-notes/               ← What's new in each version
│   │   ├── v0.5.md                  ← FreeRTOS + LVGL
│   │   ├── v1.0.md                  ← Linux kernel + systemd
│   │   ├── v1.5.md                  ← Buildroot/Yocto
│   │   ├── v2.0.md                  ← Protocol & integration
│   │   ├── v2.5.md                  ← Networking (MQTT)
│   │   ├── v3.0.md                  ← OTA updates
│   │   └── v3.5.md                  ← Security (TLS)
│   │
│   └── protocols/
│       └── ELDMP_PROTOCOL_SPEC.md   ← Linux↔MCU wire format
│
├── 📝 notes/                        ← Sprint learning journals
│   ├── SPRINT_TEMPLATE.md           ← Template for each sprint
│   ├── sprint-0.md                  ← Problem–Solution–Lessons
│   ├── sprint-1.md                  ← Logger module insights
│   ├── sprint-2.md                  ← Config manager notes
│   ├── sprint-3.md                  ← Bare-metal MCU learnings
│   ├── sprint-4.md                  ← FreeRTOS insights
│   ├── sprint-5.md                  ← LVGL GUI notes
│   ├── sprint-6.md                  ← Linux kernel driver notes
│   ├── ... (sprint-7 to sprint-16)
│   └── README.md                    ← Guide to reading sprint notes
│
├── 🖥️  src/                          ← Main source code (tiến dần)
│   ├── CMakeLists.txt               ← Source build root
│   │
│   ├── 📦 common/                   ← Shared utilities (mọi sprint)
│   │   ├── include/
│   │   │   ├── types.h              ← Common data types
│   │   │   ├── error_codes.h        ← Error code definitions
│   │   │   └── macros.h             ← Common macros
│   │   └── logging.h
│   │
│   ├── 📦 logger/                   ← Sprint 1: Logging module
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   └── logger.h
│   │   ├── logger.cpp
│   │   └── test_config.json
│   │
│   ├── 📦 config/                   ← Sprint 2: Configuration manager
│   │   ├── CMakeLists.txt
│   │   ├── include/
│   │   │   └── config_manager.h
│   │   ├── config_manager.cpp
│   │   └── config.json (template)
│   │
│   ├── 📦 device/                   ← Sprint 7: Device info service
│   │   ├── CMakeLists.txt
│   │   └── device_info.h
│   │
│   ├── 📦 monitor/                  ← Sprint 8: Health monitoring
│   │   ├── CMakeLists.txt
│   │   └── health_monitor.h
│   │
│   ├── 📦 ipc/                      ← Sprint 9: D-Bus IPC
│   │   ├── CMakeLists.txt
│   │   └── dbus_interface.h
│   │
│   ├── 📦 driver/                   ← Sprint 6: Linux kernel module
│   │   ├── CMakeLists.txt
│   │   ├── gpio_driver.c
│   │   └── device_tree_overlay.dts
│   │
│   ├── 📦 mcu/                      ← Sprint 3-5: MCU firmware
│   │   ├── CMakeLists.txt
│   │   ├── bare-metal/              ← Sprint 3: Register access
│   │   │   ├── startup.c
│   │   │   ├── system_init.c
│   │   │   └── main.c
│   │   ├── freertos/                ← Sprint 4: RTOS tasks
│   │   │   ├── FreeRTOSConfig.h
│   │   │   └── tasks/
│   │   │       ├── sensor_task.c
│   │   │       └── control_task.c
│   │   └── lvgl/                    ← Sprint 5: GUI
│   │       ├── ui_config.h
│   │       └── gui/
│   │           └── main_screen.c
│   │
│   ├── 📦 watchdog/                 ← Sprint 11: System watchdog
│   │   ├── CMakeLists.txt
│   │   └── watchdog.h
│   │
│   ├── 📦 network/                  ← Sprint 14: Networking
│   │   ├── CMakeLists.txt
│   │   └── network_manager.h
│   │
│   ├── 📦 ota/                      ← Sprint 15: OTA updates
│   │   ├── CMakeLists.txt
│   │   └── ota_manager.h
│   │
│   ├── 📦 security/                 ← Sprint 16: Security (TLS)
│   │   ├── CMakeLists.txt
│   │   └── tls_manager.h
│   │
│   └── 🎯 app/                      ← Main application
│       ├── CMakeLists.txt
│       ├── main.cpp                 ← Entry point
│       └── cli.cpp                  ← Command-line interface
│
├── 🧪 tests/                        ← Unit & integration tests
│   ├── CMakeLists.txt               ← Test root configuration
│   ├── catch2_setup.cmake           ← Catch2 test framework setup
│   │
│   ├── unit/                        ← Unit tests (per module)
│   │   ├── CMakeLists.txt
│   │   ├── test_logger.cpp          ← Sprint 1
│   │   ├── test_config.cpp          ← Sprint 2
│   │   └── ... (test_ipc.cpp, test_protocol.cpp, etc.)
│   │
│   ├── integration/                 ← Integration tests
│   │   ├── CMakeLists.txt
│   │   ├── test_service_integration.cpp
│   │   └── ... (multi-module tests)
│   │
│   └── fixtures/                    ← Test data
│       ├── sample_config.json
│       └── test_protocol_packets.bin
│
├── 🔨 scripts/                      ← Build & deployment helpers
│   ├── build.sh                     ← Compile Linux side
│   ├── build-mcu.sh                 ← Compile MCU firmware
│   ├── flash-mcu.sh                 ← Upload to STM32
│   ├── format-code.sh               ← Code formatting (clang-format)
│   ├── static-check.sh              ← Static analysis (cppcheck)
│   ├── create-image.sh              ← Build Buildroot/Yocto image
│   └── clean.sh                     ← Clean build artifacts
│
├── 🔧 yocto/                        ← Yocto build layer (Sprint 12)
│   └── meta-eldmp/                  ← Custom Yocto layer
│       ├── conf/
│       │   ├── layer.conf           ← Layer configuration
│       │   └── machine/
│       │       └── beaglebone.conf
│       ├── recipes-core/            ← Base recipes
│       ├── recipes-app/             ← ELDMP application recipe
│       │   └── eldmp_3.5.bb
│       └── README.md
│
├── 📦 buildroot/                    ← Buildroot configuration (Sprint 12)
│   ├── config                       ← menuconfig output
│   ├── rootfs_overlay/              ← Custom rootfs files
│   │   ├── etc/systemd/system/
│   │   └── opt/eldmp/
│   └── README.md
│
├── 🌳 device-tree/                  ← Device Tree source (Sprint 6)
│   ├── am335x-boneblack.dts         ← BeagleBone reference (read-only)
│   └── overlays/                    ← Custom overlays
│       ├── eldmp-gpio.dts           ← GPIO pins configuration
│       ├── eldmp-uart.dts           ← UART configuration
│       └── eldmp-spi.dts            ← SPI configuration
│
└── 📄 OTHER REFERENCE FILES
    ├── EMBEDDED_C_MASTERY_GUIDE.md  ← In docs/learning/ (copy for reference)
    └── ELDMP_REPOSITORY_STRUCTURE.md ← This structure explained
```

---

## 📊 Phân Tích Cấu Trúc Theo Mục Đích

### **1️⃣ Learning Path (Đầu tiên, trước khi code)**

```
START HERE:
  1. docs/learning/EMBEDDED_C_MASTERY_GUIDE.md      (⭐ REQUIRED)
  2. docs/learning/SETUP_GUIDE.md                   (📖 10-15 phút)
  3. README.md (in root)                            (📖 5 phút)
  4. SPRINT_ROADMAP.md                              (📖 10 phút)
  
THEN, review relevant guides for upcoming sprint:
  - Sprint 3: docs/learning/ARM_CORTEX_M_GUIDE.md
  - Sprint 4: docs/learning/FREERTOS_BASICS.md
  - Sprint 5: docs/learning/LVGL_GUIDE.md
  - Sprint 6: docs/learning/LINUX_KERNEL_INTRO.md
```

### **2️⃣ Sprint Structure (Mỗi sprint cần)**

```
Sprint N:
├── Implement:     src/<module>/
├── Test:          tests/unit/test_<module>.cpp + tests/integration/
├── Document:      notes/sprint-N.md (Problem–Reality–Lessons)
├── Knowledge:     Read ONE source file from production code
└── Commit:        git tag vX.Y
```

### **3️⃣ Module Dependencies (Cách thêm module mới)**

```
src/
├── common/           ← Độc lập (foundation)
├── logger/           ← Dùng common (Sprint 1)
├── config/           ← Dùng logger + common (Sprint 2)
│
├── device/           ← Dùng logger + config (Sprint 7)
├── monitor/          ← Dùng logger + device (Sprint 8)
├── ipc/              ← Dùng logger + config (Sprint 9)
│
├── driver/           ← Kernel module (Sprint 6, riêng biệt)
├── mcu/              ← Firmware (Sprint 3-5, riêng biệt)
│
└── app/              ← Link tất cả (Sprint 1+)
```

### **4️⃣ Knowledge Base Mapping (Kỳ lục: Chủ đề → File)**

| Chủ đề | File | Sprint |
|--------|------|--------|
| C fundamentals | docs/learning/EMBEDDED_C_MASTERY_GUIDE.md | 0 |
| Memory layout | docs/learning/EMBEDDED_C_MASTERY_GUIDE.md#1 | 0 |
| Pointers & callbacks | docs/learning/EMBEDDED_C_MASTERY_GUIDE.md#3 | 0-1 |
| Bitwise operations | docs/learning/EMBEDDED_C_MASTERY_GUIDE.md#4 | 3-6 |
| ARM Cortex-M | docs/learning/ARM_CORTEX_M_GUIDE.md | 3 |
| Bare-metal GPIO | docs/learning/ARM_CORTEX_M_GUIDE.md + src/mcu/bare-metal/ | 3 |
| FreeRTOS tasks | docs/learning/FREERTOS_BASICS.md | 4 |
| LVGL GUI | docs/learning/LVGL_GUIDE.md | 5 |
| Linux kernel | docs/learning/LINUX_KERNEL_INTRO.md | 6 |
| Device Tree | device-tree/overlays/ | 6 |
| D-Bus IPC | docs/learning/SYSTEMD_GUIDE.md | 9 |
| Protocol design | docs/protocols/ELDMP_PROTOCOL_SPEC.md | 13 |
| OTA updates | docs/release-notes/v3.0.md | 15 |
| Security (TLS) | docs/release-notes/v3.5.md | 16 |

---

## 🚀 Getting Started (First 15 Minutes)

```bash
# 1. Clone (hoặc init nếu mới)
git clone https://github.com/you/eldmp.git
cd eldmp

# 2. Read overview
cat README.md

# 3. Setup environment
cat docs/learning/SETUP_GUIDE.md
./scripts/build.sh

# 4. Verify build
cd build && ctest

# 5. Start learning
cat docs/learning/EMBEDDED_C_MASTERY_GUIDE.md | less

# 6. First assignment
cat notes/SPRINT_TEMPLATE.md
# Write your own notes/sprint-0.md about setup experience
```

---

## 📋 File Naming Conventions

### **Source Code**
```
src/<module>/<file>.cpp          ← Implementation
src/<module>/include/<file>.h    ← Header
tests/unit/test_<module>.cpp     ← Unit test
tests/integration/test_*.cpp     ← Integration test
```

### **Documentation**
```
docs/learning/<topic>.md         ← Educational guide
docs/architecture/decisions/ADR-XXXX-*.md  ← Architectural decision
docs/release-notes/v<x.y>.md     ← Version milestone
notes/sprint-<N>.md              ← Sprint journal
```

### **Build & Scripts**
```
scripts/<action>.sh              ← Bash script (build, flash, format)
CMakeLists.txt                   ← CMake config (root or module)
.clang-format                    ← Code style
```

---

## 🔄 Typical Sprint Workflow

```
1. PLAN (Read docs/learning/)
   └─ Understand what to build
   
2. DESIGN (Update notes/sprint-N.md)
   └─ Write "Problem" & "Expected Outcome"
   
3. IMPLEMENT (Add to src/module/)
   └─ Code implementation
   
4. TEST (Add to tests/unit/)
   └─ Write test cases
   
5. DEBUG & FIX
   └─ Run: ./scripts/build.sh && cd build && ctest
   
6. REVIEW (Check code quality)
   └─ Run: ./scripts/format-code.sh && ./scripts/static-check.sh
   
7. DOCUMENT (Finish notes/sprint-N.md)
   └─ Write "Thực tế", "Root Cause", "Bài Học"
   
8. COMMIT & TAG
   └─ git add -A && git commit -m "sprint-N: ..."
   └─ git tag vX.Y
   
9. RELEASE (Update docs/release-notes/)
   └─ Create docs/release-notes/vX.Y.md
```

---

## 🎯 Quick Reference: What File to Edit?

| Task | Edit This File |
|------|---|
| Add new C++ module | Create `src/<module>/<module>.cpp` |
| Add header | Create `src/<module>/include/<module>.h` |
| Add unit test | Create `tests/unit/test_<module>.cpp` |
| Fix build error | Check `src/<module>/CMakeLists.txt` |
| Add design decision | Create `docs/architecture/decisions/ADR-XXXX-*.md` |
| Record sprint learnings | Edit `notes/sprint-N.md` |
| Add learning guide | Create `docs/learning/<topic>.md` |
| Configure build | Edit root `CMakeLists.txt` or `scripts/build.sh` |
| Add compile flag | Edit `CMakeLists.txt` |
| Change coding style | Edit `.clang-format` |

---

## 📦 Dependency Graph (What Depends On What)

```
app/
├── logger ────────┐
│                  ├─→ common
├── config ────────┤
│                  └──→ logger
│
└─ (future services)
   └── device ────┬─→ logger + config
   └── monitor ───┼─→ logger + device
   └── ipc ───────┴─→ config + logger
   
device-tree/          (independent, Sprint 6)
mcu/firmware/         (independent, Sprint 3-5)
driver/kernel/module/ (independent, Sprint 6)
```

---

## ✨ Best Practices

### **1. Keep Each Module Independent**
- Each `src/<module>/` should be buildable standalone
- Avoid circular dependencies
- Use interfaces (`.h` files) for coupling

### **2. Document As You Code**
- Commit message: "what" + "why"
- Header comment: module purpose
- Inline comments: "why", not "what"

### **3. Test-Driven When Possible**
- Write test first, then implementation
- Keep tests simple and focused
- One test per behavior

### **4. Learning Notes Capture Insights**
- Not just a summary, but "what I learned"
- Why a bug happened, not just how to fix it
- Recommend for future sprints

### **5. Keep Git History Clean**
- One feature = one pull request / one commit
- Good commit messages
- Tag at milestones (v0.5, v1.0, ...)

---

## 📞 When Stuck?

1. **Code doesn't compile?**
   - Check: `CMakeLists.txt` for your module
   - Run: `./scripts/format-code.sh` (syntax issues)
   - Check: C++ version compatibility

2. **Test fails?**
   - Run: `cd build && ctest --output-on-failure -VV`
   - Add debug logs
   - Isolate the failing test

3. **Design question?**
   - Check: `docs/architecture/decisions/` for similar decision
   - Read: relevant learning guide from `docs/learning/`
   - Ask yourself: "What would production code do?"

4. **How to add new module?**
   - Copy template from existing module (e.g., `src/logger/`)
   - Add entry to `src/CMakeLists.txt`
   - Create `tests/unit/test_<module>.cpp`

---

## 🎓 Learning Progression

```
Week 1:
  ├─ Read: EMBEDDED_C_MASTERY_GUIDE.md
  ├─ Do: SETUP_GUIDE.md (environment)
  └─ Play: Build skeleton, run make

Week 2-3:
  ├─ Sprint 0: Repository setup
  ├─ Sprint 1: Logger module
  └─ Sprint 2: Config manager

Month 2:
  ├─ Sprint 3-5: MCU firmware (bare-metal → FreeRTOS → LVGL)
  └─ Output: V0.5 release

Month 3-4:
  ├─ Sprint 6-11: Linux kernel + services
  └─ Output: V1.0 release

... (continue per roadmap)
```

---

**This visual guide + structure files are your complete roadmap. Start with learning guides, then follow sprint by sprint. Questions? Check docs first! 🚀**
