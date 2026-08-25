# 🚀 ELDMP Setup Đơn Giản — Chỉ Dùng Git Local

**Mục đích:** Setup ELDMP repository trên máy tính của bạn mà không cần GitHub.

---

## 📋 Các File Bạn Đã Download

```
✓ 00-START-HERE.md
✓ EMBEDDED_C_MASTERY_GUIDE.md        ← Học C trước (quan trọng nhất)
✓ ELDMP_REPOSITORY_STRUCTURE.md
✓ ELDMP_REPO_VISUAL_GUIDE.md
✓ FILE-TREE.txt
✓ IMPLEMENTATION-SUMMARY.md
✓ INDEX.md
✓ README-FIRST.md
✓ init-eldmp-repo.sh
✓ eldmp-complete-repository.tar.gz   ← Repository hoàn chỉnh
```

**Tất cả file đều đó rồi!** INDEX.md = INDEX.md, README-FIRST.md = README-FIRST.md, etc.

---

## 🎯 Setup Cơ Bản (5 Phút)

### **Bước 1: Chọn Nơi Lưu Dự Án**

```bash
# Tạo thư mục cho ELDMP (Windows CMD/PowerShell hoặc Git Bash)
mkdir C:\Users\YourName\Projects\eldmp
cd C:\Users\YourName\Projects\eldmp

# Hoặc Linux/Mac
mkdir ~/Projects/eldmp
cd ~/Projects/eldmp
```

### **Bước 2: Extract Repository**

```bash
# Nếu đã download eldmp-complete-repository.tar.gz
# Dùng 7-Zip hoặc tar (Git Bash đã có sẵn tar)

tar -xzf ../eldmp-complete-repository.tar.gz
# Hoặc: bạn có thể copy nội dung bằng File Explorer

# Kết quả: thư mục eldmp/ chứa:
# ├── src/
# ├── tests/
# ├── docs/
# ├── scripts/
# ├── CMakeLists.txt
# ├── README.md
# └── .git/ (đã có git history)
```

### **Bước 3: Kiểm Tra Git Đã Setup**

```bash
cd eldmp

# Xem git status
git status

# Xem git history
git log --oneline

# Xem tags
git tag
# Output: v0.0.1 (Sprint 0 skeleton)
```

---

## 📖 Bước Tiếp Theo (Học Trước Khi Code)

### **1. Đọc Hướng Dẫn (30 phút)**

Đọc file theo thứ tự này:

```
1. 00-START-HERE.md              (10 phút)
2. ELDMP_REPO_VISUAL_GUIDE.md    (15 phút)
3. FILE-TREE.txt                 (5 phút)
```

**Cách đọc:** Mở file bằng text editor hoặc cat/type command

```bash
# Windows (Notepad hoặc VS Code)
notepad 00-START-HERE.md
# hoặc
type 00-START-HERE.md | more

# Linux/Mac
cat 00-START-HERE.md | less
# hoặc
less 00-START-HERE.md
```

### **2. Học C Foundation (Bắt Buộc — 4-5 Giờ)**

```bash
# Mở file C guide
notepad EMBEDDED_C_MASTERY_GUIDE.md
# hoặc
less EMBEDDED_C_MASTERY_GUIDE.md
```

**Điểm quan trọng:**
- Chapter 1: Memory layout (30 phút)
- Chapter 2: Keywords (45 phút)
- Chapter 3: Pointers (1 giờ)
- Chapter 4: Bitwise (45 phút)
- Chapter 5: Data structures (45 phút)
- Chapter 6: Defensive C (45 phút)

**Phải tập code examples!** Không chỉ đọc.

---

## 💾 Git Cơ Bản (Đơn Giản — Không GitHub)

### **Tại Sao Không Cần GitHub?**

- ✅ Chỉ có bạn làm dự án
- ✅ Git local đủ để tracking changes
- ✅ Không cần backup remote (tạm thời)
- ✅ Đơn giản, nhanh

### **Git Commands Cơ Bản**

