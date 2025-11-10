# Diagnostics 插件模块

## 模块设计意图

提供完整的代码调试基础设施，涵盖断点管理、调试会话控制、变量检视、REPL 交互等核心调试功能。

## 核心能力

- **多语言调试**: Go, Python, C/C++, Rust等
- **持久化断点**: 断点跨会话保存
- **可视化界面**: 自动化调试UI管理
- **REPL高亮**: Treesitter驱动的语法高亮
- **虚拟文本**: 实时显示变量值

## 插件列表

### dap.lua

**插件**: `mfussenegger/nvim-dap`

**仓库**: <https://github.com/mfussenegger/nvim-dap>

**功能**: DAP协议核心实现

**配置特点**:

- 统一的调试适配器接口
- 多语言支持（Go, Python, C/C++等）
- 丰富的调试快捷键（F5-F12 + `<leader>d*`）
- 集成 nvim-dap-go 自动配置 Go 调试
- 保护 `vim.ui.select` 避免取消时报错

### dap-ui.lua

**插件**: `rcarriga/nvim-dap-ui`

**仓库**: <https://github.com/rcarriga/nvim-dap-ui>

**功能**: 调试可视化界面

**配置特点**:

- 会话生命周期管理（自动开启/关闭）
- 动态键位加载（`K` 键在调试时临时映射为 `eval`）
- 自定义图标配置（从 `utils/icons.lua` 获取）
- 集成 focus.nvim 在调试时禁用自动聚焦
- 断点图标和调试状态标记

### dap-python.lua

**插件**: `mfussenegger/nvim-dap-python`

**仓库**: <https://github.com/mfussenegger/nvim-dap-python>

**功能**: Python调试适配器

**配置特点**:

- 智能虚拟环境检测（`.venv`, `venv`, `env`, `.env`）
- 支持多种Python环境（venv, conda, uv）
- 项目级虚拟环境优先级策略
- 跨平台路径处理（Windows/Unix）

### persistent-breakpoints.lua

**插件**: `Weissle/persistent-breakpoints.nvim`

**仓库**: <https://github.com/Weissle/persistent-breakpoints.nvim>

**功能**: 断点持久化管理

**配置特点**:

- 在 `BufReadPre` 早期加载确保断点恢复
- 自动保存断点到磁盘
- 支持会话管理集成
- `always_reload = true` 确保可靠恢复

### dap-repl-highlights.lua

**插件**: `LiadOz/nvim-dap-repl-highlights`

**仓库**: <https://github.com/LiadOz/nvim-dap-repl-highlights>

**功能**: DAP REPL语法高亮

**配置特点**:

- 基于 Treesitter 的语法高亮
- 按需加载（`ft = "dap_repl"`）
- 兼容 treesitter main 分支 API
- 友好的错误提示

## 快捷键

### 调试控制

| 快捷键 | 功能 |
|--------|------|
| `<F5>` | 开始/继续调试 |
| `<F7>` | 打开/关闭调试界面 |
| `<F9>` | 切换断点（持久化） |
| `<F10>` | 单步跳过 |
| `<F11>` | 单步进入 |
| `<F12>` | 单步跳出 |

### Leader 键调试命令

| 快捷键 | 功能 |
|--------|------|
| `<leader>db` | 切换断点（持久化） |
| `<leader>dB` | 设置条件断点 |
| `<leader>dc` | 继续执行 |
| `<leader>dr` | 打开 REPL |
| `<leader>dt` | 终止调试会话 |

### 调试会话中的键位

| 快捷键 | 功能 | 作用域 |
|--------|------|--------|
| `K` | 求值光标下的表达式 | 仅在调试会话中 |

## 图标配置

所有调试图标从 `lua/utils/icons.lua` 的 `dap` 分类获取：

```lua
local icons = require("utils.icons").get("dap")
-- 可用图标：
-- Breakpoint, BreakpointCondition, BreakpointRejected
-- LogPoint, Pause, Play, RunLast
-- StepBack, StepInto, StepOut, StepOver
-- Stopped, Terminate
-- expanded, collapsed, current_frame
```

