# EMBEDDED C MASTERY GUIDE (ELDMP ROADMAP)
## Lộ Trình Từ MCU Bare-Metal → FreeRTOS → Embedded Linux

---

## 1. TƯ DUY BỘ NHỚ TRONG EMBEDDED C

### 1.1 Bối Cảnh Bộ Nhớ: Kiến Trúc Flash + RAM

**Thiết bị MCU nhúng điển hình (STM32H743ZI):**

```
┌─────────────────────────────────────────────────┐
│                    FLASH (2 MB)                 │
├─────────────────────────────────────────────────┤
│ Text (code binary - .text section)              │  Chứa instruction machine code
├─────────────────────────────────────────────────┤
│ Read-Only Data (const, string literal)          │  const int x = 42; → lưu ở Flash
│ (.rodata, .data initialization image)          │  tiết kiệm RAM, không mất khi power off
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│                     RAM (928 KB)                │
├─────────────────────────────────────────────────┤
│ Initialized Data (.data)                        │  global int x = 42; → được init từ Flash
├─────────────────────────────────────────────────┤
│ Uninitialized Data (.bss)                       │  global int y; → FW zeros nó trước main()
├─────────────────────────────────────────────────┤
│ Heap (thường không dùng, hoặc rất hạn chế)    │  malloc()/free() - cấm trong bare-metal
├─────────────────────────────────────────────────┤
│ Stack (từ cao xuống thấp)                       │  function stack frames, local variables
│ ← SP (Stack Pointer) tăng xuống khi push       │  CẢNH BÁO: Stack overflow khi chạm Heap
└─────────────────────────────────────────────────┘
```

**Vì sao bài toán này quan trọng:**
- Embedded thường có RAM hạn chế (vài KB tới MB, không phải GB như desktop)
- Flash (persistent, không mất khi reboot) được dùng để tiết kiệm RAM cho const data
- Bootloader phải copy .data từ Flash vào RAM, zero .bss trước khi chạy main()

**Ví dụ kiến trúc GCC linker script (STM32):**
```c
/* Linker script snippet (lập trình viên không viết, nhưng phải hiểu) */
MEMORY
{
  FLASH (rx)   : ORIGIN = 0x08000000, LENGTH = 2048K
  RAM (rwx)    : ORIGIN = 0x20000000, LENGTH = 928K
}

/* .data section được tạo như sau:
   - Phần khởi tạo lưu ở FLASH
   - Phần runtime lưu ở RAM
   - Bootloader copy từ Flash → RAM
*/
```

---

### 1.2 Biến & Vòng Đời (Variable Lifetime & Storage Class)

| Khai báo | Vùng nhớ | Vòng đời | Giá trị khởi tạo | Dùng cho |
|---|---|---|---|---|
| `int global = 5;` | RAM (.data) | Toàn bộ chương trình | Copy từ Flash lúc startup | State dùng chung nhiều function |
| `static int file_level = 10;` | RAM (.data) | Toàn bộ chương trình | Copy từ Flash | Biến cục bộ ở mức file (Encapsulation) |
| `int func_local = 20;` | **Stack** | Chỉ trong function | **Không khởi tạo** (rác) | Biến tạm trong function |
| `static int persistent = 30;` | RAM (.data) | Toàn bộ chương trình | Copy từ Flash | Giữ state qua nhiều lần gọi function |
| `const int fixed = 40;` | **Flash (.rodata)** | Toàn bộ chương trình | Flash | Hằng số, tiết kiệm RAM |
| `const volatile int *reg = 0x40000000;` | Stack pointer → Flash | Truy cập register | — | MMIO register (phải volatile!) |

**Code minh họa:**

```c
#include <stdint.h>

int global_var = 100;              /* RAM (.data), được init từ Flash */
static int file_static = 200;      /* RAM (.data), chỉ nhìn thấy trong file này */
const int CONST_CONFIG = 300;      /* Flash (.rodata), NOT RAM - tiết kiệm! */

void example_function(void) {
    int local_var = 400;           /* Stack, được zero mỗi lần gọi */
    static int call_counter = 0;   /* RAM, giữ giá trị qua các lần gọi */
    
    call_counter++;                /* lần 1: 1, lần 2: 2, ... */
    
    printf("Called %d times\n", call_counter);
    /* local_var mất sau khi function trả về */
}

/* Tại sao điều này quan trọng cho MCU:
   - RAM có giới hạn → hạn chế biến global
   - const → Flash → tiết kiệm RAM cho config/lookup table
   - static local → giữ state mà không global (encapsulation)
   - Stack-based local var → tự giải phóng, không leak
*/
```

**Cạm bẫy thực tế:**

```c
/* ❌ SAI: Tạo pointer tới local variable, rồi dùng sau khi function trả về */
int* bad_pointer_example(void) {
    int local = 42;
    return &local;  /* ← Undefined Behavior! local bị xoá khi return */
}

/* ❌ SAI: Giả sử biến local được init tự động */
void uninitialized_local(void) {
    int x;          /* x chứa rác từ Stack */
    if (x > 50) {   /* Hành vi không xác định */
        /* ... */
    }
}

/* ✓ ĐÚNG: Khởi tạo rõ ràng hoặc dùng static */
void correct_initialization(void) {
    int x = 0;      /* Khởi tạo rõ */
    static int y;   /* static int mặc định = 0 (zero-init) */
}
```

---

### 1.3 Stack vs Heap: Tại Sao Cấm malloc() Trong Bare-Metal & FreeRTOS

**Bối cảnh:**
```
Stack:
  ↓ grows downward (thường)
  SP → [local vars của current function]
       [return addr, saved registers]
       ...

Heap:
  ↑ grows upward
  [allocated blocks]
  [free space]
```

**Vấn đề #1: Fragmentation (Phân Tán Bộ Nhớ)**

```c
void fragmentation_demo(void) {
    /* Heap: [Block1: 100B][Block2: 100B][Block3: 100B] */
    
    int* p1 = malloc(100);  /* Allocate Block1 */
    int* p2 = malloc(100);  /* Allocate Block2 */
    int* p3 = malloc(100);  /* Allocate Block3 */
    
    free(p2);  /* Free Block2 (ở giữa) */
    
    /* Heap: [Block1: 100B][HOLE: 100B][Block3: 100B]
       Bây giờ cần allocate 100B? OK (dùng hole)
       Nhưng cần allocate 120B? ❌ Lỗi, dù tổng free là 100B
    */
    
    int* p4 = malloc(120);  /* Có thể FAIL! */
}

/* Embedded system có thể chạy 24/7, malloc/free lặp lại → 
   Fragmentation lớn → Memory exhaustion → Crash đột ngột */
```

**Vấn đề #2: Không Xác Định Thời Gian Thực (No Real-Time Guarantee)**

```c
void real_time_issue(void) {
    /* allocate có thể chậm vô tính (O(n)) do tìm kiếm free block)
       → ISR interrupt lâu → timing deadline vỡ */
    
    void* ptr = malloc(512);  /* 1 microsecond? 100 microsecond? Unknown! */
    
    /* Điều này bị cấm trong ISR và FreeRTOS critical section */
}
```

**Vấn đề #3: Không Có Giải Phóng Tự Động (No Automatic Cleanup)**

```c
/* ❌ Memory leak trong bare-metal/FreeRTOS:
   Khi task FreeRTOS terminate, heap không tự cleanup
*/
void task_example(void) {
    int* data = malloc(1000);
    
    /* Nếu task exit mà không free, 1000B bị leak vĩnh viễn */
    vTaskDelete(NULL);  /* Task terminate, data pointer mất */
    /* data không ai free → Heap bị gọm lâu dần */
}
```

**Giải pháp thay thế:**

```c
/* ✓ Phương pháp 1: Static allocation (an toàn nhất) */
typedef struct {
    uint8_t buffer[512];
    uint32_t index;
} DataBuffer;

static DataBuffer buffers[10];  /* Cấp phát tĩnh, không heap */

void task_safe(void) {
    DataBuffer* buf = &buffers[0];  /* Chỉ pointer, không malloc */
    /* ... dùng buf ... */
    /* Tự động cleanup khi task exit */
}

/* ✓ Phương pháp 2: Memory Pool (Static heap + allocation tracking) */
typedef struct {
    uint8_t pool[4096];
    uint32_t allocated_size;
} MemoryPool;

static MemoryPool my_pool = {0};

void* pool_malloc(uint32_t size) {
    if (my_pool.allocated_size + size > sizeof(my_pool.pool)) {
        return NULL;  /* Out of pool */
    }
    void* ptr = &my_pool.pool[my_pool.allocated_size];
    my_pool.allocated_size += size;
    return ptr;
    /* Lưu ý: Không thể free từng block (pool only grows), 
       chỉ reset toàn bộ pool khi task restart */
}

/* ✓ Phương pháp 3: FreeRTOS Memory (xem mục 5) */
```