```bash
cd ~/eldmp  # Vào thư mục dự án

# 1. Xem trạng thái hiện tại
git status

# 2. Thêm file vào staging
git add src/logger/logger.cpp          # Một file
git add src/logger/                    # Cả folder
git add .                              # Tất cả (cẩn thận!)

# 3. Commit (lưu lại thay đổi)
git commit -m "sprint-1: Implement logger module"
# Hoặc tả chi tiết:
git commit -m "sprint-1: Implement logger module

- Add Logger class with file I/O
- Support log levels (DEBUG, INFO, WARN, ERROR)
- Implement log rotation
- Write unit tests

See: notes/sprint-1.md"

# 4. Xem history
git log --oneline
git log --oneline -10  # 10 commits gần nhất

# 5. Tạo tag (milestone)
git tag v1.0           # Đánh dấu version 1.0
git tag v0.5 abc1234   # Tag ở commit cụ thể
git tag -l             # Xem tất cả tags

# 6. Xem diff (thay đổi)
git diff               # So sánh với commit trước
git diff HEAD~1        # So sánh với 1 commit trước
```

### **Workflow Đơn Giản Cho Mỗi Sprint**

```bash
# Sprint N bắt đầu
cd ~/eldmp

# 1. Tạo/sửa code
nano src/logger/logger.cpp
# ... edit code ...

# 2. Check xem gì thay đổi
git status

# 3. Thêm vào staging
git add src/logger/

# 4. Commit
git commit -m "sprint-1: Logger implementation"

# 5. Repeat cho tests, notes, docs
git add tests/unit/test_logger.cpp
git commit -m "sprint-1: Logger unit tests"

git add notes/sprint-1.md
git commit -m "sprint-1: Learning notes"

# 6. Khi sprint xong, tạo tag
git tag v1.0
git log --oneline  # Xem history

# 7. Sprint tiếp theo
# Repeat từ bước 1
```

### **Cẩn Thận: .gitignore Đã Có**

File `.gitignore` trong repository sẽ tự động bỏ qua:
- `build/` (CMake output)
- `*.o`, `*.a` (object files)
- `.vscode/`, `.idea/` (IDE files)
- `*.log` (log files)

**Không cần configure thêm!**

---

## 📁 Cấu Trúc Thư Mục Hàng Ngày

```
~/eldmp/
├── src/                    ← Code chính (C++ + C firmware)
│   ├── logger/             ← Sprint 1
│   ├── config/             ← Sprint 2
│   └── ...
├── tests/                  ← Unit tests
├── docs/
│   ├── learning/           ← Tất cả guides đã tải
│   ├── architecture/
│   └── release-notes/
├── notes/
│   ├── sprint-0.md         ← Ghi chú của bạn
│   ├── sprint-1.md         ← (Tạo khi làm sprint 1)
│   └── ...
├── scripts/                ← Build scripts
├── .git/                   ← Git history (không động)
├── .gitignore              ← (Không động)
├── CMakeLists.txt          ← (Không động)
├── README.md               ← (Không động)
└── LICENSE                 ← (Không động)
```

---

## 🎯 Workflow Thực Tế (Từng Ngày)

### **Ngày 1-3: Học C Foundation**

```bash
cd ~/eldmp

# Đọc EMBEDDED_C_MASTERY_GUIDE.md
less EMBEDDED_C_MASTERY_GUIDE.md

# Tạo thư mục practice
mkdir ~/practice-c

# Code examples từ guide
cd ~/practice-c
nano memory_layout.c
gcc -Wall memory_layout.c -o memory_layout
./memory_layout

# Kiểm tra learning notes template
cd ~/eldmp
cat notes/SPRINT_TEMPLATE.md
```

### **Ngày 4-7: Hiểu Cấu Trúc Repository**

```bash
cd ~/eldmp

# Xem hết cấu trúc
ls -la

# Kiểm tra các guides
ls docs/learning/

# Xem example code
cat src/logger/include/logger.h
cat src/logger/logger.cpp

# Xem test example
cat tests/unit/test_logger.cpp
```

### **Ngày 8+: Bắt Đầu Sprint 1 (Logger)**

