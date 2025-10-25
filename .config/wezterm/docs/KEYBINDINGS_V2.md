```
MOD (Cmd/Alt)
├─ C/V          → 复制/粘贴
├─ +/-          → 字体大小
├─ R            → 重载
├─ F            → 搜索
├─ [/]          → 标签切换
└─ 1-9/0        → 标签跳转

LEADER (Ctrl+,) 🌊
├─ n/Enter      → 窗口管理
├─ c/x          → 标签创建/关闭
├─ h/v          → Pane 分割
├─ q/z/o/s      → Pane 操作
├─ [/f          → Copy/Quick Select
├─ p/Space      → 命令面板/启动器
├─ b/B          → 背景切换
└─ w            → Workspace 子模式 📦
   ├─ l → 列表
   ├─ c → 创建
   ├─ r → 重命名
   ├─ n → 下一个
   └─ p → 上一个
```

🌊 LEADER                    → Leader 激活
🌊 LEADER 📦 WORKSPACE       → Workspace 子模式
📋 COPY                      → Copy 模式
📁 myproject                 → 当前 Workspace



# WezTerm 快捷键速查表 V2

## 🎯 设计理念

### 三层架构

```
MOD Layer (Cmd/Alt)
├─ 系统操作: 复制/粘贴/字体/重载/标签切换
└─ 最常用操作，单键直达

LEADER Layer (Ctrl+,)
├─ WezTerm 操作: 窗口/标签/Pane
├─ 系统功能: 命令面板/启动器
└─ Workspace 子模式入口 (Ctrl+, w)

Workspace Sub-mode (嵌套模态)
├─ l: 列表
├─ c: 创建
├─ r: 重命名
├─ n: 下一个
└─ p: 上一个
```

### 状态栏指示器

```
🌊 LEADER    → Leader 模式已激活
📦 WORKSPACE → Workspace 子模式已激活
📋 COPY      → Copy 模式已激活
📁 <name>    → 当前 Workspace 名称
```

---

## 📋 快捷键清单

### MOD Layer (Cmd on Mac, Alt on Linux)

#### 系统操作

| 快捷键 | 功能 |
|--------|------|
| `Cmd+C` | 复制 |
| `Cmd+V` | 粘贴 |
| `Cmd+=` | 增大字体 |
| `Cmd+-` | 减小字体 |
| `Cmd+R` | 重载配置 |
| `Cmd+F` | 搜索 |
| `Cmd+PageUp/Down` | 滚动 |

#### 标签切换

| 快捷键 | 功能 |
|--------|------|
| `Cmd+[` / `Cmd+]` | 上一个/下一个标签 |
| `Cmd+Shift+←/→` | 上一个/下一个标签 |
| `Cmd+Shift+Ctrl+←/→` | 移动标签位置 |
| `Cmd+1~9` | 跳转到第 1-9 个标签 |
| `Cmd+0` | 跳转到最后一个标签 |

---

### LEADER Layer (Ctrl+,)

#### 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+, n` | 新建窗口 |
| `Ctrl+, Enter` | 全屏切换 |

#### 标签管理

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+, c` | 创建新标签 |
| `Ctrl+, x` | 关闭当前标签 |

#### Pane 管理

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+, h` | 垂直分割（左右） |
| `Ctrl+, v` | 水平分割（上下） |
| `Ctrl+, q` | 关闭当前 Pane |
| `Ctrl+, z` | Pane 缩放切换 |
| `Ctrl+, o` | 切换到下一个 Pane |
| `Ctrl+, s` | 交换 Pane |