**Kết luận cho Embedded C:**
> **Bare-metal & ISR context: Tuyệt đối CẤM malloc/free**
> **FreeRTOS: Cho phép malloc (vxMemAlloc), nhưng chỉ khi:**
> - Task level (không ISR)
> - Có cơ chế quản lý pool, kiểm soát fragmentation
> - Luôn pair malloc/free (tracking leak)

---

## 2. TỪ KHÓA ĐẶC BIỆT (QUALIFIERS & KEYWORDS)

### 2.1 volatile: Bản Chất & Bắt Buộc Trong MCU

**Định nghĩa cơ bản (sai lầm thường gặp):**
> ❌ "volatile = chậm"
> ✓ "volatile = **compiler không tối ưu bỏ qua thao tác này**"

**Tại sao compiler tối ưu bỏ?**

```c
/* Bình thường, compiler thấy biến x không thay đổi trong vòng lặp
   → Tối ưu: chỉ đọc x một lần, reuse giá trị */

int x = 0;
while (1) {
    if (x > 0) {  /* x != 0 ở lần 1 → compiler tối ưu if luôn false */
        do_something();
    }
    /* Compiler không biết x được MCU hardware thay đổi ở ngoài! */
}

/* Nhưng hardware (ví dụ: register được ISR cập nhật, hay UART 
   data register được Rx interrupt thay đổi) LÀ thay đổi x
   → Compiler tối ưu SAI → Bug!
*/
```

**Giải pháp: volatile**

```c
/* ✓ ĐÚNG: volatile yêu cầu compiler đọc x từ memory mỗi lần
   (không cache vào CPU register) */
volatile int x = 0;

while (1) {
    if (x > 0) {  /* Compiler phải đọc x từ RAM mỗi iteration */
        do_something();
    }
}
```

**Trường hợp BẮT BUỘC dùng volatile trong MCU:**

#### A. Memory-Mapped I/O (MMIO) Register

```c
/* Bộ điều khiển GPIO của STM32 (ví dụ) */
typedef struct {
    volatile uint32_t MODER;      /* GPIO port mode register */
    volatile uint32_t OTYPER;     /* GPIO port output type register */
    volatile uint32_t OSPEEDR;    /* GPIO port output speed register */
    volatile uint32_t PUPDR;      /* GPIO port pull-up/pull-down register */
    volatile uint32_t IDR;        /* GPIO port input data register (READ only) */
    volatile uint32_t ODR;        /* GPIO port output data register (WRITE/READ) */
} GPIO_TypeDef;

/* MMIO virtual address (từ linker script) */
#define GPIOA ((GPIO_TypeDef *) 0x40020000)

void gpio_read_example(void) {
    /* Nếu IDR không volatile, compiler tối ưu:
       if (GPIOA->IDR > 0) { } /* Đọc lần 1 */
       if (GPIOA->IDR > 0) { } /* Compiler reuse kết quả lần 1 - SAI!
       
       Vì IDR là register nhập liệu, giá trị có thể thay đổi mỗi khi
       chân GPIO nhất định bị thay đổi từ bên ngoài
    */
    
    uint32_t pin_state1 = GPIOA->IDR;  /* Đọc lần 1 (compile: ldr) */
    uint32_t pin_state2 = GPIOA->IDR;  /* Đọc lần 2 (compile: ldr) - volatile buộc */
    
    /* Nếu pin thay đổi giữa 2 lần đọc, sẽ capture được */
}

void gpio_write_example(void) {
    /* Nếu ODR không volatile:
       GPIOA->ODR = 0x01;  /* Set LED1 */
       GPIOA->ODR = 0x01;  /* Same value - compiler tối ưu bỏ! */
       
       Nhưng việc viết tới register là **side effect**, không nên optimize
       (ví dụ: lần 1 set, lần 2 có thể cập nhật logic khác trong hardware)
    */
    
    GPIOA->ODR = 0x01;  /* volatile buộc compiler emit write instruction */
    GPIOA->ODR = 0x01;  /* volatile buộc compiler emit write instruction */
}
```

#### B. Interrupt Service Routine (ISR) & Shared Variable

```c
static volatile uint32_t interrupt_counter = 0;  /* Shared với ISR */

/* Main context */
void main_loop(void) {
    while (1) {
        if (interrupt_counter > 100) {  /* volatile: compiler đọc từ RAM */
            handle_many_interrupts();    /* Không optimize bỏ */
        }
    }
}

/* ISR context - chạy asynchronous, update interrupt_counter */
void UART_IRQHandler(void) {
    interrupt_counter++;  /* ISR modify */
}

/* Nếu interrupt_counter không volatile:
   → Compiler thấy main_loop không modify nó
   → Cache giá trị lúc đầu vào CPU register
   → ISR update RAM, nhưng main_loop vẫn dùng giá trị cũ ở register
   → Lỗi race condition
*/
```

#### C. Flag Được Modify Bởi Hardware (DMA Complete, ADC Ready, etc.)

```c
typedef struct {
    volatile uint32_t SR;  /* Status register - update bởi hardware */
    volatile uint32_t DR;  /* Data register */
} ADC_TypeDef;

#define ADC ((ADC_TypeDef *) 0x50040000)

void adc_wait_ready(void) {
    /* Chờ ADC conversion xong (hardware set flag tự động) */
    while ((ADC->SR & 0x01) == 0) {  /* volatile: không lặp vô hạn! */
        /* volatile buộc compiler check SR từ memory mỗi iteration */
    }
    
    /* Nếu không volatile:
       Compiler thấy `(ADC->SR & 0x01) == 0` không thay đổi mã
       → Tối ưu thành infinite loop (compiler không biết hardware update SR)
       → Chương trình treo
    */
}
```

**Quy tắc nhớ volatile:**
```
volatile = "Đừng optimize - giá trị có thể thay đổi bởi không phải lập trình viên"
           (ISR, hardware, DMA, memory-mapped register, ...)
```

**Code pattern an toàn:**

```c
/* ✓ PATTERN 1: volatile cho register access */
#define REG_READ(addr)  (*(volatile uint32_t*)(addr))
#define REG_WRITE(addr, val) (*(volatile uint32_t*)(addr) = (val))

void safe_register_access(void) {
    uint32_t status = REG_READ(0x40020010);  /* Compiler forced to read */
    REG_WRITE(0x40020014, 0x01);              /* Compiler forced to write */
}

/* ✓ PATTERN 2: volatile cho ISR-modified variable */
typedef struct {
    volatile uint32_t flags;       /* Shared với ISR */
    volatile uint32_t error_count; /* Shared với ISR */
} SystemState;

static SystemState sys_state = {0};

/* ✓ PATTERN 3: volatile pointer (advanced) */
typedef volatile struct {
    uint32_t reg1;
    uint32_t reg2;
} RegisterMap;

RegisterMap* hw_reg = (RegisterMap*)0x40000000;
hw_reg->reg1 = 42;  /* Chắc chắn access memory, không cache */
```

---

### 2.2 const: Bảo Vệ Dữ Liệu & Tiết Kiệm RAM

**Cơ bản: const data được lưu trong Flash, không RAM**

```c
/* ❌ SAI: Lãng phí RAM */
int lookup_table[] = {
    10, 20, 30, 40, 50, 60, 70, 80, 90, 100  /* 10 * 4 bytes = 40B RAM */
};

/* ✓ ĐÚNG: 40B Flash (persists), 0B RAM (const) */
const int lookup_table[] = {
    10, 20, 30, 40, 50, 60, 70, 80, 90, 100
};
```

**const Pointer vs Pointer to const (hay bị nhầm)**

```c
int x = 10, y = 20;

/* Case 1: const data, con trỏ thay đổi được */
const int *ptr1 = &x;      /* ptr1 → const int */
*ptr1 = 30;                /* ❌ Compiler error: không modify const data */
ptr1 = &y;                 /* ✓ OK: ptr1 thay đổi được */

/* Case 2: const con trỏ, data thay đổi được */
int * const ptr2 = &x;     /* const ptr → int */
*ptr2 = 30;                /* ✓ OK: data thay đổi được */
ptr2 = &y;                 /* ❌ Compiler error: const pointer không thay đổi */

/* Case 3: cả hai đều const */
const int * const ptr3 = &x;  /* const ptr → const int */
*ptr3 = 30;                /* ❌ Compiler error */
ptr3 = &y;                 /* ❌ Compiler error */

/* Mnemonic (nhớ từ phải sang trái):
   const int *ptr      → const [int], variable [ptr]
   int * const ptr     → constant [ptr], variable [int]
*/
```