```bash
cd ~/eldmp

# 1. Tạo learning notes template
cat notes/SPRINT_TEMPLATE.md > notes/sprint-1.md
# Edit: notes/sprint-1.md (thêm Problem, Expected, etc.)

# 2. Start implementing
nano src/logger/logger.cpp

# 3. Thường xuyên check status
git status

# 4. Commit khi hoàn thành feature
git add src/logger/
git commit -m "sprint-1: Implement Logger class"

# 5. Commit tests
git add tests/unit/test_logger.cpp
git commit -m "sprint-1: Logger unit tests"

# 6. Commit notes
git add notes/sprint-1.md
git commit -m "sprint-1: Learning notes"

# 7. Khi sprint 1 xong
git tag v1.0
git log --oneline  # Xem toàn bộ history
```

---

## 🔄 Nếu Sau Này Muốn Push Lên GitHub

**Hiện tại:** Không cần.  
**Sau này (khi muốn backup):**

```bash
cd ~/eldmp

# 1. Tạo empty repo trên GitHub (không init README)
# Tên: eldmp
# Private hoặc Public (tuỳ chọn)

# 2. Add remote
git remote add origin https://github.com/your-username/eldmp.git

# 3. Push lên
git branch -M main
git push -u origin main
git push --tags  # Push tags cũng

# 4. Sau đó, mỗi lần commit local
git push
```

**Nhưng bây giờ: Bỏ qua bước này, dùng local git thôi.**

---

## ✅ Quick Checklist

**Hôm Nay:**
- [ ] Extract repository
- [ ] Kiểm tra git (`git status`, `git log --oneline`)
- [ ] Đọc 00-START-HERE.md

**Tuần 1:**
- [ ] Đọc EMBEDDED_C_MASTERY_GUIDE.md (chương 1-6)
- [ ] Tập code examples
- [ ] Hiểu cấu trúc repository

**Tuần 2:**
- [ ] Chuẩn bị Sprint 1
- [ ] Tạo notes/sprint-1.md
- [ ] Bắt đầu implement logger module

---

## 🛠️ Công Cụ Cần Thiết

**Bắt Buộc:**
- Git Bash / CMD (Windows) hoặc Terminal (Linux/Mac)
- Text editor (VS Code, Notepad++, Sublime, etc.)
- C compiler (gcc) — optional cho lúc build

**Tuỳ Chọn:**
- VS Code (editor + git integration)
- CMake (khi build phần Linux)
- ARM GCC toolchain (khi làm Sprint 3+)

---

## 📞 Nếu Có Vấn Đề

**Các file giúp đỡ:**
1. `00-START-HERE.md` — Giải thích cơ bản
2. `ELDMP_REPO_VISUAL_GUIDE.md` — Quick reference
3. `EMBEDDED_C_MASTERY_GUIDE.md` — C knowledge
4. `ELDMP_REPOSITORY_STRUCTURE.md` — Folder details

**Git help:**
```bash
git help               # Git help menu
git help commit        # Giúp về commit command
git help log           # Giúp về log command
```

---

## 💡 Pro Tips

1. **Commit thường xuyên** — Sau mỗi feature
2. **Viết message rõ ràng** — Dễ review history sau
3. **Dùng tags cho milestones** — `git tag v0.5`, `git tag v1.0`
4. **Viết sprint notes** — Học lâu hơn
5. **Đừng commit** `build/`, `*.o`, `*.log` — `.gitignore` đã xử lý

---

## 🎉 Sẵn Sàng!

```bash
cd ~/eldmp

# Xem status
git status

# Xem history
git log --oneline

# Xem tags
git tag -l

# Output sẽ thấy:
# On branch master
# nothing to commit, working tree clean
# 0ee76ad sprint-0: Initial repository structure
# v0.0.1
```

**Bây giờ bạn đã sẵn sàng để bắt đầu!**

**Bước tiếp theo:**
1. Đọc `00-START-HERE.md` (10 phút)
2. Đọc `EMBEDDED_C_MASTERY_GUIDE.md` (4-5 giờ)
3. Bắt đầu Sprint 1!

---

**Happy coding! 🚀**
