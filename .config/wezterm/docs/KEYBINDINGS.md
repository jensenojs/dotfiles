# WezTerm 快捷键速查表

**版本**: 1.0  
**日期**: 2025-10-19  
**设计**: Leader 键系统 + 模态操作

---

## 🎯 快捷键设计理念

### Leader 键系统

**Leader 键**: `Ctrl+;`

- 按下后进入 Leader 模式（状态栏显示 🌊 LEADER）
- 2 秒内按下下一个键执行操作
- 超时或执行操作后自动退出 Leader 模式

**优势**:

- ✅ 避免快捷键冲突
- ✅ 更符合 Vim/Tmux 用户习惯
- ✅ 易于记忆（逻辑分组）

### MOD 键跨平台适配

| 平台 | MOD 键 |
|------|--------|
| macOS | `Cmd` |
| Linux | `Alt` |
| Windows | `Alt` |

**说明**: 文档中 `MOD` 表示跨平台修饰键

---

## 📋 快捷键总览

### 快速参考

| 类别 | 前缀 | 示例 | 功能说明 |
|------|------|------|----------|
| 系统操作 | `MOD+` | `MOD+R` 重载配置 | 基础系统功能 |
| Tab 操作 | `MOD+` | `MOD+T` 新建 Tab | 标签页管理 |
| Pane 操作 | `Leader+` | `Leader+h` 垂直分割 | 窗格分割 |
| 窗格调整 | `Leader+Shift+` | `Leader+Shift+h` | 调整窗格大小 |
| 窗格操作 | `Leader+` | `Leader+o` 切换窗格 | 窗格管理 |
| 窗格操作 | `Leader+` | `Leader+x` 关闭窗格 | 窗格管理 |
| 窗格操作 | `Leader+` | `Leader+z` 全屏窗格 | 窗格管理 |
| 窗格操作 | `Leader+` | `Leader+s` 交换窗格 | 窗格管理 |
| 命令面板 | `Leader+` | `Leader+p` 激活命令面板 | 命令面板 |
| 系统功能 | `Leader+` | `Leader+l` 调试覆盖层 | 系统功能 |
| 系统功能 | `Leader+` | `Leader+Space` 启动器 | 系统功能 |
| 工作区 | `Leader+` | `Leader+w` 切换工作区 | 工作区管理 |
| 工作区 | `Leader+` | `Leader+n` 下一工作区 | 工作区管理 |
| 工作区 | `Leader+Shift+` | `Leader+Shift+P` 上一工作区 | 工作区管理 |
| 工作区 | `Leader+` | `Leader+,` 重命名工作区 | 工作区管理 |
| 工作区 | `Leader+` | `Leader+c` 创建工作区 | 工作区管理 |
| 背景管理 | `Leader+` | `Leader+b` 下一张背景 | 背景管理 |
| 背景管理 | `Leader+Shift+` | `Leader+Shift+B` 上一张背景 | 背景管理 |
| 背景管理 | `Leader+Ctrl+` | `Leader+Ctrl+B` 随机背景 | 背景管理 |
| 复制模式 | `Leader+` | `Leader+[` 进入复制模式 | 复制模式 |
| 快速选择 | `Leader+` | `Leader+f` 快速选择 | 快速选择 |

---

## 🖥️ 系统操作

### 基础操作

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `MOD+N` | 新建窗口 | 新建独立窗口 |
| `MOD+Enter` | 切换全屏 | 全屏/恢复 |
| `MOD+R` | 重新加载配置 | 热重载配置文件 |
| `MOD+Shift+P` | 激活命令面板 | 通过 MOD 键快速调用 |
| `MOD+Shift+L` | 显示调试覆盖层 | 显示调试信息 |
| `MOD+Shift+Space` | 显示启动器 | 显示启动菜单 |

---

## 📑 Tab 操作

### Tab 管理

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `MOD+T` | 新建 Tab | 在当前目录创建 |
| `MOD+W` | 关闭当前 Tab | 确认后关闭 |
| `MOD+1~9` | 切换到 Tab 1-9 | 快速跳转 |
| `MOD+0` | 切换到最后一个 Tab | 跳转到末尾 |

