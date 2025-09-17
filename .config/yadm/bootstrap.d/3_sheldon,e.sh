#!/bin/bash

# Sheldon 和 Starship 安装脚本
# 此脚本安装 Sheldon (插件管理器) 和 Starship (提示符)

source ${HOME}/.config/yadm/utils.sh

# ============================================================================
# 安装 Sheldon
# ============================================================================

if executable_exists sheldon; then
	info "sheldon 已安装: $(which sheldon)"
else
	step "正在安装 sheldon ..."
	
	# 检测操作系统
	system_type=$(uname -s)
	
	if [ "$system_type" = "Darwin" ]; then
		# macOS: 使用 Homebrew
		if executable_exists brew; then
			run brew install sheldon
		else
			error "未找到 Homebrew。请先安装 Homebrew。"
		fi
	elif [ "$system_type" = "Linux" ]; then
		# Linux: 使用官方安装脚本
		info "在 Linux 上安装 sheldon..."
		run_safe "curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
"
	else
		error "不支持的操作系统: $system_type"
	fi
	
	# 验证安装
	if executable_exists sheldon; then
		info "sheldon 安装成功: $(sheldon --version)"
	else
		error "sheldon 安装失败"
	fi
fi

# ============================================================================
# 生成 Sheldon 插件缓存
# ============================================================================

if [ -f "${HOME}/.config/sheldon/plugins.toml" ]; then
	step "正在生成 sheldon 插件缓存..."
	
	# 创建缓存目录
	run mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/sheldon"
	
	# 生成缓存
	run_safe "sheldon source > ${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/sheldon.zsh"
	
	info "sheldon 插件缓存已生成"
else
	warn "sheldon 配置文件不存在: ~/.config/sheldon/plugins.toml"
fi

# ============================================================================
# 安装 Starship
# ============================================================================

if executable_exists starship; then
	info "starship 已安装: $(starship --version)"
else
	step "正在安装 starship ..."
	
	# 检测操作系统
	system_type=$(uname -s)
	
	if [ "$system_type" = "Darwin" ]; then
		# macOS: 使用 Homebrew
		if executable_exists brew; then
			run brew install starship
		else
			error "未找到 Homebrew。请先安装 Homebrew。"
		fi
	elif [ "$system_type" = "Linux" ]; then
		# Linux: 检查 GLIBC 版本
		info "在 Linux 上安装 starship..."
		
		# 检查是否需要 musl 版本
		glibc_version=$(ldd --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+')
		
		if [ -z "$glibc_version" ]; then
			warn "无法检测 GLIBC 版本，将尝试安装 musl 版本"
			run_safe "curl -sS https://starship.rs/install.sh | sh -s -- --platform unknown-linux-musl --yes"
		else
			# 比较版本号（需要 2.18+）
			required_version="2.18"
			if awk -v ver="$glibc_version" -v req="$required_version" 'BEGIN{exit !(ver >= req)}'; then
				info "GLIBC 版本 $glibc_version >= $required_version，安装标准版本"
				run_safe "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
			else
				warn "GLIBC 版本 $glibc_version < $required_version，安装 musl 版本"
				run_safe "curl -sS https://starship.rs/install.sh | sh -s -- --platform unknown-linux-musl --yes"
			fi
		fi
	else
		error "不支持的操作系统: $system_type"
	fi
	
	# 验证安装
	if executable_exists starship; then
		info "starship 安装成功: $(starship --version)"
	else
		error "starship 安装失败"
	fi
fi

info "Sheldon 和 Starship 安装完成"
