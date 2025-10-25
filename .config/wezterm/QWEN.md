# WezTerm 配置 - Qwen Code 上下文

## 目录概述

这是一个简洁、高性能、跨平台的 WezTerm 终端配置。该配置采用了模块化设计，遵循了简洁、实用主义的设计哲学，使用 Lua 作为配置语言。

### 核心架构

- **配置系统**: 使用 WezTerm 的 Lua API 进行配置
- **设计原则**: 简洁性、模块化、跨平台支持
- **性能优化**: 启用了严格模式和节流机制
- **主题**: Gruvbox Dark 配色方案
- **快捷键系统**: 采用 Leader 键系统，避免快捷键冲突

## 主要组件

### 入口文件: `wezterm.lua`

这是配置的入口文件，负责初始化配置对象并加载各个模块：

```lua
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- 启用严格模式以提前发现配置错误
if wezterm.config_builder then
   config:set_strict_mode(true)
end

local platform = require('config.platform')

require('config.options').apply(config, platform)
require('config.appearance').apply(config, platform)
require('config.keymaps').apply(config, platform)

require('config.events').setup({
   show_seconds = false,
   date_format = '%H:%M',
   show_tab_index = true,
   show_process = true,
   show_unseen_indicator = true,
   enable_command_palette = true,
})

return config
```

### 配置模块

配置被组织成以下几个模块：

#### 1. `config/platform.lua` - 平台检测

- 检测操作系统 (macOS/Linux/Windows)
- 定义平台相关的修饰键 (Mac 使用 SUPER/Cmd, 其他使用 ALT)
- 提供平台特定的辅助函数

#### 2. `config/options.lua` - 基础选项

- 通用配置: 更新检查、窗口行为、初始大小
- 字体配置: JetBrains Mono 等 Nerd Font
- 性能设置: 帧率、动画
- 工作区、SSH 域、启动菜单配置

#### 3. `config/appearance.lua` - 外观配置

- 颜色方案: Gruvbox Dark
- 窗口外观: 透明度、装饰、内边距
- 标签栏: 位置、样式、颜色
- 可选的背景图片管理

#### 4. `config/keymaps.lua` - 快捷键

- Leader 键系统 (Ctrl+Space)
- 系统快捷键 (MOD+key)
- WezTerm 特定快捷键 (Leader+key)
- Vim 风格的复制模式快捷键

#### 5. `config/events.lua` - 事件处理

- 标签标题格式化
- 状态栏更新 (显示 Leader 状态、工作区、CPU/内存)
- 命令面板增强
- GUI 启动事件

### 工具模块

#### `utils/colors.lua` - 自定义配色

- 提供完整的 Gruvbox 颜色调色板
- ANSI 颜色、亮色、索引颜色定义

#### `utils/backdrops.lua` - 背景管理

- 可选的背景图片管理功能
- 支持切换背景、聚焦模式
- 默认禁用，需要显式启用

## 配置特色

### 1. Leader 键系统

使用 Tmux 风格的 Leader 键 (`Ctrl+Space`) 来避免快捷键冲突，所有 WezTerm 特定功能都通过 Leader 键访问。

### 2. 跨平台支持

自动适配不同操作系统:
- macOS: 使用 `Cmd` 作为主修饰键，支持原生按钮窗口装饰
- Linux/Windows: 使用 `Alt` 作为主修饰键

### 3. 智能状态栏

- 显示 Leader 键激活状态
- 显示当前工作区
- 显示 CPU 和内存使用率 (节流优化，每 5 秒更新)
- 性能优化避免卡顿

### 4. Vim 风格复制模式

实现了完整的 Vim 风格复制模式，支持：
- 移动: hjkl、w/b/e、0/$/^
- 页面移动: PageUp/PageDown、Ctrl+d/u
- 选择: v/V/Ctrl+v
- 搜索: /、n/N
- 复制: y

### 5. 工作区管理

为不同项目创建独立的标签集合，支持快速切换：
- `Leader+w`: 模糊搜索切换工作区
- `Leader+c`: 创建新工作区
- `Leader+n`: 重命名工作区

### 6. 命令面板

增强的命令面板，包含：
- 切换工作区
- 重载配置
- 显示/隐藏标签栏
- 切换透明度
- 窗口最大化
- 进入复制模式

## 性能优化

### 1. 无 OOP 抽象

避免了过度抽象，使用简单的 apply/setup 模式直接操作配置对象，避免了元表开销。

### 2. 节流机制

在状态栏更新中实现了节流机制，限制系统信息 (CPU/内存) 更新频率（每 5 秒一次），避免不必要的性能开销。

### 3. 按需加载

- 背景图片功能默认关闭
- 系统监控数据节流刷新

## 开发规范

### 代码格式化

- 使用 Stylua 格式化工具
- 语法: LuaJIT
- 缩进: 3 个空格
- 列宽: 100 字符
- 行尾: Unix 风格
- 引号: 自动使用单引号

### 代码检查

- 使用 Luacheck 进行静态分析
- 遵循 LuaJIT 标准
- 忽略特定代码风格警告

### 严格模式

启用 WezTerm 的严格模式以检测配置错误，防止无效配置项在运行时产生问题。

## 文件结构

```
~/.config/wezterm/
├── backdrops/            # 背景图片目录
├── wezterm.lua           # 入口文件 (56 行)
├── config/               # 配置模块
│   ├── platform.lua      # 平台检测
│   ├── options.lua       # 基础配置
│   ├── appearance.lua    # 外观配置
│   ├── keymaps.lua       # 快捷键定义
│   └── events.lua        # 事件处理
├── utils/                # 工具模块
│   ├── colors.lua        # 自定义配色
│   └── backdrops.lua     # 背景管理 (可选)
├── docs/                 # 文档
│   ├── ARCHITECTURE.md   # 架构设计
│   ├── KEYBINDINGS.md    # 快捷键速查
│   ├── EVENTS.md         # 事件说明
│   └── FEATURES.md       # 功能特性
├── .luacheckrc           # Luacheck 配置
├── .luarc.json           # Lua LS 配置
├── .stylua.toml          # Stylua 格式化配置
└── README.md             # 项目文档
```

## 架构模式

### Apply 模式 (配置模块)

用于 options, appearance, keymaps 模块。直接修改传入的 config 对象。

### Setup 模式 (事件模块)

用于 events 模块。支持传入配置选项，提供更灵活的功能定制。

## 设计哲学

1. **简单优于复杂** (KISS) - 避免过度抽象，直接清晰
2. **实用优于炫技** (YAGNI) - 只实现需要的功能
3. **性能优于功能** - 节流优化，避免卡顿
4. **可读优于简洁** - 代码即文档
5. **模块化但不过度** - 5 个核心文件足矣