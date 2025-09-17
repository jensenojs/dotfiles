# Zsh 配置文档

**版本**: 1.0  
**标准**: XDG Base Directory Specification  
**架构**: 模块化 + 延迟加载

---

## 📋 目录

- [设计哲学](#设计哲学)
- [目录结构](#目录结构)
- [模块化设计](#模块化设计)
- [XDG 规范](#xdg-规范)
- [加载顺序](#加载顺序)
- [配置管理](#配置管理)
- [性能优化](#性能优化)
- [扩展指南](#扩展指南)

---

## 🎯 设计哲学

### 核心原则

1. **模块化** - 单一职责，独立配置，易于维护
2. **XDG 规范** - 符合标准，目录清晰，避免污染
3. **性能优先** - 快速启动(<50ms)，延迟加载非关键组件
4. **可扩展性** - 易于添加新功能，不影响现有配置
5. **文档完善** - 清晰注释，易于理解和修改

### 设计目标

- ✅ 启动时间 < 50ms
- ✅ 配置集中在 `~/.config/zsh/`
- ✅ 数据分离到 `~/.local/share/`, `~/.cache/`, `~/.local/state/`
- ✅ 插件管理使用 Sheldon(替代 Oh My Zsh)
- ✅ 提示符使用 Starship(现代化、快速)

---

## 📁 目录结构

```
~/.config/zsh/
├── .zshenv                   # 环境变量入口(所有 shell 都会加载)
├── .zshrc                    # 交互式配置入口(仅交互式 shell 加载)
├── README.md                 # 本文档
├── env.d/                    # 环境变量模块(.zshenv 加载)
│   ├── 00-xdg.zsh            # XDG 目录定义
│   ├── 01-utils.zsh          # 工具函数
│   ├── 10-homebrew.zsh       # Homebrew 环境
│   ├── 11-path.zsh           # PATH 配置
│   ├── 20-go.zsh             # Go 工具链
│   ├── 21-rust.zsh           # Rust 工具链
│   ├── 22-node.zsh           # Node.js 工具链
│   ├── 23-python.zsh         # Python 工具链
│   ├── 24-bun.zsh            # Bun 运行时
│   ├── 30-toolchains.zsh     # 其他工具链
│   ├── 40-lab.zsh            # 实验室环境
│   └── 99-local-env.zsh      # 本地覆盖
└── zshrc.d/                  # 交互式配置模块(.zshrc 加载)
    ├── 00-core.zsh           # 核心设置(历史、选项)
    ├── 10-prompt.zsh         # Starship 提示符
    ├── 20-plugins.zsh        # Sheldon 插件管理
    ├── 30-aliases.zsh        # 别名定义
    ├── 40-functions.zsh      # 自定义函数
    ├── 50-fzf.zsh            # FZF 集成
    └── 99-local.zsh          # 本地覆盖

# XDG 数据目录
~/.local/share/               # 用户数据
├── go/                       # Go 第三方库
├── cargo/                    # Rust 第三方库
├── npm/                      # NPM 全局包
├── bun/                      # Bun 安装
├── fnm/                      # Node 版本管理
└── rustup/                   # Rust 工具链

~/.cache/                     # 缓存数据
├── go/                       # Go 缓存
├── npm/                      # NPM 缓存
├── pip/                      # Pip 缓存
└── sheldon/                  # Sheldon 插件缓存

~/.local/state/               # 状态数据
├── zsh/history               # Zsh 历史记录
└── npm/logs/                 # NPM 日志

~/.local/bin/                 # 用户可执行文件
```

---

## 🧩 模块化设计

### env.d/ - 环境变量模块

**加载时机**: 所有 shell 实例(登录、交互、脚本)  
**用途**: 定义环境变量、PATH、工具链配置

#### 命名规范

```shell
[优先级]-[功能].zsh

优先级:
  00-09: 基础设施(XDG、工具函数)
  10-19: 系统工具(Homebrew、PATH)
  20-29: 编程语言工具链
  30-39: 额外工具链
  40-89: 特定项目/环境
  90-99: 本地覆盖
```

#### 模块说明

| 文件 | 功能 | 依赖 |
|------|------|------|
| `00-xdg.zsh` | 定义 XDG 标准目录 | 无 |
| `01-utils.zsh` | 工具函数库 | 无 |
| `10-homebrew.zsh` | Homebrew 环境 | 无 |
| `11-path.zsh` | 基础 PATH | `01-utils.zsh` |
| `20-go.zsh` | Go 环境 | `00-xdg.zsh`, `01-utils.zsh` |
| `21-rust.zsh` | Rust 环境 | `00-xdg.zsh`, `01-utils.zsh` |
| `22-node.zsh` | Node.js 环境 | `00-xdg.zsh`, `01-utils.zsh` |
| `23-python.zsh` | Python 环境 | `00-xdg.zsh`, `01-utils.zsh` |
| `24-bun.zsh` | Bun 环境 | `00-xdg.zsh`, `01-utils.zsh` |
| `30-toolchains.zsh` | 其他工具链 | `01-utils.zsh` |
| `40-lab.zsh` | 实验室环境变量 | 无 |
| `99-local-env.zsh` | 本地覆盖 | 所有 |

### zshrc.d/ - 交互式配置模块

**加载时机**: 仅交互式 shell  
**用途**: 提示符、插件、别名、函数等

#### 模块说明

| 文件 | 功能 | 依赖 |
|------|------|------|
| `00-core.zsh` | 历史记录、Zsh 选项 | `env.d/00-xdg.zsh` |
| `10-prompt.zsh` | Starship 提示符 | `env.d/01-utils.zsh` |
| `20-plugins.zsh` | Sheldon 插件管理 | `env.d/00-xdg.zsh` |
| `30-aliases.zsh` | 别名定义 | 无 |
| `40-functions.zsh` | 自定义函数 | 无 |
| `50-fzf.zsh` | FZF 集成 | `env.d/01-utils.zsh` |
| `99-local.zsh` | 本地覆盖 | 所有 |

---

## 📐 XDG 规范

完全符合 [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)。

### 标准目录

| 环境变量 | 默认路径 | 用途 | 示例 |
|----------|----------|------|------|
| `XDG_CONFIG_HOME` | `~/.config` | 用户配置 | `~/.config/zsh/` |
| `XDG_DATA_HOME` | `~/.local/share` | 用户数据 | `~/.local/share/go/` |
| `XDG_STATE_HOME` | `~/.local/state` | 状态数据 | `~/.local/state/zsh/history` |
| `XDG_CACHE_HOME` | `~/.cache` | 缓存数据 | `~/.cache/npm/` |

### 扩展目录(非标准)

| 环境变量 | 默认路径 | 用途 | 说明 |
|----------|----------|------|------|
| `XDG_BIN_HOME` | `~/.local/bin` | 用户可执行文件 | 常见约定 |
| `XDG_LIB_HOME` | `~/.local/lib` | 用户库文件 | 为将来扩展预留 |

### 工具链 XDG 化

所有编程语言工具链都遵循 XDG 规范：

```bash
# Go
GOPATH=~/.local/share/go
GOBIN=~/.local/bin
GOMODCACHE=~/.cache/go/mod

# Rust
RUSTUP_HOME=~/.local/share/rustup
CARGO_HOME=~/.local/share/cargo

# Node.js
NPM_CONFIG_USERCONFIG=~/.config/npm/npmrc
# 全局包安装到: ~/.local/share/npm
# 缓存: ~/.cache/npm

# Python
PIP_CONFIG_FILE=~/.config/pip/pip.conf
PIP_CACHE_DIR=~/.cache/pip
PYTHONUSERBASE=~/.local

# Bun
BUN_INSTALL=~/.local/share/bun
```

---

## ⚡ 加载顺序

### Zsh 启动流程

```
┌─────────────────┐
│  Zsh 启动       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  1. .zshenv     │  ← 所有 shell 都会加载
│     加载 env.d/ │
└────────┬────────┘
         │
         ▼
    是交互式 shell?
         │
         ├─ 是 ──▶ ┌─────────────────┐
         │         │  2. .zshrc      │
         │         │  加载 zshrc.d/   │
         │         └─────────────────┘
         │
         └─ 否 ──▶ (结束)
```

### env.d/ 加载顺序

```shell
00-xdg.zsh          # XDG 标准目录
  ↓
01-utils.zsh        # 工具函数(command_exists, prepend_to_path_if_exists 等)
  ↓
10-homebrew.zsh     # Homebrew 环境
  ↓
11-path.zsh         # 基础 PATH
  ↓
20-go.zsh           # Go 工具链
21-rust.zsh         # Rust 工具链
22-node.zsh         # Node.js 工具链
23-python.zsh       # Python 工具链
24-bun.zsh          # Bun 运行时
  ↓
30-toolchains.zsh   # 其他工具链
  ↓
40-lab.zsh          # 实验室环境
  ↓
99-local-env.zsh    # 本地覆盖
```

### zshrc.d/ 加载顺序

```shell
00-core.zsh         # Zsh 核心配置(历史、选项)
  ↓
10-prompt.zsh       # Starship 提示符初始化
  ↓
20-plugins.zsh      # Sheldon 插件管理
  ↓
30-aliases.zsh      # 别名定义
  ↓
40-functions.zsh    # 自定义函数
  ↓
50-fzf.zsh          # FZF 集成
  ↓
99-local.zsh        # 本地覆盖
```

---

## 🔧 配置管理

### 工具函数

定义在 `env.d/01-utils.zsh`：

```bash
# 检查命令是否存在
command_exists() {
  command -v "$1" &> /dev/null
}

# 检查目录是否存在
dir_exists() {
  [ -d "$1" ]
}

# 如果目录存在，添加到 PATH 前面
prepend_to_path_if_exists() {
  [ -d "$1" ] && export PATH="$1:$PATH"
}

# 如果文件存在，source 它
source_if_exists() {
  [ -f "$1" ] && source "$1"
}

# 检查是否为 macOS
is_macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

# 检查是否为 Linux
is_linux() {
  [[ "$OSTYPE" == "linux-gnu"* ]]
}
```

### 插件管理 (Sheldon)

**配置文件**: `~/.config/sheldon/plugins.toml`  
**缓存**: `~/.cache/sheldon/sheldon.zsh`

#### 核心插件

- `zsh-defer` - 延迟加载工具
- `zsh-autosuggestions` - 自动建议
- `zsh-syntax-highlighting` - 语法高亮(延迟加载)
- `fzf-tab` - FZF 增强补全
- `you-should-use` - 别名提醒
- Oh My Zsh 特定插件：git, sudo, vscode, copypath, copyfile, colored-man-pages
- `zoxide` - 智能目录跳转

#### 性能优化

1. **缓存机制**: 只在配置更新时重新生成
2. **延迟加载**: 非关键插件延迟加载
3. **compinit 优先**: 必须最先运行，避免 compdef 错误

### 提示符 (Starship)

**配置文件**: `~/.config/starship.toml`  
**特性**: 单行、命令持续时间显示、Git 状态、Gruvbox 主题

---

## 🚀 性能优化

### 启动性能

**目标**: < 50ms  
**实际**: 30-50ms

### 优化策略

1. **模块化加载**
   - env.d/ 模块按需加载环境变量
   - zshrc.d/ 模块仅交互式 shell 加载

2. **插件缓存**
   - Sheldon 生成静态缓存
   - 只在配置更新时重新生成

3. **延迟加载**
   - 语法高亮使用 zsh-defer 延迟加载
   - 非关键插件延迟初始化

4. **compinit 优化**
   - 使用 `-C` 跳过安全检查
   - 只运行一次，在所有插件之前

### 性能测试

```bash
# 测试启动时间
time zsh -i -c exit

# 使用 zprof 分析
# 在 .zshrc 开头添加: zmodload zsh/zprof
# 在 .zshrc 结尾添加: zprof
```

---

## 🔌 扩展指南

### 添加新的环境变量

1. 在 `env.d/` 创建新文件：

```bash
# env.d/25-java.zsh
# Java 工具链配置

# JDK 路径
if is_macos; then
  export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null || echo "/Library/Java/Home")
else
  export JAVA_HOME="/usr/lib/jvm/default-java"
fi

# 添加到 PATH
prepend_to_path_if_exists "$JAVA_HOME/bin"
```

2. 使用合适的编号前缀(20-29 用于语言工具链)

### 添加新的别名

在 `zshrc.d/30-aliases.zsh` 中添加：

```bash
# 你的新别名
alias myalias='command'
```

### 添加新的函数

在 `zshrc.d/40-functions.zsh` 中添加：

```bash
# 你的新函数
function myfunc() {
  # 函数逻辑
}
```

### 添加新的 Sheldon 插件

编辑 `~/.config/sheldon/plugins.toml`：

```toml
[plugins.my-plugin]
github = "username/repo"
```

然后重新生成缓存：

```bash
sheldon source > ~/.cache/sheldon/sheldon.zsh
exec zsh
```

### 本地覆盖

如果需要本地特定的配置，使用：

- `env.d/99-local-env.zsh` - 环境变量覆盖
- `zshrc.d/99-local.zsh` - 交互式配置覆盖

这些文件在最后加载，可以覆盖任何之前的配置。

---

## 📚 常用命令

### Sheldon 插件管理

```bash
# 列出已安装插件
sheldon list

# 更新所有插件
sheldon lock --update

# 添加新插件
sheldon add plugin-name --github user/repo

# 重新生成缓存
sheldon source > ~/.cache/sheldon/sheldon.zsh
```

### 配置管理

```bash
# 编辑配置
vi ~/.config/zsh/zshrc.d/30-aliases.zsh

# 重新加载配置
exec zsh

# 或者
source ~/.config/zsh/.zshrc
```

### 调试

```bash
# 检查环境变量
echo $GOPATH
echo $NPM_CONFIG_USERCONFIG

# 检查 PATH
echo $PATH | tr ':' '\n'

# 测试函数
command_exists git && echo "Git installed"
```

---

## 🔍 故障排查

### 启动缓慢

1. 使用 `zprof` 分析
2. 检查是否有插件未使用缓存
3. 确认延迟加载配置正确

### 插件不工作

1. 检查 Sheldon 缓存是否最新
2. 确认 `compinit` 在所有插件之前运行
3. 查看 `~/.cache/sheldon/sheldon.zsh` 内容

### 环境变量未生效

1. 确认文件在 `env.d/` 目录
2. 检查文件命名是否正确(`.zsh` 后缀)
3. 确认没有语法错误
4. 重新加载：`exec zsh`

### 命令找不到

1. 检查 PATH：`echo $PATH`
2. 确认相关 env.d 文件已加载
3. 检查工具是否已安装

---

## 📖 参考资料

### 标准和规范

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [Zsh Manual](https://zsh.sourceforge.io/Doc/)

### 工具文档

- [Sheldon Documentation](https://sheldon.cli.rs/)
- [Starship Documentation](https://starship.rs/)
- [FZF Documentation](https://github.com/junegunn/fzf)

### 相关配置

- Starship 配置: `~/.config/starship.toml`
- Sheldon 配置: `~/.config/sheldon/plugins.toml`
- NPM 配置: `~/.config/npm/npmrc`
- Pip 配置: `~/.config/pip/pip.conf`

---

## ✅ 配置检查清单

- [x] 符合 XDG Base Directory Specification
- [x] 模块化设计，单一职责
- [x] 启动时间 < 50ms
- [x] 使用 Sheldon 管理插件
- [x] 使用 Starship 提示符
- [x] 所有工具链支持 XDG
- [x] 完整的文档和注释
- [x] 本地覆盖支持

---

**配置版本**: 2.0  
**最后更新**: 2025-10-18  
**维护者**: Jensen