**Ứng dụng thực tế: API bảo vệ dữ liệu**

```c
/* ✓ Function signature rõ ràng: không modify input buffer */
void process_data(const uint8_t *data, uint32_t len) {
    for (uint32_t i = 0; i < len; i++) {
        uint8_t byte = data[i];
        /* data[i] = 0xFF;  ❌ Compiler error: const param */
    }
}

/* ✓ Struct field protection */
typedef struct {
    const char *name;      /* Có thể thay đổi pointer, nhưng không string */
    const uint32_t id;     /* Không thay đổi được field này */
} Device;

Device dev = {"sensor", 123};
dev.id = 456;      /* ❌ Compiler error */
dev.name = "motor"; /* ✓ OK: pointer thay đổi (string khác) */

/* ✓ ROM-based configuration (Tiết kiệm RAM) */
typedef struct {
    const char *ssid;
    const char *password;
    const uint32_t timeout_ms;
} WiFiConfig;

const WiFiConfig wifi_profiles[] = {  /* Toàn bộ lưu Flash */
    {"home", "pass123", 5000},
    {"office", "office_pass", 10000},
};

void connect_wifi(uint32_t profile_idx) {
    const WiFiConfig *cfg = &wifi_profiles[profile_idx];  /* Pointer từ Flash */
    printf("SSID: %s\n", cfg->ssid);  /* Read từ Flash, không copy RAM */
}
```

**const volatile (kết hợp 2 qualifier)**

```c
/* Status register: hardware update (volatile), nhưng lập trình viên không modify */
volatile const uint32_t *hw_status_reg = (uint32_t*)0x40000000;

uint32_t status = *hw_status_reg;  /* Compiler: read từ memory (volatile) */
*hw_status_reg = 0;                /* ❌ Compiler error: const */

/* Pattern: volatile const = read-only register trong hardware */
```

---

### 2.3 static: Encapsulation & Persistent State

**Sử dụng #1: File-level encapsulation**

```c
/* file: uart_driver.c */

static uint8_t uart_buffer[256];     /* Chỉ nhìn thấy trong file này */
static volatile uint32_t buffer_index = 0;

/* Function được export */
void uart_send_char(uint8_t ch) {
    uart_buffer[buffer_index++] = ch;
    if (buffer_index >= 256) buffer_index = 0;
}

/* file: main.c */
void main(void) {
    uart_send_char('A');  /* ✓ OK: visible */
    
    uart_buffer[0] = 'B';  /* ❌ Compiler error: uart_buffer static, không visible */
}
```

**Sử dụng #2: Persistent local state (thay thế global)**

```c
/* ❌ Cách cũ: global (polluted namespace) */
uint32_t call_count = 0;  /* Mọi file đều nhìn thấy */

uint32_t get_call_count(void) {
    return ++call_count;
}

/* ✓ Cách tốt: static local (encapsulated) */
uint32_t get_call_count_better(void) {
    static uint32_t call_count = 0;  /* Static local, không global namespace */
    return ++call_count;
    
    /* call_count retain value qua mỗi lần gọi
       Lần 1: return 1
       Lần 2: return 2
       ...
    */
}

void main(void) {
    printf("%u\n", get_call_count_better());  /* 1 */
    printf("%u\n", get_call_count_better());  /* 2 */
    printf("%u\n", get_call_count_better());  /* 3 */
    
    /* Bên ngoài không thể access call_count trực tiếp
       (encapsulation tốt hơn global)
    */
}
```

**Sử dụng #3: Static array (memory pool initialization)**

```c
#define MAX_TASKS 10

typedef struct {
    uint32_t id;
    char name[32];
    uint32_t priority;
} Task;

static Task task_pool[MAX_TASKS] = {0};  /* Pre-allocated, zero-init */
static uint32_t task_count = 0;

void create_task(uint32_t id, const char *name, uint32_t priority) {
    if (task_count >= MAX_TASKS) return;  /* Pool full */
    
    task_pool[task_count].id = id;
    strncpy(task_pool[task_count].name, name, sizeof(task_pool[0].name) - 1);
    task_pool[task_count].priority = priority;
    
    task_count++;
}

Task* get_task(uint32_t id) {
    for (uint32_t i = 0; i < task_count; i++) {
        if (task_pool[i].id == id) return &task_pool[i];
    }
    return NULL;
}

/* ✓ Điểm: không malloc, memory layout tĩnh, không fragmentation */
```

**Vị trí lưu trữ của static (linker perspective)**

```c
int global_var = 50;              /* .data section (RAM) */
static int file_static = 60;      /* .data section (RAM) */
const int const_global = 70;      /* .rodata section (Flash) */

/* Linker map sẽ có:
   .data (RAM):
     global_var @ 0x20000000
     file_static @ 0x20000004
   .rodata (Flash):
     const_global @ 0x08001000
*/
```

---

### 2.4 inline & extern: Linkage & Optimization

**inline: Khi nào compiler copy code vào caller (không gọi function)**

```c
/* Bình thường, function call overhead:
   - Push return address vào stack
   - Push parameter registers vào stack
   - Jump tới function
   - Prologue/epilogue setup
   → Chi phí 10-20 cycle CPU
*/

/* Tối ưu: inline - compiler copy code function vào call site */
inline uint32_t min(uint32_t a, uint32_t b) {
    return (a < b) ? a : b;
}

uint32_t result = min(10, 20);

/* Compiler sinh ra (inline expand):
   uint32_t result = (10 < 20) ? 10 : 20;  ← No function call, pure code
*/

/* Ưu điểm:
   - Nhanh hơn (no call overhead)
   - Compiler có thể further optimize
   
   Nhược điểm:
   - Code size tăng (copy code mỗi call site)
   - Không lý tưởng cho large function
*/

/* ✓ TỐNG HỢP GỢI Ý:
   - Inline cho tiny utility function (vài dòng)
   - Không inline cho function chứa loop/complexity
   - Compiler thường ignore inline hint nếu function quá lớn
*/
```

**static inline (phổ biến trong header file)**

```c
/* header: bit_operations.h */

/* static inline cho phép định nghĩa trong header mà không linking error */
static inline void set_bit(volatile uint32_t *addr, uint32_t bit) {
    *addr |= (1U << bit);
}

static inline void clear_bit(volatile uint32_t *addr, uint32_t bit) {
    *addr &= ~(1U << bit);
}

/* Mỗi .c file include header này sẽ có copy riêng của hàm
   (Compiler tối ưu vào inline, no external linkage conflict)
*/

/* main.c */
#include "bit_operations.h"

void gpio_init(void) {
    volatile uint32_t *reg = (uint32_t*)0x40000000;
    set_bit(reg, 5);      /* Inline, no call overhead */
    clear_bit(reg, 3);
}
```

**extern: Cross-file linkage**

```c
/* file1.c */
extern int global_value;  /* Declaration: "Exists elsewhere, linker will link" */

void print_value(void) {
    printf("Value: %d\n", global_value);
}

/* file2.c */
int global_value = 42;    /* Definition: "Create it here" */

/* Linker sẽ resolve:
   file1.c: print_value() → extern global_value
   file2.c: global_value @ some_address
   Link thành công ✓
*/

/* Lưu ý: extern là default cho global variable/function ở C
   - int x;           ← extern (hidden unless declared static)
   - int func();      ← extern (hidden unless declared static)
   - static int y;    ← NOT extern (file-scope only)
*/
```

**Ứng dụng thực tế: Header guard pattern**

```c
/* header: config.h */
#ifndef CONFIG_H
#define CONFIG_H

extern const uint32_t TIMER_FREQ_HZ;  /* Declaration */
extern void init_timer(void);          /* Function declaration */

#endif

/* config.c */
#include "config.h"

const uint32_t TIMER_FREQ_HZ = 1000000;  /* Definition */

void init_timer(void) {
    /* ... */
}

/* other_module.c */
#include "config.h"

void setup(void) {
    init_timer();
    printf("Freq: %u Hz\n", TIMER_FREQ_HZ);  /* Linker sẽ link tới definitions */
}
```

---

## 3. CON TRỎ (POINTERS) & QUẢN LÝ BỘ NHỚ CHUYÊN SÂU

### 3.1 Con Trỏ Cơ Bản & Toán Tử Con Trỏ

**Bản chất: Con trỏ = Địa chỉ bộ nhớ (số nguyên)**