## 相关文档

- [Neotest 测试调试](../test/README.md)
- [nvim-dap 官方文档](https://github.com/mfussenegger/nvim-dap)

---

# Diagnostics 插件模块

意图: 代码诊断、调试和问题列表管理。

## 插件列表

### dap.lua

- 插件: `mfussenegger/nvim-dap`
- 仓库: <https://github.com/mfussenegger/nvim-dap>
- 功能: DAP核心插件，提供调试协议实现
- 配置特点:
    - 集成调试界面和虚拟文本显示
    - 支持多种语言调试适配器
    - 提供丰富的调试快捷键

### dap-ui.lua

- 插件: `rcarriga/nvim-dap-ui`
- 仓库: <https://github.com/rcarriga/nvim-dap-ui>
- 功能: 调试界面配置，提供可视化调试信息
- 配置特点:
    - 动态加载和卸载调试键位映射
    - 会话生命周期管理
    - 自定义调试界面元素和图标

### dap-python.lua

- 插件: `mfussenegger/nvim-dap-python`
- 仓库: <https://github.com/mfussenegger/nvim-dap-python>
- 功能: Python调试适配器配置
- 配置特点:
    - 自动检测项目虚拟环境
    - 支持多种Python环境(venv, conda, uv等)
    - 提供Python特定的调试配置

### persistent-breakpoints.lua

- 插件: `Weissle/persistent-breakpoints.nvim`
- 仓库: <https://github.com/Weissle/persistent-breakpoints.nvim>
- 功能: 持久化断点管理，在读取缓冲时加载并恢复断点
- 配置特点:
    - 自动保存和恢复断点
    - 支持会话管理集成

### dap-repl-highlights.lua

- 插件: `LiadOz/nvim-dap-repl-highlights`
- 仓库: <https://github.com/LiadOz/nvim-dap-repl-highlights>
- 功能: DAP REPL语法高亮
- 配置特点:
    - 基于Treesitter的语法高亮
    - 提升调试时REPL的可读性

## 使用说明

### DAP (Debug Adapter Protocol) 使用说明

DAP 插件提供了一个完整的调试环境，支持多种编程语言。

#### 核心功能

- 断点管理(普通断点和条件断点)
- 步进调试(步入、步过、步出)
- 变量检查和监视
- 调用栈查看
- REPL终端

#### 快捷键

- `<F5>`: 开始/继续调试
- `<F7>`: 打开/关闭调试界面
- `<F9>`: 切换断点(持久化)
- `<F10>`: 步过
- `<F11>`: 步入
- `<F12>`: 步出
- `<leader>db`: 切换断点(持久化)
- `<leader>dB`: 设置条件断点(持久化)
- `<leader>dc`: 继续调试
- `<leader>dr`: 打开REPL
- `<leader>dt`: 终止调试

### DAP UI 使用说明

DAP UI 提供了可视化的调试界面，包含以下元素：

- 作用域面板：显示当前作用域内的变量
- 断点面板：显示所有断点
- 调用栈面板：显示当前调用栈
- 监视面板：显示监视表达式的值
- REPL面板：交互式命令行

界面会在调试会话开始时自动打开，在会话结束时自动关闭。

### Python 调试配置

Python调试插件会自动检测项目环境：

1. 优先使用项目本地虚拟环境(.venv/venv/env/.env)
2. 其次使用环境变量中的虚拟环境(VIRTUAL_ENV/CONDA_PREFIX)
3. 如果安装了uv，则交给uv处理
4. 最后回退到系统Python

### 持久化断点

Persistent Breakpoints 插件会在你关闭文件时自动保存断点，并在重新打开文件时恢复断点，确保调试状态的连续性。

### REPL 语法高亮

REPL Highlights 插件为调试时的交互式终端提供语法高亮，提高代码可读性。
