#!/bin/bash

# 编程语言安装脚本
# 此脚本安装 Node.js (通过 fnm)、Go 和 Rust
# 完全遵循 XDG Base Directory Specification

source ${HOME}/.config/yadm/utils.sh

# ============================================================================
# 安装 Node.js (使用 fnm - Fast Node Manager)
# ============================================================================

if executable_exists fnm; then
	note "fnm 已安装: $(fnm --version)"
else
	step "正在安装 fnm (Fast Node Manager) ..."
	
	# 检测操作系统
	system_type=$(uname -s)
	
	if [ "$system_type" = "Darwin" ]; then
		# macOS: 使用 Homebrew
		if executable_exists brew; then
			run brew install fnm
		else
			error "未找到 Homebrew。请先安装 Homebrew。"
		fi
	elif [ "$system_type" = "Linux" ]; then
		# Linux: 使用官方安装脚本
		info "在 Linux 上安装 fnm..."
		run_safe "curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir ${HOME}/.local/bin --skip-shell"
	else
		error "不支持的操作系统: $system_type"
	fi
	
	# 验证安装
	if executable_exists fnm; then
		info "fnm 安装成功: $(fnm --version)"
	else
		error "fnm 安装失败"
	fi
fi

# 如果 fnm 已安装但 node 未安装，安装 Node.js LTS
if executable_exists fnm && ! executable_exists node; then
	step "正在使用 fnm 安装 Node.js LTS ..."
	
	# 设置 FNM 环境
	export FNM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"
	eval "$(fnm env --use-on-cd)"
	
	# 安装 LTS 版本
	run fnm install --lts
	run fnm use lts-latest
	run fnm default lts-latest
	
	# 验证安装
	if executable_exists node; then
		info "Node.js 安装成功: $(node --version)"
		info "npm 版本: $(npm --version)"
	else
		error "Node.js 安装失败"
	fi
elif executable_exists node; then
	note "Node.js 已安装: $(node --version)"
fi

# 创建 npm XDG 配置
if executable_exists npm; then
	step "配置 npm 使用 XDG 目录 ..."
	
	# 创建必要的目录
	run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/npm"
	run mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/npm"
	run mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/npm"
	run mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/npm"
	
	info "npm XDG 配置已完成"
fi

# ============================================================================
# 安装 Go
# ============================================================================

if ! executable_exists go; then
	step "正在安装 golang ..."

	# 确定正确的架构
	system_type=$(uname -s)
	if [ "$system_type" = "Darwin" ]; then
		arch_type=$(uname -m)
		if [ "$arch_type" = "arm64" ]; then
			toinstall="darwin-arm64"
		else
			toinstall="darwin-amd64"
		fi
	else
		toinstall="linux-amd64"
	fi

	# 创建 XDG 目录
	run mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/go"
	run mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/go"

	# 获取最新的稳定版 Go 版本
	info "正在从 go.dev 获取最新稳定版本"
	lastest_stable_go_version=$(curl -s https://go.dev/dl/ | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | head -1)

	info "将安装 Go $lastest_stable_go_version ($toinstall)"

	# 下载并安装 Go 到系统目录
	tmp_dir=$(mktemp -d)
	run_safe "wget -P $tmp_dir https://go.dev/dl/${lastest_stable_go_version}.${toinstall}.tar.gz"
	
	# 安装到 /usr/local (需要 sudo) 或 ~/.local
	if [ -w "/usr/local" ]; then
		info "安装到 /usr/local/go"
		run_safe "tar -C /usr/local -xzf $tmp_dir/${lastest_stable_go_version}.${toinstall}.tar.gz"
	else
		info "安装到 ~/.local/go (需要 sudo 权限才能安装到 /usr/local)"
		run_safe "sudo tar -C /usr/local -xzf $tmp_dir/${lastest_stable_go_version}.${toinstall}.tar.gz"
	fi

	# 清理
	run rm -rf "$tmp_dir"

	# 验证安装
	if executable_exists /usr/local/go/bin/go; then
		info "Go 安装成功: $(/usr/local/go/bin/go version)"
	else
		error "Go 安装失败"
	fi
else
	note "Go 已安装: $(go version)"
fi

# ============================================================================
# 安装 Rust (使用 rustup)
# ============================================================================

if ! executable_exists rustc; then
	step "正在安装 Rust ..."

	# 创建 XDG 目录
	run mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
	run mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/rustup"

	# 设置环境变量
	export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
	export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"

	# 下载并运行 rustup 安装程序 (非交互式)
	info "使用 rustup 安装 Rust..."
	run_safe "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"

	# 加载 Rust 环境
	. "$CARGO_HOME/env"

	# 验证安装
	if executable_exists rustc; then
		info "Rust 安装成功: $(rustc --version)"
		info "Cargo 版本: $(cargo --version)"
	else
		error "Rust 安装失败"
	fi
else
	note "Rust 已安装: $(rustc --version)"
fi

# ============================================================================
# 配置 Python/Pip
# ============================================================================

if executable_exists python3; then
	step "配置 Python/Pip 使用 XDG 目录 ..."
	
	# 创建必要的目录
	run mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/pip"
	run mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/pip"
	
	info "Python/Pip XDG 配置已完成"
	note "Python 版本: $(python3 --version)"
else
	warn "Python3 未安装，跳过 Pip 配置"
fi

info "所有编程语言安装完成"