```c
int x = 42;                    /* x lưu tại địa chỉ, ví dụ: 0x20000000 */
int *ptr = &x;                 /* ptr = địa chỉ của x = 0x20000000 */

printf("x = %d\n", x);         /* 42 */
printf("ptr = %p\n", ptr);     /* 0x20000000 */
printf("*ptr = %d\n", *ptr);   /* 42 (dereference) */

*ptr = 100;                    /* Thay đổi giá trị x thông qua ptr */
printf("x = %d\n", x);         /* 100 */

/* Diagram:
   ┌─────────────────┐
   │  Stack/Memory   │
   ├─────────────────┤
   │ ptr   = 0x200.. │ ← địa chỉ con trỏ (địa chỉ của ptr)
   │ &ptr  = 0x200.. │ ← địa chỉ của con trỏ
   ├─────────────────┤
   │ x     = 100     │ ← giá trị của x
   │ &x    = 0x200.. │ ← địa chỉ của x (= giá trị ptr)
   └─────────────────┘
*/
```

**Pointer Arithmetic (phép toán con trỏ)**

```c
int arr[] = {10, 20, 30, 40, 50};  /* Địa chỉ arr[0] = 0x20000000 */

int *ptr = arr;  /* ptr = 0x20000000 (array name = address of first element) */

/* ✓ ptr + 1 = địa chỉ của arr[1] (NOT +1 byte, but +1 * sizeof(int)) */
printf("arr[1] = %d\n", *(ptr + 1));  /* Output: 20 */

/* ✓ ptr[i] ≡ *(ptr + i) */
printf("ptr[2] = %d\n", ptr[2]);     /* Output: 30 */

/* ✓ Pointer subtraction = index difference */
int *ptr_end = &arr[4];
int diff = ptr_end - ptr;  /* 4 (not 4*4=16, it's element count) */

/* ✓ Pointer comparison */
if (ptr < ptr_end) {  /* "ptr is before ptr_end in memory" */
    /* ... */
}

/* ❌ Undefined Behavior: Pointer outside array bounds */
int *out_of_bounds = ptr + 100;  /* Accessing invalid memory */
printf("%d\n", *out_of_bounds);  /* ← UB, could crash */
```

---

### 3.2 void Pointer & Type Casting

**void\*: Generic pointer (bất kỳ loại nào)**

```c
/* void* là con trỏ generic, không biết loại dữ liệu nó trỏ tới */

int x = 42;
float f = 3.14;
char c = 'A';

void *generic_ptr;

generic_ptr = &x;      /* ✓ void* có thể nhận int* */
generic_ptr = &f;      /* ✓ void* có thể nhận float* */
generic_ptr = &c;      /* ✓ void* có thể nhận char* */

/* Nhưng không thể dereference trực tiếp */
int val = *generic_ptr;  /* ❌ Compiler error: unknown size */

/* Phải cast về loại cụ thể */
val = *(int*)generic_ptr;      /* ✓ Cast tới int*, dereference */
printf("Value: %d\n", val);    /* Output: 42 */
```

**Ứng dụng: Callback data parameter (generic data passing)**

```c
/* Mục tiêu: Function callback cần truyền data loại bất kỳ */

typedef void (*CallbackFunc)(void *data);  /* void* = generic data */

/* Callback handler #1: dùng int data */
void handle_int_event(void *data) {
    int *value = (int*)data;  /* Cast về int* */
    printf("Int value: %d\n", *value);
}

/* Callback handler #2: dùng float data */
void handle_float_event(void *data) {
    float *value = (float*)data;  /* Cast về float* */
    printf("Float value: %.2f\n", *value);
}

/* Generic event register function */
void register_event(CallbackFunc cb, void *user_data) {
    /* Store cb + user_data, invoke later */
    cb(user_data);  /* Call callback với generic data */
}

void example(void) {
    int event_data = 123;
    register_event(handle_int_event, &event_data);  /* Pass int as void* */
    
    float event_data2 = 4.56;
    register_event(handle_float_event, &event_data2);  /* Pass float as void* */
}

/* Lợi ích:
   - Callback function generic, không cần biết loại data
   - Caller quyết định loại data
   - Flexible API
*/
```

**Safe casting practice:**

```c
/* ❌ Casting không an toàn: char* → int* */
char buffer[] = "hello";
int *bad_cast = (int*)buffer;  /* Undefined Behavior nếu access */

/* ✓ Casting an toàn: kiểm tra alignment + size */
typedef struct {
    uint32_t magic;  /* 0xDEADBEEF */
    uint32_t size;
} Header;

uint8_t *raw_buffer = malloc(sizeof(Header) + 1024);
Header *hdr = (Header*)raw_buffer;  /* Cast OK nếu buffer align tới 4B */

if (hdr->magic == 0xDEADBEEF) {
    /* ... */
}
free(raw_buffer);
```

---

### 3.3 Pointer Hàm (Function Pointers) & Callback System

**Định nghĩa: Con trỏ tới địa chỉ code của hàm**

```c
/* Bình thường: gọi hàm trực tiếp */
int add(int a, int b) {
    return a + b;
}

int result = add(5, 3);  /* Trực tiếp call */

/* Dùng function pointer: gọi gián tiếp */
int (*fp)(int, int) = &add;  /* fp = địa chỉ hàm add */
result = fp(5, 3);           /* Gọi qua pointer */
result = (*fp)(5, 3);        /* Tương đương (dereference explicit) */

/* Mnemonic: đọc từ trong ra ngoài
   int (*fp)(int, int)
   ^   ^  ^           
   |   |  parameter types
   |   function pointer
   return type
*/
```

**Ứng dụng #1: Callback system (ISR, event handler)**

```c
/* GPIO interrupt callback pattern */

typedef void (*GPIO_Callback)(uint32_t pin);  /* Callback type */

static GPIO_Callback gpio_callbacks[16] = {NULL};

/* Register callback cho pin */
void gpio_register_callback(uint32_t pin, GPIO_Callback cb) {
    gpio_callbacks[pin] = cb;
}

/* ISR: gọi registered callback */
void EXTI_IRQHandler(void) {  /* External interrupt handler */
    for (uint32_t pin = 0; pin < 16; pin++) {
        if (check_interrupt(pin)) {
            if (gpio_callbacks[pin] != NULL) {
                gpio_callbacks[pin](pin);  /* Call user's callback */
            }
        }
    }
}

/* Application: register callback */
void on_button_pressed(uint32_t pin) {
    printf("Button pressed on pin %u\n", pin);
    toggle_led();
}

void main(void) {
    gpio_register_callback(5, on_button_pressed);  /* Register */
    /* ISR sẽ gọi on_button_pressed khi pin 5 interrupt */
}
```

**Ứng dụng #2: State Machine callback table**

```c
typedef enum {
    STATE_IDLE,
    STATE_ACTIVE,
    STATE_ERROR,
} State;

typedef void (*StateHandler)(void);

StateHandler state_table[] = {
    [STATE_IDLE]   = handle_idle,
    [STATE_ACTIVE] = handle_active,
    [STATE_ERROR]  = handle_error,
};

static State current_state = STATE_IDLE;

void handle_event(int event) {
    switch (event) {
        case EVENT_START:
            current_state = STATE_ACTIVE;
            break;
        case EVENT_STOP:
            current_state = STATE_IDLE;
            break;
        case EVENT_FAULT:
            current_state = STATE_ERROR;
            break;
    }
    
    /* Dispatch tới state handler thông qua callback table */
    state_table[current_state]();  /* Call appropriate handler */
}

void handle_idle(void) {
    printf("System idle\n");
}

void handle_active(void) {
    printf("System active\n");
}

void handle_error(void) {
    printf("System error\n");
}
```

**Ứng dụng #3: Polymorphism giả trong C (Virtual function table)**

```c
/* Abstract interface */
typedef struct {
    void (*init)(void *self);
    void (*run)(void *self);
    void (*cleanup)(void *self);
} VirtualTable;

typedef struct {
    VirtualTable *vtable;  /* Pointer tới vtable */
    uint32_t config;
} Device;

/* Concrete implementation 1 */
void uart_init(void *self) {
    printf("UART init\n");
}

void uart_run(void *self) {
    printf("UART running\n");
}

void uart_cleanup(void *self) {
    printf("UART cleanup\n");
}

VirtualTable uart_vtable = {
    .init = uart_init,
    .run = uart_run,
    .cleanup = uart_cleanup,
};

/* Concrete implementation 2 */
void spi_init(void *self) {
    printf("SPI init\n");
}

void spi_run(void *self) {
    printf("SPI running\n");
}

void spi_cleanup(void *self) {
    printf("SPI cleanup\n");
}

VirtualTable spi_vtable = {
    .init = spi_init,
    .run = spi_run,
    .cleanup = spi_cleanup,
};

/* Generic device interface */
void device_init(Device *dev) {
    dev->vtable->init(dev);  /* Call virtual init */
}

void device_run(Device *dev) {
    dev->vtable->run(dev);   /* Call virtual run */
}

void device_cleanup(Device *dev) {
    dev->vtable->cleanup(dev);  /* Call virtual cleanup */
}

void main(void) {
    Device uart = {.vtable = &uart_vtable};
    Device spi = {.vtable = &spi_vtable};
    
    device_init(&uart);      /* Gọi uart_init */
    device_init(&spi);       /* Gọi spi_init */
    
    device_run(&uart);       /* Gọi uart_run */
    device_run(&spi);        /* Gọi spi_run */
}

/* Điểm: Tương tự C++ virtual function, nhưng dùng function pointer table */
```

