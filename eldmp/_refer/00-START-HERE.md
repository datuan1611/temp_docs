# 🚀 ELDMP Repository Setup — START HERE

## Tóm Tắt

Bạn vừa nhận được một **bộ hoàn chỉnh** để khởi tạo ELDMP repository với cấu trúc chuyên nghiệp, đầy đủ documentation, và sẵn sàng để bắt đầu Sprint 0.

**Files trong thư mục này:**
1. ⭐ **EMBEDDED_C_MASTERY_GUIDE.md** — Foundation C knowledge (đọc trước)
2. **ELDMP_REPOSITORY_STRUCTURE.md** — Chi tiết từng thư mục & mục đích
3. **ELDMP_REPO_VISUAL_GUIDE.md** — Sơ đồ + quick reference
4. **init-eldmp-repo.sh** — Script tự động khởi tạo repo

---

## 📋 Bước 1: Hiểu Toàn Bộ Bố Cục (5 phút)

Đọc theo thứ tự này:

```
1. Phần này (00-START-HERE.md)
2. ELDMP_REPO_VISUAL_GUIDE.md — Xem sơ đồ & cấu trúc tổng quan
3. ELDMP_REPOSITORY_STRUCTURE.md — Hiểu chi tiết từng thư mục
```

**Key takeaways:**
- Repository có **docs/, src/, tests/, scripts/, yocto/, etc.**
- Mỗi **sprint thêm modules mới**, không xoá cái cũ
- **Learning guides** nằm trong `docs/learning/` — đọc trước khi code
- **Git history** được lưu trữ bằng tags (v0.5, v1.0, v1.5, ...)

---

## 📚 Bước 2: Học Foundation C (Tối thiểu 1-2 tuần)

⭐ **IMPORTANT:** Đây là bước cốt lõi nhất trước khi bắt đầu code.

### Cách đọc EMBEDDED_C_MASTERY_GUIDE.md

File có **6 chương chính:**

```
1. TƯ DUY BỘ NHỚ (Memory Layout) — 30 phút
   └─ Flash, RAM, Stack, Heap
   └─ Biến global, static, local
   
2. TỪ KHÓA ĐẶC BIỆT (Qualifiers) — 45 phút
   └─ volatile, const, static, inline, extern
   
3. CON TRỎ (Pointers) — 1 giờ
   └─ Pointer arithmetic, void*, function pointers
   
4. THAO TÁC BIT (Bitwise) — 45 phút
   └─ AND/OR/XOR/SHIFT, bit masking, bit-fields
   
5. CẤU TRÚC DỮ LIỆU (Data Structures) — 45 phút
   └─ Circular buffer, linked list, event flags
   
6. BẢO VỆ BỘ NHỚ (Defensive Programming) — 45 phút
   └─ Undefined Behavior, NULL checks, assertions
```

**Tổng thời lượng:** ~4-5 giờ đọc + thực hành

### Cách Thực Hành

Để mỗi section, viết **small C program** để thử:

```bash
# Tạo thư mục tạm
mkdir ~/eldmp-c-practice
cd ~/eldmp-c-practice

# Viết code từ guide
nano memory_layout.c
gcc -Wall -Wextra memory_layout.c -o memory_layout
./memory_layout

# Hiểu output, modify, try lại
```

**Recommended exercises:**
1. Memory layout: In ra địa chỉ của global, static, local variables
2. Pointers: Implement function pointer callback system
3. Bitwise: Implement bit masking macros (SET_BIT, CLEAR_BIT, READ_BIT)
4. Data structures: Implement circular buffer
5. Defensive: Write code with checks, handle NULL pointers

---

## 🔧 Bước 3: Setup Repository (15 phút)

### Option A: Dùng Script (Recommended)

```bash
# Tạo thư mục cho ELDMP
mkdir ~/eldmp
cd ~/eldmp

# Chạy script tự động khởi tạo
bash ~/path/to/init-eldmp-repo.sh
```

**Kết quả:**
- ✅ Git repository initialized
- ✅ Toàn bộ folder structure created
- ✅ CMake build system setup
- ✅ GitHub Actions CI pipeline ready
- ✅ Skeleton source files (logger, config)
- ✅ Unit test framework (Catch2)
- ✅ Initial commit + tag v0.0.1

### Option B: Manual Setup (Nếu muốn hiểu chi tiết)

1. **Init git:**
   ```bash
   git init
   git config user.name "Your Name"
   git config user.email "you@example.com"
   ```

