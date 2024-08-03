#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

system_type=$(uname -s)
if [ "$system_type" = "Darwin" ]; then
	note "prepare to bootstrap on Darwin"
else
	error "should not bootstrap from this file"
fi

# ================================================================================================
# 设置 XDG_CONFIG_HOME、XDG_DATA_HOME 以及 XDG_STATE_HOME 等, 尽可能将配置文件梳理干净
# https://ios.sspai.com/post/90480

target_file="${HOME}/.zshenv"

# 检查文件是否存在
if ! file_exists "$target_file"; then
	touch "${HOME}/.zshenv"
fi

# 软件的配置文件 - XDG_CONFIG_HOME - ~/.config
if grep -q "XDG_CONFIG_HOME" "$target_file"; then
	info "XDG_CONFIG_HOME already set. Skipping."
else
	info "set XDG_CONFIG_HOME to $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_CONFIG_HOME="${HOME}/.config"' >>"$target_file"
	export XDG_CONFIG_HOME="${HOME}/.config"

fi

# 软件的数据文件 - XDG_DATA_HOME - ~/.local/share/
if grep -q "XDG_DATA_HOME" "$target_file"; then
	info "XDG_DATA_HOME already set. Skipping."
else
	info "set XDG_DATA_HOME to $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_DATA_HOME="${HOME}/.local/share"' >>"$target_file"
	export XDG_DATA_HOME="${HOME}/.local/share"
fi

# 软件的状态文件 - XDG_STATE_HOME - ~/.local/state
if grep -q "XDG_STATE_HOME" "$target_file"; then
	info "XDG_STATE_HOME already set. Skipping."
else
	info "set XDG_STATE_HOME to $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_STATE_HOME="${HOME}/.local/state"' >>"$target_file"
	export XDG_STATE_HOME="${HOME}/.local/state"
fi

# 软件的缓存文件 - XDG_STATE_HOME - ~/.cache
if grep -q "XDG_CACHE_HOME" "$target_file"; then
	info "XDG_CACHE_HOME already set. Skipping."
else
	info "set XDG_CACHE_HOME to $target_file"
	echo "" >>"$target_file"
	echo 'export XDG_CACHE_HOME="${HOME}/.cache"' >>"$target_file"
	export XDG_CACHE_HOME="${HOME}/.cache"
fi

if ! directory_exists "${HOME}/Projects"; then
	run mkdir "${HOME}/Projects"
fi