---

### 3.4 Alignment & Structure Padding

**Memory Alignment: CPU fetch dữ liệu hiệu quả từ địa chỉ align**

```c
/* Bộ 32-bit ARM thích dữ liệu align tới 4 bytes:
   - Địa chỉ 0x20000000 (chia hết 4): ✓ aligned
   - Địa chỉ 0x20000001 (lẻ 1): ⚠ unaligned (penalty, crash, hoặc UB)
*/

/* CPU alignment requirement */
typedef struct {
    uint8_t byte;           /* 1 byte: 0x20000000 */
    /* Padding (3 bytes)  : 0x20000001-0x20000003 (compiler tự thêm) */
    uint32_t word;          /* 4 bytes: 0x20000004 (aligned tới 4) */
} AlignedStruct;

printf("sizeof(AlignedStruct) = %zu\n", sizeof(AlignedStruct));
/* Output: 8 (not 5!) */

/* Memory layout:
   0x20000000: [byte]
   0x20000001: [padding]
   0x20000002: [padding]
   0x20000003: [padding]
   0x20000004: [word..........] (4 bytes)
*/

/* Tại sao compiler tự thêm padding?
   - ARM32 fetch 4 bytes cùng lúc từ địa chỉ align 4
   - Nếu uint32_t lưu ở 0x20000001 (unaligned):
     * Cần 2 lần fetch (0x20000000 + 0x20000004)
     * Phải shift bits để extract (chậm)
     * Hoặc crash (architecture-dependent)
   - Padding → align → 1 lần fetch (nhanh) ✓
*/
```

**Tính toán sizeof và alignment:**

```c
typedef struct {
    uint8_t a;          /* 1 byte */
    uint32_t b;         /* 4 bytes, align 4 → padding 3 bytes */
    uint16_t c;         /* 2 bytes, align 2 → no padding (0x20000008 chia hết 2) */
    uint8_t d;          /* 1 byte */
    /* Padding 3 bytes để struct align 4 (largest member: 4) */
} TestStruct;

printf("sizeof(TestStruct) = %zu\n", sizeof(TestStruct));
/* Calculation:
   a: 1 byte @ 0x00
   padding: 3 bytes @ 0x01-0x03
   b: 4 bytes @ 0x04
   c: 2 bytes @ 0x08
   d: 1 byte @ 0x0A
   padding: 2 bytes @ 0x0B-0x0C (struct total align 4)
   Total: 12 bytes (not 1+4+2+1=8)
*/

/* Kiểm chứng offset */
TestStruct ts;
printf("offsetof(a) = %zu\n", offsetof(TestStruct, a));  /* 0 */
printf("offsetof(b) = %zu\n", offsetof(TestStruct, b));  /* 4 */
printf("offsetof(c) = %zu\n", offsetof(TestStruct, c));  /* 8 */
printf("offsetof(d) = %zu\n", offsetof(TestStruct, d));  /* 10 */
```

**Bit-fields: Compact struct, nhưng cẩn thận**

```c
/* ❌ Bit-field có vấn đề endianness + portability */
typedef struct {
    unsigned int a : 1;   /* 1 bit */
    unsigned int b : 3;   /* 3 bits */
    unsigned int c : 4;   /* 4 bits */
} BitFieldStruct;          /* Total: 1 byte (hay 4 bytes?) architecture-dependent! */

printf("sizeof(BitFieldStruct) = %zu\n", sizeof(BitFieldStruct));
/* Output: 4 (not 1!) - compiler padding để align */

/* ✓ Ổn định hơn: bit masking thay vì bit-field */
typedef struct {
    uint32_t flags;  /* 32 bits, explicitly */
} SafeFlags;

#define FLAG_A(flags)  ((flags) & (1U << 0))
#define FLAG_B(flags)  ((flags) & (1U << 1))
#define SET_FLAG_A(flags)  ((flags) |= (1U << 0))
#define CLEAR_FLAG_A(flags) ((flags) &= ~(1U << 0))

SafeFlags sf = {0};
SET_FLAG_A(sf.flags);
if (FLAG_A(sf.flags)) {
    /* ... */
}
```

**MMIO register mapping dùng struct + packed:**

```c
/* GPIOA register definition (STM32) */
typedef struct {
    volatile uint32_t MODER;     /* 0x00 */
    volatile uint32_t OTYPER;    /* 0x04 */
    volatile uint32_t OSPEEDR;   /* 0x08 */
    volatile uint32_t PUPDR;     /* 0x0C */
    volatile uint32_t IDR;       /* 0x10 */
    volatile uint32_t ODR;       /* 0x14 */
} __attribute__((packed)) GPIO_TypeDef;

/* Hoặc: #pragma pack(1)
   typedef struct {
       volatile uint32_t MODER;
       ...
   } GPIO_TypeDef;
   #pragma pack()
*/

#define GPIOA ((GPIO_TypeDef*)0x40020000)

void gpio_example(void) {
    GPIOA->MODER = 0x00004000;   /* Set pin 7 mode = output (01b << 14) */
    GPIOA->ODR = (1 << 7);       /* Set pin 7 output = high */
    
    uint32_t state = GPIOA->IDR;  /* Read input data */
}

/* __attribute__((packed)):
   - GCC: không thêm padding
   - sizeof(GPIO_TypeDef) = 24 (6 * 4 bytes, no padding)
   - Đảm bảo offset chính xác = register datasheet
*/

/* ⚠️ Trade-off:
   - Lợi: Offset chính xác theo hardware register
   - Hại: Unaligned access (slow, hoặc UB nếu CPU không support)
   - Giải pháp: ARM support unaligned MMIO, nhưng check datasheet
*/
```

---

## 4. THAO TÁC BIT (BITWISE OPERATIONS) & THIẾT KẾ DRIVER

### 4.1 Bitwise Operators & Masking Technique

**Các toán tử:**

```c
uint8_t a = 0b10101100;  /* 0xAC */
uint8_t b = 0b11110000;  /* 0xF0 */

/* AND: &
   Kết quả = 1 chỉ khi cả 2 bit = 1
*/
uint8_t and_result = a & b;
printf("a & b = 0b%s\n", uint8_to_binary(and_result));
/* 10101100 & 11110000 = 10100000 (0xA0) */

/* OR: |
   Kết quả = 1 nếu ít nhất 1 bit = 1
*/
uint8_t or_result = a | b;
printf("a | b = 0b%s\n", uint8_to_binary(or_result));
/* 10101100 | 11110000 = 11111100 (0xFC) */

/* XOR: ^
   Kết quả = 1 nếu 2 bit khác nhau
*/
uint8_t xor_result = a ^ b;
printf("a ^ b = 0b%s\n", uint8_to_binary(xor_result));
/* 10101100 ^ 11110000 = 01011100 (0x5C) */

/* NOT: ~
   Kết quả = đảo bit
*/
uint8_t not_result = ~a;
printf("~a = 0b%s\n", uint8_to_binary(not_result));
/* ~10101100 = 01010011 (0x53) */

/* Shift Left: <<
   Dịch bit sang trái n vị trí (* 2^n)
*/
uint8_t shl_result = a << 2;  /* 10101100 << 2 = 10110100 (0xB0) */

/* Shift Right: >>
   Dịch bit sang phải n vị trí (/ 2^n)
   Arithmetic shift (sign extension) vs Logical shift
*/
uint8_t shr_result = a >> 2;  /* 10101100 >> 2 = 00101011 (0x2B) */
```

**Bit Masking Techniques (thiết yếu cho driver):**