2. **Create directories** (xem `ELDMP_REPOSITORY_STRUCTURE.md`)
   ```bash
   mkdir -p docs/{architecture/decisions,learning,release-notes}
   mkdir -p src/{logger,config,common,device,monitor,ipc,mcu,driver,app}
   mkdir -p tests/{unit,integration}
   mkdir -p scripts yocto buildroot device-tree notes
   ```

3. **Copy CMakeLists.txt, README.md, LICENSE** (xem file guide)

4. **Commit:**
   ```bash
   git add -A
   git commit -m "sprint-0: Initial repository structure"
   git tag v0.0.1
   ```

---

## ✅ Bước 4: Verify Build (10 phút)

```bash
cd ~/eldmp

# Install dependencies (Ubuntu/Debian)
sudo apt-get install -y build-essential cmake

# Build
./scripts/build.sh

# Expected output:
# ✓ Directory structure created
# ✓ CMake configured
# ✓ Compiled successfully
# ✓ Tests passed
```

Nếu thành công, bạn sẽ thấy:
```
✅ Build successful!
📦 Output: build/src/app/eldmp
```

---

## 📖 Bước 5: Explore Cấu Trúc (20 phút)

```bash
cd ~/eldmp

# Xem README
cat README.md

# Xem architecture overview
cat docs/architecture/ARCHITECTURE.md

# Xem roadmap tóm tắt
cat SPRINT_ROADMAP.md

# List tất cả documentation
find docs/learning -name "*.md" | sort
```

**Key files to review:**
```
1. docs/learning/SETUP_GUIDE.md ← Environment setup in detail
2. docs/learning/ARM_CORTEX_M_GUIDE.md ← Cho Sprint 3
3. docs/learning/FREERTOS_BASICS.md ← Cho Sprint 4
4. docs/architecture/decisions/ADR-* ← Design decisions
5. notes/SPRINT_TEMPLATE.md ← How to write sprint notes
```

---

## 🎯 Bước 6: Làm Sprint 0 Checklist

**Sprint 0 = Environment Setup & Repository.**

Điền vào `notes/sprint-0.md`:

```markdown
# Sprint 0 — Environment Setup & Repository Structure

## Problem (Vấn đề)
Cần tạo repository structure rõ ràng cho dự án 16-sprint.

## Expected Outcome (Kỳ Vọng)
- Git repo hoạt động
- CMake build system chạy được
- Folder structure clear
- Có tài liệu cho tất cả sprint

## What Actually Happened (Thực Tế)
[Describe your experience with init-eldmp-repo.sh or manual setup]
- Mất bao lâu?
- Có vấn đề gì?
- Phần nào khó nhất?

## Root Cause / Solution
[If there were issues, what caused them?]

## Lessons Learned
[Key takeaways to apply in Sprint 1]
- 1 learning point
- 2 learning point
- 3 learning point

## References Used
- init-eldmp-repo.sh (automation)
- ELDMP_REPOSITORY_STRUCTURE.md (understanding)
- CMake documentation (build system)

## Time Spent
- Planned: 1.5 hours
- Actual: __ hours
- Variance: __
```

**Commit this:**
```bash
git add notes/sprint-0.md
git commit -m "sprint-0: Environment setup + learning notes"
```

---

## 📊 Next Steps After Sprint 0

```
Sprint 0 (Setup) ✓ DONE
    ↓
Sprint 1 (Logger module)
    - Implement: src/logger/logger.cpp
    - Test: tests/unit/test_logger.cpp
    - Learn: File I/O, log rotation
    - Read: spdlog source code
    
Sprint 2 (Config manager)
    - Implement: src/config/config_manager.cpp
    - Test: tests/unit/test_config.cpp
    - Learn: JSON parsing
    
... (continue per roadmap)
```

---

## 🚨 Common Issues & Fixes

### Issue 1: CMake not found
```bash
sudo apt-get install cmake
```

### Issue 2: Compiler missing
```bash
sudo apt-get install build-essential g++
```

### Issue 3: Git not initialized properly
```bash
cd ~/eldmp
rm -rf .git
git init
```

### Issue 4: Can't run build.sh
```bash
chmod +x scripts/build.sh
```

### Issue 5: Tests fail
```bash
cd build
ctest --output-on-failure -VV  # Verbose output
```

---

## 📚 Reading Order (Recommended)

### **Week 1-2: Foundation**
```
1. This file (00-START-HERE.md) ← You are here
2. ELDMP_REPO_VISUAL_GUIDE.md
3. EMBEDDED_C_MASTERY_GUIDE.md (Full, with practice)
```

