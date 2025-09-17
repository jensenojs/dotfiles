#!/bin/bash

# macOS (Darwin) 的 Bootstrap 准备脚本
# 此脚本为 macOS 系统设置基本环境。

source ${HOME}/.config/yadm/utils.sh
source ${HOME}/.config/yadm/constants.sh

# 验证我们是否在正确的操作系统上
system_type=$(uname -s)
if [ "$system_type" = "Darwin" ]; then
	note "准备在 Darwin 上进行 bootstrap"
else
	error "不应从该文件进行 bootstrap"
fi

# ================================================================================================
# 设置 XDG 基础目录规范环境变量
# 这有助于通过组织配置、数据、状态和缓存文件来保持主目录的整洁
# 参见: https://ios.sspai.com/post/90480

target_file="${HOME}/.zshenv"

# 如果 .zshenv 不存在则创建
if ! file_exists "$target_file"; then
	touch "${HOME}/.zshenv"
fi

# 设置 XDG_CONFIG_HOME (~/.config) - 用户特定的配置文件
if grep -q "XDG_CONFIG_HOME" "$target_file"; then
	info "XDG_CONFIG_HOME 已设置，跳过。"
else
	info "将 XDG_CONFIG_HOME 设置到 $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_CONFIG_HOME="${HOME}/.config"' >>"$target_file"
	export XDG_CONFIG_HOME="${HOME}/.config"
fi

# 设置 XDG_DATA_HOME (~/.local/share) - 用户特定的数据文件
if grep -q "XDG_DATA_HOME" "$target_file"; then
	info "XDG_DATA_HOME 已设置，跳过。"
else
	info "将 XDG_DATA_HOME 设置到 $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_DATA_HOME="${HOME}/.local/share"' >>"$target_file"
	export XDG_DATA_HOME="${HOME}/.local/share"
fi

# 设置 XDG_STATE_HOME (~/.local/state) - 用户特定的状态文件
if grep -q "XDG_STATE_HOME" "$target_file"; then
	info "XDG_STATE_HOME 已设置，跳过。"
else
	info "将 XDG_STATE_HOME 设置到 $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_STATE_HOME="${HOME}/.local/state"' >>"$target_file"
	export XDG_STATE_HOME="${HOME}/.local/state"
fi

# 设置 XDG_CACHE_HOME (~/.cache) - 用户特定的缓存文件
if grep -q "XDG_CACHE_HOME" "$target_file"; then
	info "XDG_CACHE_HOME 已设置，跳过。"
else
	info "将 XDG_CACHE_HOME 设置到 $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_CACHE_HOME="${HOME}/.cache"' >>"$target_file"
	export XDG_CACHE_HOME="${HOME}/.cache"
fi

# 创建默认的 Projects 目录
if ! directory_exists "${HOME}/Projects"; then
	run mkdir "${HOME}/Projects"
fi