```c
/* Pattern #1: Set bit n thành 1 */
#define SET_BIT(value, n) ((value) |= (1U << (n)))

uint32_t reg = 0x00000000;
SET_BIT(reg, 5);  /* reg |= (1 << 5) = 0x00000020 */
/* reg = 0b00000000000000000000000000100000 */

/* Pattern #2: Clear bit n (thành 0) */
#define CLEAR_BIT(value, n) ((value) &= ~(1U << (n)))

reg = 0xFFFFFFFF;
CLEAR_BIT(reg, 5);  /* reg &= ~(1 << 5) = 0xFFFFFFDF */
/* reg = 0b11111111111111111111111111011111 */

/* Pattern #3: Toggle bit n */
#define TOGGLE_BIT(value, n) ((value) ^= (1U << (n)))

reg = 0x00000000;
TOGGLE_BIT(reg, 5);  /* reg ^= (1 << 5) → reg = 0x00000020 */
TOGGLE_BIT(reg, 5);  /* reg ^= (1 << 5) → reg = 0x00000000 */

/* Pattern #4: Read bit n */
#define READ_BIT(value, n) (((value) >> (n)) & 1U)

reg = 0b00000000000000000000000000100000;
if (READ_BIT(reg, 5)) printf("Bit 5 = 1\n");  /* true */
if (READ_BIT(reg, 4)) printf("Bit 4 = 1\n");  /* false */

/* Pattern #5: Set multiple bits (mask) thành pattern */
#define WRITE_MASK(value, mask, pattern) \
    ((value) = ((value) & ~(mask)) | ((pattern) & (mask)))

reg = 0xFFFFFFFF;
/* Clear bits 7-4 (mask = 0xF0), set tới pattern 0b0101 = 0x50 */
WRITE_MASK(reg, 0xF0, 0x50);
/* reg = (reg & ~0xF0) | (0x50 & 0xF0) = 0xFFFFFF5F */
```

**Ứng dụng thực tế: STM32 GPIO configuration**

```c
/* STM32 GPIO Port Mode Register (MODER)
   - Bit [2n+1:2n] = mode của pin n
   - 00 = Input
   - 01 = General Purpose Output
   - 10 = Alternate Function
   - 11 = Analog
*/

void gpio_set_pin_mode(GPIO_TypeDef *port, uint32_t pin, uint32_t mode) {
    /* Mask: 2 bits cho pin này */
    uint32_t mask = 0x3U << (2 * pin);
    
    /* Pattern: mode value shifted tới position */
    uint32_t pattern = mode << (2 * pin);
    
    /* Write mode */
    port->MODER = (port->MODER & ~mask) | pattern;
    
    /* Tương đương:
       port->MODER &= ~(0x3 << (2 * pin));     // Clear 2 bits
       port->MODER |=  (mode << (2 * pin));    // Set new mode
    */
}

void gpio_setup_example(void) {
    /* Set pin 5 = Output (mode 01b = 1) */
    gpio_set_pin_mode(GPIOA, 5, 0x1);
    
    /* Set pin 7 = Alternate Function (mode 10b = 2) */
    gpio_set_pin_mode(GPIOA, 7, 0x2);
}

/* ✓ Lợi ích:
   - Rõ ràng: đặt tên mask/pattern tránh nhầm lẫn
   - Atomic: 1 RMW (Read-Modify-Write) operation
   - Không ảnh hưởng pin khác
*/
```

---

### 4.2 Bit-field trong Struct & Endianness

**Bit-field cơ bản:**

```c
/* Compact bit storage trong struct */
typedef struct {
    unsigned int enable : 1;      /* 1 bit, bit 0 */
    unsigned int mode   : 2;      /* 2 bits, bit 1-2 */
    unsigned int priority : 3;    /* 3 bits, bit 3-5 */
    /* compiler padding: 2 bits (bit 6-7) để align byte */
} ControlReg;  /* sizeof = 1 byte */

ControlReg ctrl = {0};
ctrl.enable = 1;      /* Set bit 0 */
ctrl.mode = 3;        /* Set bits 1-2 = 11b */
ctrl.priority = 5;    /* Set bits 3-5 = 101b */

printf("Value: 0x%02x\n", *(uint8_t*)&ctrl);
/* Output: 0x3D (tính toán: enable=1, mode=11b, priority=101b) */
```

**Vấn đề: Endianness & Portability**

```c
/* ❌ Bit-field không portable! */
typedef struct {
    unsigned int a : 1;
    unsigned int b : 1;
    unsigned int c : 1;
} BitField;

/* Little Endian (Intel x86, ARM):
   a = bit 0, b = bit 1, c = bit 2
*/

/* Big Endian (MIPS, PowerPC):
   a = bit 7, b = bit 6, c = bit 5 (reversed!)
*/

/* Kết quả: Cùng code, khác kết quả trên big-endian architecture */

/* ✓ Giải pháp: Dùng bit masking thay vì bit-field */
typedef struct {
    uint8_t value;
} ControlReg;

#define CTRL_A_POS 0
#define CTRL_B_POS 1
#define CTRL_C_POS 2

void ctrl_set_a(ControlReg *reg, int val) {
    if (val) {
        reg->value |= (1U << CTRL_A_POS);
    } else {
        reg->value &= ~(1U << CTRL_A_POS);
    }
}

int ctrl_get_a(ControlReg *reg) {
    return (reg->value >> CTRL_A_POS) & 1U;
}

/* Portable, explicit endianness handling */
```

**Endianness & Multi-byte Register:**

```c
/* Register mapping phải match hardware layout (từ datasheet) */

/* Little Endian (STM32, ARM):
   Hardware register: [B3][B2][B1][B0] ← byte addresses
   Bit numbering: [31..24][23..16][15..8][7..0]
*/

typedef struct {
    volatile uint32_t reg;
} HardwareReg;

void register_example(HardwareReg *hw) {
    /* Set bit 5 */
    hw->reg |= (1U << 5);  /* ✓ Correct for little-endian */
    
    /* Get bits [3:0] */
    uint32_t nibble = hw->reg & 0x0F;  /* ✓ Correct */
}

/* Big Endian (hypothetical):
   Hardware register: [B0][B1][B2][B3] ← byte addresses reversed
   Bit numbering: [7..0][15..8][23..16][31..24] (confusing!)
   
   Same code sẽ sai! Cần bswap hoặc remap register layout.
*/
```

---

## 5. CẤU TRÚC DỮ LIỆU CỐT LÕI CHO EMBEDDED & FREERTOS

### 5.1 Circular Buffer (Ring Buffer)

**Mục đích: FIFO buffer có kích thước cố định, tái sử dụng bộ nhớ**

```c
/* Typical use case: UART RX buffer
   ISR put data, main loop get data
   Không thể dùng malloc (no heap in bare-metal)
*/

#define CBUF_SIZE 256

typedef struct {
    uint8_t buffer[CBUF_SIZE];
    uint32_t head;  /* Write pointer */
    uint32_t tail;  /* Read pointer */
    uint32_t count; /* Current data count (tuỳ chọn, để optimization) */
} CircularBuffer;

CircularBuffer uart_rx_buffer = {0};

/* Add element (ISR context) */
void cbuf_put(CircularBuffer *cbuf, uint8_t data) {
    if (cbuf->count >= CBUF_SIZE) {
        /* Buffer full, drop data (hoặc overwrite oldest) */
        return;
    }
    
    cbuf->buffer[cbuf->head] = data;
    cbuf->head = (cbuf->head + 1) % CBUF_SIZE;  /* Wrap around */
    cbuf->count++;
}

/* Get element (main context) */
uint8_t cbuf_get(CircularBuffer *cbuf) {
    if (cbuf->count == 0) {
        return 0;  /* Empty */
    }
    
    uint8_t data = cbuf->buffer[cbuf->tail];
    cbuf->tail = (cbuf->tail + 1) % CBUF_SIZE;  /* Wrap around */
    cbuf->count--;
    
    return data;
}

/* Check empty/full */
int cbuf_is_empty(CircularBuffer *cbuf) {
    return cbuf->count == 0;
}

int cbuf_is_full(CircularBuffer *cbuf) {
    return cbuf->count >= CBUF_SIZE;
}

/* UART ISR */
void UART_IRQHandler(void) {
    uint8_t ch = UART->DR;  /* Receive data register */
    cbuf_put(&uart_rx_buffer, ch);
}

/* Main loop */
void main(void) {
    while (1) {
        if (!cbuf_is_empty(&uart_rx_buffer)) {
            uint8_t ch = cbuf_get(&uart_rx_buffer);
            process_byte(ch);
        }
    }
}

/* Memory layout visualization:
   head = 2, tail = 0, count = 2
   
   ┌─────────────────────────────┐
   │ [0]=[1]=[2]=[3]=[4]=...     │ buffer
   │  T   T   H   -   -          │ (T=tail, H=head, -=empty)
   └─────────────────────────────┘
   
   After put 'D':
   head = 3, tail = 0, count = 3
   
   ┌─────────────────────────────┐
   │ [0]=[1]=[2]=[3]=[4]=...     │ buffer
   │  T   T   -   H   -          │
   └─────────────────────────────┘
   
   After get (tail advance):
   head = 3, tail = 1, count = 2
   
   ┌─────────────────────────────┐
   │ [0]=[1]=[2]=[3]=[4]=...     │ buffer
   │  -   T   -   H   -          │
   └─────────────────────────────┘
*/

/* ⚠️ Race condition: ISR modify head, main modify tail simultaneously
   Giải pháp: dùng FreeRTOS queue thay vì thủ công circular buffer
   FreeRTOS queue đã handle synchronization
*/
```