### Tab 导航

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `MOD+[` | 上一个 Tab | 向左切换 |
| `MOD+]` | 下一个 Tab | 向右切换 |
| `MOD+Shift+Left/Right` | 切换 Tab | 方向键导航替代 |
| `MOD+Shift+Ctrl+Left/Right` | 移动 Tab 位置 | 调整 Tab 顺序 |

---

## 🔲 Pane 操作 (窗格分割)

### Pane 创建

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+h` | 垂直分割 | 左右分割（产生左右窗格） |
| `Leader+v` | 水平分割 | 上下分割（产生上下窗格） |
| `Leader+x` | 关闭当前 Pane | 确认后关闭 |

### Pane 导航 (已注释，避免冲突)

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+h` | (已禁用) 移动到左侧 Pane | 使用方向键导航 |
| `Leader+j` | (已禁用) 移动到下方 Pane | 使用方向键导航 |
| `Leader+k` | (已禁用) 移动到上方 Pane | 使用方向键导航 |
| `Leader+l` | (已禁用) 移动到右侧 Pane | 使用方向键导航 |
| `Leader+↑/↓/←/→` | 方向键导航 | 推荐的窗格导航方式 |

### Pane 调整大小

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+Shift+h` | 向左扩展 | 调整宽度 |
| `Leader+Shift+j` | 向下扩展 | 调整高度 |
| `Leader+Shift+k` | 向上扩展 | 调整高度 |
| `Leader+Shift+l` | 向右扩展 | 调整宽度 |

### Pane 操作

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+z` | 全屏/恢复当前 Pane | 切换 Zoom 状态 |
| `Leader+o` | 切换到下一个窗格 | 循环切换窗格 |
| `Leader+s` | 交换窗格 | 与活动窗格交换 |

---

## 🎯 命令面板与系统功能

### 系统功能

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+p` | 激活命令面板 | 显示命令面板 |
| `Leader+l` | 显示调试覆盖层 | 显示调试信息 |
| `Leader+Space` | 显示启动器 | 显示启动菜单 |

### 命令面板 (Leader+P) - 可用命令

- 🔄 Reload Configuration - 重载配置
- 👁️ Toggle Tab Bar - 显示/隐藏标签栏
- 🖼️ Toggle Opacity - 切换透明度
- ⬆️ Maximize Window - 最大化窗口
- 📋 Copy Mode - 进入复制模式

### 快速选择

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+f` | 快速选择 | 快速选择并执行操作 |

---

## 💼 Workspace 操作

### Workspace 管理