#### 系统功能

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+, [` | 进入 Copy 模式 |
| `Ctrl+, f` | 快速选择 |
| `Ctrl+, p` | 命令面板 |
| `Ctrl+, Space` | 启动器 |
| `Ctrl+, b` | 下一张背景（可选） |
| `Ctrl+, Shift+B` | 上一张背景（可选） |

#### Workspace 子模式

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+, w` | 进入 Workspace 模式 |

---

### Workspace Sub-mode

**进入方式**: `Ctrl+, w`（状态栏显示 `📦 WORKSPACE`）

| 快捷键 | 功能 |
|--------|------|
| `l` | 列出所有 Workspace（模糊搜索） |
| `c` | 创建/切换 Workspace |
| `r` | 重命名当前 Workspace |
| `n` | 下一个 Workspace |
| `p` | 上一个 Workspace |
| `Escape` | 退出 Workspace 模式 |

**工作流示例**:

```
1. Ctrl+,    → 🌊 LEADER
2. w         → 📦 WORKSPACE
3. c         → 输入名称创建
4. Escape    → 退出
```

---

### Copy Mode (Vim-style)

**进入方式**: `Ctrl+, [`

#### 移动

| 快捷键 | 功能 |
|--------|------|
| `h/j/k/l` | 左/下/上/右 |
| `w/b/e` | 下一词/上一词/词尾 |
| `0/$` | 行首/行尾 |
| `g/G` | 顶部/底部 |
| `H/M/L` | 视口顶部/中间/底部 |
| `Ctrl+b/f` | 上翻页/下翻页 |
| `Ctrl+d/u` | 下翻半页/上翻半页 |

#### 选择与复制

| 快捷键 | 功能 |
|--------|------|
| `v` | 字符选择 |
| `V` | 行选择 |
| `Ctrl+v` | 块选择 |
| `y` | 复制 |
| `Enter` | 复制并退出 |

#### 搜索

| 快捷键 | 功能 |
|--------|------|
| `/` | 搜索 |
| `n` | 下一个匹配 |
| `N` | 上一个匹配 |

#### 退出

| 快捷键 | 功能 |
|--------|------|
| `q` / `Escape` / `Ctrl+C` | 退出 Copy 模式 |

---

## 🎨 设计亮点

### 1. ✅ 清晰的层次结构

- **MOD 层**: 系统级操作，跨应用一致
- **LEADER 层**: WezTerm 专属，功能丰富
- **子模式层**: 嵌套模态，避免冲突

### 2. ✅ 完整的状态显示

- `🌊 LEADER` - Leader 激活
- `📦 WORKSPACE` - Workspace 子模式
- `📋 COPY` - Copy 模式
- `📁 <name>` - 当前 Workspace

### 3. ✅ 语义一致的按键

- `c` = Create（创建标签/Workspace）
- `x` = Close（关闭标签）
- `q` = Quit（关闭 Pane）
- `h/v` = Horizontal/Vertical（分割）
- `n/p` = Next/Previous（切换）

### 4. ✅ Vim 风格的 Copy Mode

- 完整的 hjkl 导航
- w/b/e 词移动
- v/V 选择模式
- / 搜索功能

### 5. ✅ 嵌套模态系统

```
Ctrl+, → LEADER 模式
  └─ w → WORKSPACE 子模式
     ├─ l/c/r/n/p 操作
     └─ Escape 退出
```

---

## 🚀 常用工作流

### 创建新 Workspace

```
Ctrl+, w c
输入名称: myproject
Enter
```

### 切换 Workspace

```
Ctrl+, w l
模糊搜索选择
Enter
```

### 分割 Pane 并复制文本

```
Ctrl+, h      → 垂直分割
Ctrl+, [      → 进入 Copy 模式
/pattern      → 搜索
n             → 跳转
v             → 选择
y             → 复制
```

### 管理多个标签

```
Ctrl+, c      → 创建新标签
Cmd+1~9       → 快速跳转
Ctrl+, x      → 关闭标签
```

---

## 📊 快捷键统计

| 类别 | 数量 |
|------|------|
| MOD 层 | 22 个 |
| LEADER 层 | 17 个 |
| Workspace 子模式 | 5 个 |
| Copy 模式 | 30+ 个 |
| **总计** | **70+ 个** |

---

## 🎯 与旧版本对比

| 项目 | 旧版本 | 新版本 V2 |
|------|--------|-----------|
| Leader 显示 | ✅ 有 | ✅ 有 |
| Workspace 模式显示 | ❌ 无 | ✅ 有 |
| Tab 创建 | `Cmd+T` | `Ctrl+, c` |
| Tab 关闭 | `Cmd+W` | `Ctrl+, x` |
| Workspace 切换 | `Ctrl+, Shift+W` | `Ctrl+, w l` |
| 架构清晰度 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

---

## 💡 设计哲学

> "好的快捷键应该是直觉的、有层次的、可扩展的"

1. **MOD 层**专注于系统级操作，保持跨应用一致性
2. **LEADER 层**提供 WezTerm 专属功能，避免冲突
3. **子模式**通过嵌套实现功能分组，清晰直观
4. **状态显示**实时反馈当前模式，减少迷失
5. **Vim 兼容**Copy 模式完全遵循 Vim 习惯

---

**快捷键总评**: ⭐⭐⭐⭐⭐ (5/5) - 架构清晰，功能完整！