---

### 5.2 Linked List (Single & Double)

**Singly Linked List:**

```c
typedef struct Node {
    int data;
    struct Node *next;  /* Self-referential pointer */
} Node;

/* Create node */
Node* create_node(int data) {
    static Node nodes[10];  /* Static pool (not malloc) */
    static int node_count = 0;
    
    if (node_count >= 10) return NULL;
    
    nodes[node_count].data = data;
    nodes[node_count].next = NULL;
    
    return &nodes[node_count++];
}

/* Insert at head */
Node* insert_head(Node *head, int data) {
    Node *new_node = create_node(data);
    if (!new_node) return head;
    
    new_node->next = head;  /* Point to old head */
    return new_node;        /* Return new head */
}

/* Find node by data */
Node* find_node(Node *head, int data) {
    Node *current = head;
    while (current != NULL) {
        if (current->data == data) return current;
        current = current->next;
    }
    return NULL;  /* Not found */
}

/* Delete node by data */
Node* delete_node(Node *head, int data) {
    if (head == NULL) return NULL;
    
    /* Delete head */
    if (head->data == data) {
        return head->next;
    }
    
    /* Delete middle/tail */
    Node *current = head;
    while (current->next != NULL) {
        if (current->next->data == data) {
            current->next = current->next->next;  /* Bypass deleted node */
            return head;
        }
        current = current->next;
    }
    
    return head;  /* Not found */
}

/* Traverse */
void print_list(Node *head) {
    Node *current = head;
    while (current != NULL) {
        printf("%d -> ", current->data);
        current = current->next;
    }
    printf("NULL\n");
}

void linked_list_example(void) {
    Node *head = NULL;
    
    head = insert_head(head, 1);
    head = insert_head(head, 2);
    head = insert_head(head, 3);
    
    print_list(head);  /* Output: 3 -> 2 -> 1 -> NULL */
    
    head = delete_node(head, 2);
    print_list(head);  /* Output: 3 -> 1 -> NULL */
}

/* Diagram:
   head → [3] → [2] → [1] → NULL
           ↑     ↑     ↑
         data  next  next
*/
```

**Doubly Linked List (2-way traversal):**

```c
typedef struct DNode {
    int data;
    struct DNode *next;
    struct DNode *prev;
} DNode;

DNode* dlist_create_node(int data) {
    static DNode nodes[10];
    static int count = 0;
    if (count >= 10) return NULL;
    nodes[count].data = data;
    nodes[count].next = NULL;
    nodes[count].prev = NULL;
    return &nodes[count++];
}

DNode* dlist_insert_after(DNode *node, int data) {
    DNode *new_node = dlist_create_node(data);
    if (!new_node) return NULL;
    
    new_node->next = node->next;
    new_node->prev = node;
    
    if (node->next) node->next->prev = new_node;
    node->next = new_node;
    
    return new_node;
}

void dlist_traverse_forward(DNode *head) {
    DNode *current = head;
    while (current) {
        printf("%d ↔ ", current->data);
        current = current->next;
    }
    printf("NULL\n");
}

void dlist_traverse_backward(DNode *tail) {
    DNode *current = tail;
    while (current) {
        printf("%d ↔ ", current->data);
        current = current->prev;
    }
    printf("NULL\n");
}

/* Diagram:
   NULL ← [1] ↔ [2] ↔ [3] → NULL
            ↑     ↑     ↑
          prev  next  prev/next
*/
```

---

### 5.3 Bitmask Event Flags (FreeRTOS-style)

**Quản lý sự kiện dùng bitmask (thay vì queue):**

```c
typedef uint32_t EventFlags;

#define EVENT_FLAG_BUTTON_PRESSED  (1U << 0)
#define EVENT_FLAG_TIMER_EXPIRED   (1U << 1)
#define EVENT_FLAG_UART_DATA_READY (1U << 2)
#define EVENT_FLAG_ERROR           (1U << 3)

static volatile EventFlags event_flags = 0;

/* Set event flag (từ ISR hoặc other task) */
void set_event_flag(EventFlags flag) {
    event_flags |= flag;  /* atomic, if compiler generate ldrex/strex */
}

/* Clear event flag */
void clear_event_flag(EventFlags flag) {
    event_flags &= ~flag;
}

/* Check event flag */
int is_flag_set(EventFlags flag) {
    return (event_flags & flag) != 0;
}

/* Wait for ANY flag (polling) */
void wait_any_flag_polling(EventFlags mask) {
    while ((event_flags & mask) == 0) {
        /* Spin until any flag set */
    }
}

/* Handle multiple events */
void event_loop(void) {
    while (1) {
        EventFlags current = event_flags;  /* Snapshot */
        
        if (current & EVENT_FLAG_BUTTON_PRESSED) {
            handle_button();
            clear_event_flag(EVENT_FLAG_BUTTON_PRESSED);
        }
        
        if (current & EVENT_FLAG_TIMER_EXPIRED) {
            handle_timer();
            clear_event_flag(EVENT_FLAG_TIMER_EXPIRED);
        }
        
        if (current & EVENT_FLAG_UART_DATA_READY) {
            handle_uart();
            clear_event_flag(EVENT_FLAG_UART_DATA_READY);
        }
    }
}

/* ISR */
void GPIO_IRQHandler(void) {
    set_event_flag(EVENT_FLAG_BUTTON_PRESSED);
}

void UART_IRQHandler(void) {
    set_event_flag(EVENT_FLAG_UART_DATA_READY);
}

void Timer_IRQHandler(void) {
    set_event_flag(EVENT_FLAG_TIMER_EXPIRED);
}

/* ⚠️ Race condition: event_flags read by main, write by ISR
   Giải pháp: FreeRTOS EventGroup (atomic flag operations) hoặc dùng queue
*/
```

**Improved: FreeRTOS EventGroup (an toàn hơn):**

```c
/* FreeRTOS có sẵn xử lý race condition */
#include "FreeRTOS.h"
#include "event_groups.h"

EventGroupHandle_t event_group = xEventGroupCreate();

#define BUTTON_EVENT    (1 << 0)
#define TIMER_EVENT     (1 << 1)
#define UART_EVENT      (1 << 2)

void freertos_task(void *param) {
    EventBits_t uxBits;
    
    while (1) {
        /* Wait for ANY event (blocking, efficient) */
        uxBits = xEventGroupWaitBits(
            event_group,
            BUTTON_EVENT | TIMER_EVENT | UART_EVENT,
            pdTRUE,           /* Clear bits after wait */
            pdFALSE,          /* OR, not AND */
            portMAX_DELAY     /* Wait forever */
        );
        
        if (uxBits & BUTTON_EVENT) {
            handle_button();
        }
        if (uxBits & TIMER_EVENT) {
            handle_timer();
        }
        if (uxBits & UART_EVENT) {
            handle_uart();
        }
    }
}

void isr_from_button(void) {
    xEventGroupSetBitsFromISR(event_group, BUTTON_EVENT, NULL);
}

/* ✓ FreeRTOS xEventGroupSetBitsFromISR() đã handle:
   - Atomic operation (no race)
   - ISR-safe (no task switch in ISR)
   - Efficient wakeup (task unblock ngay)
*/
```

---

## 6. LẬP TRÌNH BẢO VỆ & AN TOÀN BỘ NHỚ (DEFENSIVE C)

### 6.1 Undefined Behavior (UB) Thường Gặp

**#1: Buffer Overflow**

```c
/* ❌ UB: Ghi vượt ranh giới buffer */
char buffer[10];
strcpy(buffer, "This is a very long string");  /* Writes beyond buffer! */
/* Cách này là UB, có thể crash, hoặc overwrite stack variables */

/* ✓ Safe: dùng strncpy với kích thước */
char buffer[10];
strncpy(buffer, "This is a very long string", sizeof(buffer) - 1);
buffer[sizeof(buffer) - 1] = '\0';  /* Null-terminate */
```

**#2: Dangling Pointer**

```c
int* bad_pointer(void) {
    int local = 42;
    return &local;  /* ❌ UB: local variable destroyed on return */
}

void call_bad_pointer(void) {
    int *ptr = bad_pointer();
    printf("%d\n", *ptr);  /* ❌ UB: ptr points to destroyed stack */
}

/* ✓ Fix: return static/global, or allocate properly */
int* good_pointer(void) {
    static int local = 42;  /* Static: lasts entire program */
    return &local;
}
```