**使用嵌套模态：`Ctrl+, w` 进入 Workspace 子模式**

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Ctrl+, w l` | 列表 Workspace | 模糊搜索切换工作区列表 |
| `Ctrl+, w c` | 创建 Workspace | 输入名称创建/切换工作区 |
| `Ctrl+, w r` | 重命名 Workspace | 重命名当前工作区 |
| `Ctrl+, w n` | 下一个 Workspace | 切换到下一个工作区 |
| `Ctrl+, w p` | 上一个 Workspace | 切换到上一个工作区 |

**工作流示例**：
1. 按 `Ctrl+,` → 进入 Leader 模式
2. 按 `w` → 进入 Workspace 子模式
3. 按 `l/c/r/n/p` → 执行对应操作
4. 按 `Escape` → 退出模式

**Workspace 说明**:

- Workspace 是独立的 Tab 集合，类似 tmux 的 session
- 可以为不同项目创建不同 Workspace，完全隔离
- 状态栏显示当前 Workspace 名称（非 default 时）
- 使用嵌套模态避免快捷键冲突，更符合直觉

---

## 🖼️ 背景图片操作 (可选)

**注意**: 默认关闭，需在 `config/appearance.lua` 中启用

### 背景切换

| 快捷键 | 功能 | 说明 |
|--------|------|------|
| `Leader+b` | 下一张背景 | 顺序切换 |
| `Leader+Shift+b` | 上一张背景 | 反向切换 |
| `Leader+Ctrl+b` | 随机背景 | 随机选择 |

**启用方法**:

```lua
-- config/appearance.lua
local backdrops = require("utils.backdrops"):new({
   enabled = true,  -- 改为 true
   images_dir = wezterm.config_dir .. "/backdrops/",
   opacity = 0.90, -- 背景透明度 (0.0-1.0)
   blur = 0, -- 模糊程度 (0-100)，0=不模糊
})
```

然后在 `~/.config/wezterm/backdrops/` 放置图片即可。

---

## 📋 Copy Mode (复制模式)

### 进入 Copy Mode

| 快捷键 | 功能 |
|--------|------|
| `Leader+[` | 进入 Copy Mode |
| 命令面板 → 📋 Copy Mode | 通过命令面板进入 |

### Copy Mode 导航 (Vim 风格)

#### 基础移动

| 快捷键 | 功能 |
|--------|------|
| `h` | 左移 |
| `j` | 下移 |
| `k` | 上移 |
| `l` | 右移 |
| `↑/↓/←/→` | 方向键移动 |

#### 单词移动

| 快捷键 | 功能 |
|--------|------|
| `w` | 下一个单词开头 |
| `b` | 上一个单词开头 |
| `e` | 下一个单词结尾 |

#### 行移动

| 快捷键 | 功能 |
|--------|------|
| `0` | 行首 |
| `$` | 行尾 |
| `^` | 第一个非空字符 |

#### 视口移动

| 快捷键 | 功能 |
|--------|------|
| `g` | 跳到顶部 |
| `G` | 跳到底部 |
| `H` | 视口顶部 |
| `M` | 视口中间 |
| `L` | 视口底部 |

#### 翻页

| 快捷键 | 功能 |
|--------|------|
| `PageUp` / `Ctrl+B` | 上翻页 |
| `PageDown` / `Ctrl+F` | 下翻页 |
| `Ctrl+D` | 下翻半页 |
| `Ctrl+U` | 上翻半页 |

### 选择和复制

#### 选择模式

| 快捷键 | 功能 |
|--------|------|
| `v` | 字符选择 (Visual) |
| `V` | 行选择 (Visual Line) |
| `Ctrl+V` | 块选择 (Visual Block) |

#### 复制

| 快捷键 | 功能 |
|--------|------|
| `y` | 复制选中内容到剪贴板 |
| `Enter` | 复制选中内容并退出 |

### 搜索

| 快捷键 | 功能 |
|--------|------|
| `/` | 搜索 |
| `n` | 下一个匹配 |
| `N` | 上一个匹配 |

### 退出 Copy Mode

| 快捷键 | 功能 |
|--------|------|
| `q` | 退出 |
| `Escape` | 退出 |
| `Ctrl+C` | 退出 |

---

## 🔍 Search Mode (搜索模式)

在 Copy Mode 按 `/` 进入搜索模式

| 快捷键 | 功能 |
|--------|------|
| `Enter` | 下一个匹配 |
| `Ctrl+N` | 下一个匹配 |
| `Ctrl+P` | 上一个匹配 |
| `Ctrl+R` | 切换匹配类型 (正则/普通) |
| `Ctrl+U` | 清除搜索 |
| `Escape` | 退出搜索 |

---

## 📊 快捷键分类统计

| 类别 | 快捷键数量 |
|------|-----------|
| 系统操作 | 6 个 |
| Tab 操作 | 8 个 |
| Pane 操作 | 15 个 |
| 导航操作 | 4 个（已注释） |
| 调整操作 | 4 个 |
| 系统功能 | 3 个 |
| Workspace | 5 个 |
| 背景图片 | 3 个 (可选) |
| 快速选择 | 1 个 |
| Copy Mode | 30+ 个 |
| **总计** | **73+ 个** |

---

## 🎨 快捷键设计模式

### 1. Leader 键模式

**适用**: Pane、Workspace、背景等复杂操作

```
Leader + 字母键
```

**优点**:

- 避免冲突
- 逻辑分组
- 易于扩展

### 2. MOD 键模式

**适用**: Tab、系统等常用操作

```
MOD + 字母/数字键
```

**优点**:

- 快速触发
- 跨平台一致
- 符合习惯

### 3. 模态模式

**适用**: Copy Mode、Search Mode

```
Leader + [ → 进入 Copy Mode
在 Copy Mode 内使用 Vim 键位
```

**优点**:

- 无需修饰键
- Vim 用户友好
- 功能丰富

---

## 💡 使用技巧

### 快速工作流

#### 1. 项目切换

```
Leader + W → 选择 Workspace
或
Leader + C → 创建新 Workspace
```

#### 2. 窗格分割

```
Leader + V → 垂直分割（左右）
Leader + H → 水平分割（上下）
Leader + 方向键 → 导航
```

#### 3. 快速复制

```
Leader + [ → 进入 Copy Mode
/搜索内容 → 搜索
n/N → 跳转匹配
v → 选择
y → 复制
```

---

## 🎯 快捷键速查卡

### 最常用 Top 10

| 排名 | 快捷键 | 功能 | 说明 |
|------|--------|------|------|
| 1 | `Leader+[` | Copy Mode | 文本选择与复制 |
| 2 | `MOD+T` | 新建 Tab | 创建新标签页 |
| 3 | `MOD+W` | 关闭 Tab | 关闭当前标签页 |
| 4 | `Leader+v` | 水平分割 | 上下分割窗格 |
| 5 | `Leader+h` | 垂直分割 | 左右分割窗格 |
| 6 | `Leader+w` | 切换 Workspace | 项目间快速切换 |
| 7 | `MOD+1-9` | 跳转 Tab | 快速跳转到指定Tab |
| 8 | `MOD+R` | 重载配置 | 重新加载配置 |
| 9 | `Leader+p` | 命令面板 | 访问各种命令 |
| 10 | `Leader+z` | 全屏窗格 | 窗格缩放切换 |
| 11 | `Leader+o` | 切换窗格 | 循环切换窗格 |

---

## 🔧 自定义快捷键

### 添加新快捷键

编辑 `config/keymaps.lua`:

```lua
config.keys = {
   -- 添加你的快捷键
   {
      key = "自定义键",
      mods = "修饰键",
      action = wezterm.action.动作名称,
   },
}
```

### 修改 Leader 键

编辑 `config/keymaps.lua`:

```lua
config.leader = {
   key = "a",  -- 改为你想要的键
   mods = "CTRL",
   timeout_milliseconds = 2000,  -- 超时时间
}
```

### 禁用快捷键

```lua
{
   key = "W",
   mods = "CMD",
   action = wezterm.action.DisableDefaultAssignment,
}
```

---

## 📖 相关文档

- [ARCHITECTURE.md](./ARCHITECTURE.md) - 架构设计
- [EVENTS.md](./EVENTS.md) - 事件说明
- [FEATURES.md](./FEATURES.md) - 功能特性

---

## ✨ 总结

### 设计亮点

1. ✅ **Leader 键系统** - 避免冲突，易于扩展 (`Ctrl+;`)
2. ✅ **跨平台一致** - MOD 键自动适配
3. ✅ **Vim 风格** - Copy Mode 使用 Vim 键位
4. ✅ **逻辑分组** - 相似操作使用相同前缀
5. ✅ **窗格优化** - 分割方向与视觉一致

### 快捷键哲学

> "好的快捷键应该是直觉的，而不是死记硬背的"

我们的快捷键设计遵循：

- **一致性** - 相同类型操作使用相同模式
- **可发现性** - 通过命令面板发现新功能
- **渐进式** - 从简单到复杂，逐步掌握
- **可配置** - 可以根据个人习惯调整
- **避免冲突** - 通过三层键绑定系统避免冲突

**快捷键总评**: ⭐⭐⭐⭐⭐ (5/5) - 完美平衡！