# YADM Bootstrap 文档

**版本**: 1.0  
**标准**: XDG Base Directory Specification  
**架构**: 模块化 Bootstrap

## 📋 目录

- [概述](#概述)
- [目录结构](#目录结构)
- [Bootstrap 流程](#bootstrap-流程)
- [模块说明](#模块说明)
- [工具函数](#工具函数)
- [使用指南](#使用指南)
- [故障排查](#故障排查)

## 🎯 概述

YADM Bootstrap 系统用于在新机器上自动化配置开发环境。采用模块化设计，每个脚本负责特定的安装任务。

### 设计原则

1. **模块化** - 每个脚本独立，职责单一
2. **XDG 规范** - 所有工具链遵循 XDG 标准
3. **跨平台** - 支持 macOS 和 Linux (Ubuntu, Fedora, CentOS 7+)
4. **幂等性** - 可以多次运行，不会重复安装
5. **错误处理** - 完善的日志记录和错误报告

### 特性

- ✅ 自动检测操作系统和发行版
- ✅ 完整的日志记录（`~/yadm_bootstrap.log`）
- ✅ 支持 dry-run 模式测试
- ✅ 智能跳过已安装的组件
- ✅ 使用现代工具链（fnm, Sheldon, Starship）

## 📁 目录结构

```text
~/.config/yadm/
├── bootstrap                  # 主入口脚本
├── bootstrap.d/               # 模块化 bootstrap 脚本
│   ├── 0_prepare.sh##...      # 系统准备（特定平台）
│   ├── 1_packages##...        # 包安装（特定平台）
│   ├── 2_languages,e.sh       # 编程语言（fnm, Go, Rust）
│   ├── 3_sheldon,e.sh         # Sheldon + Starship
│   ├── 3_omz,e.sh.disabled    # Oh My Zsh（已禁用）
│   ├── 4_tmux,e.sh            # Tmux 插件
│   └── 5_some_projects.sh     # 项目克隆
├── constants.sh               # 常量定义
├── utils.sh                   # 工具函数库
├── config                     # yadm 配置
├── encrypt                    # 加密文件列表
├── Brewfile                   # Homebrew Bundle
├── README.md                  # 本文档
└── XDG_SPEC.md                # XDG 规范说明

# 日志
~/yadm_bootstrap.log           # Bootstrap 执行日志
```

## ⚡ Bootstrap 流程

### 执行顺序

```text
1. bootstrap (主脚本)
   ├── 加载 utils.sh (工具函数)
   ├── 加载 constants.sh (常量)
   ├── 请求 sudo 密码
   └── 按字母顺序执行 bootstrap.d/*.sh

2. bootstrap.d/0_prepare.sh##...
   ├── 系统准备
   ├── 更新包管理器
   └── 安装基础工具

3. bootstrap.d/1_packages##...
   ├── 安装系统包
   ├── brew bundle (macOS)
   └── apt/dnf install (Linux)

4. bootstrap.d/2_languages,e.sh
   ├── 安装 fnm + Node.js LTS
   ├── 安装 Go (最新稳定版)
   ├── 安装 Rust (rustup)
   └── 配置 Python/Pip XDG

5. bootstrap.d/3_sheldon,e.sh
   ├── 安装 Sheldon
   ├── 生成插件缓存
   ├── 安装 Starship
   └── 检测 GLIBC (Linux)

6. bootstrap.d/4_tmux,e.sh
   └── 安装 TPM 插件管理器

7. bootstrap.d/5_some_projects.sh
   └── 克隆项目仓库
```

### 文件命名规范

```text
[优先级]_[名称][模板][扩展名]

优先级:
  0-9: 数字前缀控制执行顺序

模板 (##):
  ##os.Darwin        - 仅 macOS
  ##os.Linux         - 仅 Linux
  ##os.Linux,d.Ubuntu - 仅 Ubuntu
  ##os.Linux,d.Fedora - 仅 Fedora

扩展名:
  ,e.sh  - 所有平台执行
  .sh    - 所有平台执行
  ##...  - 模板文件 (不执行)
```

## 📦 模块说明

### 0_prepare.sh - 系统准备

**功能**: 更新系统、安装基础工具

**平台特定**:

- **macOS**: 安装 Xcode Command Line Tools, Homebrew
- **Ubuntu**: `apt update && apt upgrade`
- **Fedora**: `dnf update`

**输出**:

- Homebrew 安装在 `/opt/homebrew` (Apple Silicon) 或 `/usr/local` (Intel)
- 基础开发工具

### 1_packages - 包安装

**功能**: 安装开发工具和应用

**macOS (`##os.Darwin`)**:

```bash
brew bundle --file ~/.config/yadm/Brewfile
```

**Linux (`##os.Linux,d.Ubuntu`)**:

```bash
# 安装: git, curl, wget, zsh, tmux, neovim, ripgrep, fd-find, fzf, etc.
apt install -y [packages]
```

### 2_languages - 编程语言

**功能**: 安装编程语言工具链，遵循 XDG 规范

#### Node.js (fnm)

```bash
# 安装 fnm
- macOS: brew install fnm
- Linux: curl -fsSL https://fnm.vercel.app/install

# 安装 Node.js LTS
fnm install --lts
fnm use lts-latest
fnm default lts-latest

# XDG 目录
FNM_DIR=~/.local/share/fnm
npm 配置=~/.config/npm/npmrc
npm 全局=~/.local/share/npm
npm 缓存=~/.cache/npm
```

#### Go

```bash
# 下载最新稳定版
curl -s https://go.dev/dl/ | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | head -1

# 安装到 /usr/local/go
sudo tar -C /usr/local -xzf go*.tar.gz

# XDG 目录
GOPATH=~/.local/share/go
GOBIN=~/.local/bin
GOMODCACHE=~/.cache/go/mod
```

#### Rust

```bash
# 使用 rustup 安装 (非交互式)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path

# XDG 目录
RUSTUP_HOME=~/.local/share/rustup
CARGO_HOME=~/.local/share/cargo
```

#### Python/Pip

```bash
# 创建 XDG 目录
~/.config/pip/pip.conf
~/.cache/pip/

# pip.conf 配置
[global]
cache-dir = ${XDG_CACHE_HOME}/pip
index-url = https://mirrors.cloud.tencent.com/pypi/simple
```

### 3_sheldon - 插件管理和提示符

**功能**: 安装 Sheldon (替代 Oh My Zsh) 和 Starship

#### Sheldon

```bash
# 安装
- macOS: brew install sheldon
- Linux: curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash

# 生成缓存
sheldon source > ~/.cache/sheldon/sheldon.zsh

# 配置文件
~/.config/sheldon/plugins.toml
```

#### Starship

```bash
# 安装
- macOS: brew install starship
- Linux: 
  - 检测 GLIBC 版本
  - 如果 >= 2.18: 标准版本
  - 如果 < 2.18 (CentOS 7): musl 版本
  
# CentOS 7 / 旧系统
curl -sS https://starship.rs/install.sh | sh -s -- --platform unknown-linux-musl --yes

# 配置文件
~/.config/starship.toml
```

**GLIBC 检测逻辑**:

```bash
# 获取 GLIBC 版本
glibc_version=$(ldd --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+')

# 比较版本
if version >= 2.18; then
    # 标准版本
else
    # musl 版本 (静态链接)
fi
```

### 4_tmux - Tmux 插件

**功能**: 安装 Tmux Plugin Manager (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

### 5_some_projects - 项目克隆

**功能**: 克隆常用项目仓库

## 🛠️ 工具函数

定义在 `utils.sh`，所有 bootstrap 脚本都可使用。

### 日志函数

```bash
log LEVEL "message"          # 记录日志 (INFO, WARN, ERROR, DEBUG)
info "message"               # 信息消息
warn "message"               # 警告消息
error "message"              # 错误消息并退出
debug "message"              # 调试消息 (DEBUG=1 时)
note "message"               # 注意事项
step "description"           # 步骤标题（自动编号）
```

### 检查函数

```bash
executable_exists command    # 检查命令是否存在
file_exists path             # 检查文件是否存在
directory_exists path        # 检查目录是否存在
is_dryrun                    # 检查是否为 dry-run 模式
```

### 执行函数

```bash
run command args...          # 执行命令并记录日志
run_safe "complex command"   # 安全执行复杂命令（管道、重定向）
ask_password                 # 请求 sudo 密码并保持会话
```

### 使用示例

```bash
#!/bin/bash
source ${HOME}/.config/yadm/utils.sh

step "安装示例工具"

if executable_exists mytool; then
    note "mytool 已安装"
else
    info "正在安装 mytool..."
    run brew install mytool
    
    if executable_exists mytool; then
        info "mytool 安装成功"
    else
        error "mytool 安装失败"
    fi
fi
```

## 📖 使用指南

### 首次运行

```bash
# 克隆配置
yadm clone https://github.com/username/dotfiles.git

# 运行 bootstrap
yadm bootstrap

# 查看日志
tail -f ~/yadm_bootstrap.log
```

### Dry-run 模式

测试 bootstrap 而不实际执行命令：

```bash
~/.config/yadm/bootstrap --dryrun
```

### 单独执行模块

```bash
# 只安装语言工具链
~/.config/yadm/bootstrap.d/2_languages,e.sh

# 只安装 Sheldon 和 Starship
~/.config/yadm/bootstrap.d/3_sheldon,e.sh
```

### 更新工具链

```bash
# 更新 Homebrew 包
brew update && brew upgrade

# 更新 fnm + Node.js
fnm install --lts
fnm use lts-latest

# 更新 Rust
rustup update

# 更新 Sheldon 插件
sheldon lock --update
sheldon source > ~/.cache/sheldon/sheldon.zsh
```

## 🔍 故障排查

### 常见问题

#### 1. Starship 安装失败："version 'GLIBC_2.18' not found"

**原因**: CentOS 7 或旧系统的 GLIBC 版本 < 2.18

**解决**:

```bash
# 使用 musl 版本 (静态链接)
curl -sS https://starship.rs/install.sh | sh -s -- --platform unknown-linux-musl --yes
```

#### 2. fnm 命令找不到

**原因**: `~/.local/bin` 不在 PATH 中

**解决**:

```bash
# 检查 PATH
echo $PATH | grep ".local/bin"

# 添加到 PATH (env.d/11-path.zsh 应该已经处理)
export PATH="$HOME/.local/bin:$PATH"
```

#### 3. npm 全局包安装到错误位置

**原因**: NPM 配置未正确设置

**解决**:

```bash
# 检查配置
npm config get prefix
# 应该输出: ~/.local/share/npm

npm config get cache
# 应该输出: ~/.cache/npm

# 如果不正确，检查 ~/.config/npm/npmrc
# 并确保 NPM_CONFIG_USERCONFIG 环境变量已设置
```

#### 4. Go 命令找不到

**原因**: `/usr/local/go/bin` 不在 PATH 中

**解决**:

```bash
# 检查 PATH
echo $PATH | grep "/usr/local/go/bin"

# 添加到 PATH (env.d/20-go.zsh 应该已经处理)
export PATH="/usr/local/go/bin:$PATH"
```

#### 5. Rust/Cargo 命令找不到

**原因**: Cargo bin 目录不在 PATH 中

**解决**:

```bash
# 检查 PATH
echo $PATH | grep "cargo/bin"

# 添加到 PATH (env.d/21-rust.zsh 应该已经处理)
export PATH="$HOME/.local/share/cargo/bin:$PATH"
```

### 调试模式

```bash
# 启用调试输出
DEBUG=1 ~/.config/yadm/bootstrap

# 查看详细日志
cat ~/yadm_bootstrap.log

# 逐步执行
bash -x ~/.config/yadm/bootstrap.d/2_languages,e.sh
```

### 日志文件

所有执行都记录在 `~/yadm_bootstrap.log`:

```bash
# 实时查看日志
tail -f ~/yadm_bootstrap.log

# 搜索错误
grep ERROR ~/yadm_bootstrap.log

# 查看特定步骤
grep "Step 3" ~/yadm_bootstrap.log
```

## 🔄 维护指南

### 添加新模块

1. 在 `bootstrap.d/` 创建新脚本：

```bash
#!/bin/bash
source ${HOME}/.config/yadm/utils.sh

step "安装新工具"

if ! executable_exists newtool; then
    info "正在安装 newtool..."
    
    # 检测操作系统
    system_type=$(uname -s)
    
    if [ "$system_type" = "Darwin" ]; then
        run brew install newtool
    elif [ "$system_type" = "Linux" ]; then
        run_safe "curl -fsSL https://newtool.sh | bash"
    fi
    
    if executable_exists newtool; then
        info "newtool 安装成功"
    else
        error "newtool 安装失败"
    fi
else
    note "newtool 已安装"
fi
```

2. 添加执行权限：

```bash
chmod +x ~/.config/yadm/bootstrap.d/6_newtool,e.sh
```

3. 测试：

```bash
~/.config/yadm/bootstrap --dryrun
```

### 更新现有模块

1. 编辑脚本
2. 使用 dry-run 测试
3. 提交到 yadm

```bash
yadm add ~/.config/yadm/bootstrap.d/2_languages,e.sh
yadm commit -m "update: 改用 fnm 替代 nvm"
yadm push
```

## 📚 参考资料

### 标准和规范

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [YADM Documentation](https://yadm.io/docs)

### 工具文档

- [fnm (Fast Node Manager)](https://github.com/Schniz/fnm)
- [Sheldon](https://sheldon.cli.rs/)
- [Starship](https://starship.rs/)
- [Homebrew](https://brew.sh/)

### 相关文件

- Zsh 配置: `~/.config/zsh/README.md`
- Starship 配置: `~/.config/starship.toml`
- Sheldon 配置: `~/.config/sheldon/plugins.toml`
- NPM 配置: `~/.config/npm/npmrc`
- Pip 配置: `~/.config/pip/pip.conf`

## ✅ 检查清单

Bootstrap 完成后，验证以下内容：

- [ ] Zsh 已安装并设为默认 shell
- [ ] Homebrew 已安装 (macOS)
- [ ] fnm 已安装，Node.js LTS 可用
- [ ] Go 已安装并在 PATH 中
- [ ] Rust/Cargo 已安装并在 PATH 中
- [ ] Sheldon 已安装，插件缓存已生成
- [ ] Starship 已安装并正常工作
- [ ] 所有工具链遵循 XDG 规范
- [ ] `~/.local/bin` 在 PATH 中
- [ ] 日志文件无 ERROR

### 验证命令

```bash
# 检查工具是否安装
command -v zsh fnm node npm go rustc cargo sheldon starship

# 检查版本
fnm --version
node --version
npm --version
go version
rustc --version
cargo --version
sheldon --version
starship --version

# 检查 XDG 目录
ls -la ~/.local/share/{fnm,npm,go,cargo,rustup}
ls -la ~/.cache/{npm,pip,go}
ls -la ~/.config/{npm,pip,sheldon}

# 检查 PATH
echo $PATH | tr ':' '\n'
```

**Bootstrap 版本**: 1.0  
**最后更新**: 2025-10-18  
**维护者**: Jensen