**#3: Integer Overflow**

```c
/* ❌ UB: Signed integer overflow */
int x = INT_MAX;  /* 0x7FFFFFFF */
int y = x + 1;    /* ❌ UB: Signed overflow is undefined */

/* ✓ Use unsigned for bitwise operations */
uint32_t ux = 0xFFFFFFFF;
uint32_t uy = ux + 1;  /* 0, well-defined (wraps around) */

/* ✓ Check before arithmetic */
if (x > INT_MAX - 1) {
    /* Overflow would occur */
} else {
    y = x + 1;  /* Safe */
}
```

**#4: Use-After-Free (heap)**

```c
/* ❌ UB: malloc then free, then use */
int *ptr = malloc(sizeof(int));
*ptr = 42;
free(ptr);
printf("%d\n", *ptr);  /* ❌ UB: Use-after-free */

/* ✓ Set to NULL after free (defensive) */
free(ptr);
ptr = NULL;

if (ptr != NULL) {
    printf("%d\n", *ptr);
}
```

**#5: Unaligned Memory Access**

```c
/* ❌ UB on some architectures: Unaligned access */
uint8_t buffer[5] = {1, 2, 3, 4, 5};
uint32_t *ptr = (uint32_t*)&buffer[1];  /* Unaligned! */
uint32_t val = *ptr;  /* ❌ UB: Unaligned read (may crash on ARM strict) */

/* ✓ memcpy for safe unaligned access */
uint32_t val;
memcpy(&val, &buffer[1], sizeof(val));  /* Safe, compiler handles alignment */
```

**#6: Array Out of Bounds**

```c
/* ❌ UB: Access out of bounds */
int arr[10];
printf("%d\n", arr[20]);  /* ❌ UB: Accessing invalid memory */
arr[20] = 42;             /* ❌ UB: Writing to invalid memory */

/* ✓ Check bounds */
if (index < 10) {
    printf("%d\n", arr[index]);  /* Safe */
}
```

---

### 6.2 Ép Kiểu An Toàn & Kiểm Tra Con Trỏ

**Casting Guidelines:**

```c
/* ❌ Dangerous: Implicit cast, precision loss */
double d = 3.14159;
int i = d;  /* i = 3 (silently truncated) */

/* ✓ Explicit cast, with intention */
int i = (int)d;  /* Clear intent: truncate to int */

/* ❌ Dangerous: Casting between incompatible types */
float f = 3.14f;
int *ptr = (int*)&f;  /* ❌ UB: Treating float storage as int */

/* ✓ Safe: void* intermediary or memcpy */
void *generic_ptr = (void*)&f;
int *safe_ptr = (int*)generic_ptr;  /* Still technically UB, but pattern shows intent */

/* ✓ Correct: memcpy for type punning */
float f = 3.14f;
int bits;
memcpy(&bits, &f, sizeof(float));  /* Safe type reinterpretation */
```

**Pointer NULL Check Pattern:**

```c
/* ❌ No check: crashes if malloc fails */
int *arr = malloc(100);
arr[0] = 42;  /* ❌ If malloc returned NULL, crash here */

/* ✓ Always check malloc return */
int *arr = malloc(100);
if (arr == NULL) {
    fprintf(stderr, "Memory allocation failed\n");
    return -1;
}
arr[0] = 42;  /* Safe */
free(arr);
arr = NULL;  /* Good practice: avoid dangling pointer */

/* ✓ Macro for defensive NULL access */
#define SAFE_FREE(ptr) do { if ((ptr) != NULL) { free(ptr); (ptr) = NULL; } } while(0)

SAFE_FREE(arr);  /* Safe even if arr already NULL */
```

---

### 6.3 Macro vs Inline Function: Side Effects & Safety

**Macro Pitfalls:**

```c
/* ❌ Macro has side effects: parameter evaluation issue */
#define MAX(a, b) ((a) > (b) ? (a) : (b))

int x = 0;
int result = MAX(x++, 5);  /* x++ evaluated twice! */
/* result = ((x++) > (5) ? (x++) : 5)
   x becomes 2 (incremented in both ternary branches evaluating to true initially)
*/

/* ❌ Macro doesn't respect scope */
#define SWAP(a, b) { int temp = a; a = b; b = temp; }

SWAP(x, y);  /* temp might conflict with outer scope temp */

/* ❌ Macro doesn't type-check */
#define ADD(a, b) ((a) + (b))
ADD(ptr1, ptr2);  /* Compiler allows nonsense */

/* ✓ Inline function is safer */
static inline int max_int(int a, int b) {
    return (a > b) ? a : b;
}

result = max_int(x++, 5);  /* x++ evaluated exactly once ✓ */

/* ✓ Inline respects scope & type-checking */
```

**When to Use Macro (rare):**

```c
/* ✓ Macro for compile-time constants */
#define CONFIG_BUFFER_SIZE 256

/* ✓ Macro for token pasting */
#define REGISTER(name) REGISTER_##name

/* ✓ Macro for no-overhead flag operations */
#define SET_BIT(value, bit) ((value) |= (1U << (bit)))

/* Mnemonic:
   Use macro: compile-time, token manipulation, zero-overhead
   Use inline: runtime, type-safe, scope-safe
*/
```

---

### 6.4 Assertion & Defensive Programming

**assert() untuk development:**

```c
#include <assert.h>

void process_array(int *arr, int len) {
    assert(arr != NULL);     /* Fail fast if NULL pointer */
    assert(len > 0);         /* Fail if invalid length */
    assert(len < 1000);      /* Sanity check */
    
    for (int i = 0; i < len; i++) {
        process(arr[i]);
    }
}

/* assert() is removed in Release build (compiled out)
   - Development: Debug info, catches bugs early
   - Release: Zero overhead (assert disabled)
*/

/* ✓ Compile with -DNDEBUG để disable assert */
```

**Defensive coding in production:**

```c
/* ❌ Release code should NOT rely on assert */
void critical_function(int *ptr) {
    assert(ptr != NULL);  /* ❌ Removed in release, silently passes NULL */
}

/* ✓ Release code needs real error handling */
void critical_function_safe(int *ptr) {
    if (ptr == NULL) {
        return -1;  /* Return error, not silently assume */
    }
    return 0;
}

/* ✓ Hybrid: assert + runtime check */
void production_ready(int *ptr) {
    assert(ptr != NULL);  /* Catch bugs in debug */
    
    if (ptr == NULL) {    /* Protect against UB in release */
        return -1;
    }
    
    return 0;
}
```

---

## Tóm Tắt: 10 Nguyên Tắc Embedded C Cốt Lõi

1. **Memory Layout Matters:** Flash (code), RAM (data), Stack, Heap — hiểu phân bố bộ nhớ là nền tảng.
2. **volatile = No Optimization:** Dùng cho MMIO, ISR, shared variable giữa context khác nhau.
3. **const = Flash Storage:** Tiết kiệm RAM bằng cách đưa hằng số vào Flash.
4. **static = Encapsulation:** Giới hạn scope variable, đảm bảo persistence qua lần gọi.
5. **Pointers Power & Danger:** Callback, polymorphism, MMIO — nhưng cẩn thận dangling pointer, alignment.
6. **Bit Manipulation = Register Access:** AND/OR/XOR/SHIFT là ngôn ngữ hardware driver.
7. **No malloc in Bare-metal:** Static allocation + circular buffer + memory pool = safe.
8. **Struct Padding Implicit:** Compiler tự thêm padding để align → sizeof không bằng tổng field.
9. **Undefined Behavior Lurks:** Buffer overflow, race condition, uninitialized variable → tiềm ẩn mọi đâu.
10. **Defensive Programming:** Assert + NULL check + bounded access + explicit cast = robust code.

---

## Kết Nối Với ELDMP Roadmap

| Sprint ELDMP | Khái Niệm C Cần Master | Lý Do |
|---|---|---|
| Sprint 3 (Bare-metal MCU) | volatile, pointer, bitwise ops, memory layout | Truy cập thanh ghi MMIO trực tiếp |
| Sprint 4 (FreeRTOS) | static + volatile (ISR sync), queue data structure | Chia sẻ data giữa Task/ISR |
| Sprint 5 (LVGL GUI) | callback function pointer, struct + padding | LVGL event system dùng callback |
| Sprint 6 (Kernel Driver) | all of above + aligned access, alignment attribute | Writing Linux kernel module |
| Sprint 9 (IPC D-Bus) | void pointer, marshalling data | Serialize data qua D-Bus |
| Sprint 13 (Protocol) | CRC (bitwise), struct packing (alignment), endianness | Define wire protocol |

---

**END OF EMBEDDED C MASTERY GUIDE**