### **Week 3: Setup & Sprint 0**
```
1. ELDMP_REPOSITORY_STRUCTURE.md (Chi tiết)
2. Run: init-eldmp-repo.sh
3. Explore: docs/learning/SETUP_GUIDE.md
4. Verify: ./scripts/build.sh
5. Write: notes/sprint-0.md
```

### **Week 4+: Start Sprint 1**
```
1. docs/learning/FREERTOS_BASICS.md (Preview Sprint 4)
2. docs/learning/ARM_CORTEX_M_GUIDE.md (For Sprint 3)
3. Read: ELDMP_Roadmap_MCU_vi.md (Full detail)
4. Implement: src/logger/ (Sprint 1)
```

---

## 🎓 What You'll Learn by End of Sprint 0

- ✅ Git workflow (commit, tag, branches)
- ✅ CMake build system structure
- ✅ Modular C++ project organization
- ✅ CI/CD pipeline basics (GitHub Actions)
- ✅ How to read project documentation
- ✅ Sprint structure & learning pattern
- ✅ Foundation C knowledge (volatile, pointers, bitwise, etc.)

---

## 💡 Pro Tips

1. **Keep learning notes comprehensive**
   - Not just what you built, but WHY it matters
   - Record bugs and how you debugged them
   - Note time spent — helps estimate future sprints

2. **Commit frequently**
   - Don't wait until sprint end
   - Commit when feature is working (but not polished)
   - Good commit message = better git history

3. **Read the source code**
   - Each sprint requires reading 1+ real production code
   - E.g., Sprint 1: spdlog logger library
   - Sprint 4: FreeRTOS kernel source
   - This is where real learning happens

4. **Test-driven approach helps**
   - Write test first, then implementation
   - Run tests frequently: `cd build && ctest -VV`

5. **Use the guides — they're there for a reason**
   - Every guide maps to a specific sprint
   - Don't skip learning guides to "save time"
   - Time invested now saves debugging later

---

## ❓ FAQ

**Q: Tôi nên dùng script hay manual setup?**
A: Script (Option A) nhanh hơn. Manual (Option B) nếu muốn hiểu từng bước.

**Q: Tôi cần cài STM32 ngay không?**
A: Không. Sprint 0-2 hoàn toàn trên Linux. Mua STM32 Nucleo trước Sprint 3.

**Q: Tôi có thể skip C learning guide không?**
A: Không khuyến khích. Foundation C là nền tảng cho 16 sprint tiếp theo.

**Q: Mỗi sprint mất bao lâu?**
A: ~1-2 tuần bán thời gian (8-10 giờ/tuần). Tổng Core Track: 16-19 tháng.

**Q: Tôi nên push lên GitHub chưa?**
A: Sau khi test build thành công. Có thể public hoặc private repository.

**Q: Dùng repository này để phỏng vấn được không?**
A: Có! V0.5, V1.0, V1.5, V2.0, V3.0, V3.5 đều là milestone portfolio.

---

## 🎯 Your First Assignment

**After reading this file:**

```bash
# 1. Read visual guide (5 min)
cat ELDMP_REPO_VISUAL_GUIDE.md

# 2. Setup repository (15 min)
bash init-eldmp-repo.sh

# 3. Verify build (10 min)
cd ~/eldmp
./scripts/build.sh
cd build && ctest

# 4. Write first learning note (15 min)
nano notes/sprint-0.md
# Fill in: Problem, Expected, Actual, Lessons

# 5. Commit (5 min)
git add -A
git commit -m "sprint-0: Initial setup + notes"

# Total: ~60 minutes
```

---

## 📞 Need Help?

If stuck:
1. Check: `ELDMP_REPOSITORY_STRUCTURE.md` for file locations
2. Check: `ELDMP_REPO_VISUAL_GUIDE.md` for quick reference
3. Check: `EMBEDDED_C_MASTERY_GUIDE.md` for C concepts
4. Read: `docs/learning/SETUP_GUIDE.md` for environment issues

---

## ✨ Ready?

```
1. Read this (00-START-HERE.md) ✓
2. Next: Read ELDMP_REPO_VISUAL_GUIDE.md
3. Then: Run init-eldmp-repo.sh
4. Finally: ./scripts/build.sh && cd build && ctest

Let's go! 🚀
```

---

**Questions? Start with the visual guide, then reference the structure doc. Everything is documented. You've got this! 💪**
