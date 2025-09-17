#!/bin/bash

# Oh My Zsh 安装脚本
# 此脚本安装 Oh My Zsh 和几个流行的插件。

source ${HOME}/.config/yadm/utils.sh

# GitHub 上 zsh-users 组织的 URL
ZSH_USERS_URL="https://github.com/zsh-users"

# 检查 Oh My Zsh 是否已安装
if directory_exists $ZSH; then
	info "oh-my-zsh 已安装"
else
	step "正在安装 oh-my-zsh 及其插件 ..."

	# 验证是否设置了 XDG_DATA_HOME
	if [ -z "$XDG_DATA_HOME" ]; then
		error "安装 oh-my-zsh 前应设置 XDG_DATA_HOME"
	else
		# 使用官方安装程序安装 Oh My Zsh
		sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
	fi
fi

# 如果尚未设置 ZSH_CUSTOM 则设置
if [ -z "$ZSH_CUSTOM" ]; then
	export ZSH_CUSTOM="$ZSH/custom"
	info "将 ZSH_CUSTOM 设置为 $ZSH_CUSTOM"
fi

# 安装 Oh My Zsh 插件的函数
# 用法: omz_install_plugin REPO_URL PLUGIN_NAME
function omz_install_plugin() {
	declare url="$1"
	declare plugin="$2"

	# 以浅层深度克隆插件仓库以加快克隆速度
	if [[ $url == "$ZSH_USERS_URL" ]]; then
		# 对 zsh-users 插件的特殊处理
		run git clone --depth 1 "$url/$plugin" \
			"${ZSH_CUSTOM}/plugins/$plugin"
	else
		# 对其他插件的一般处理
		run git clone --depth 1 "$url" \
			"${ZSH_CUSTOM}/plugins/$plugin"
	fi
}

# 安装 Powerlevel10k 主题
# 一个快速、灵活且可定制的提示主题
if directory_exists $ZSH_CUSTOM/themes/powerlevel10k; then
	info "powerlevel10k 已安装"
else
	info "正在安装 powerlevel10k"
	run git clone --depth 1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

# 安装 zsh-autosuggestions 插件
# 根据历史记录和补全建议您输入的命令
# https://github.com/zsh-users/zsh-autosuggestions
if directory_exists $ZSH_CUSTOM/plugins/zsh-autosuggestions; then
	info "zsh-autosuggestions 已安装"
else
	info "正在安装 zsh-autosuggestions"
	omz_install_plugin $ZSH_USERS_URL "zsh-autosuggestions"
fi

# 安装 zsh-syntax-highlighting 插件
# 为您提供输入命令时的语法高亮
# https://github.com/zsh-users/zsh-syntax-highlighting
if directory_exists $ZSH_CUSTOM/plugins/zsh-syntax-highlighting; then
	info "zsh-syntax-highlighting 已安装"
else
	info "正在安装 zsh-syntax-highlighting"
	omz_install_plugin $ZSH_USERS_URL "zsh-syntax-highlighting"
fi

# 安装 zsh-you-should-use 插件
# 帮助您记住使用别名、函数和其他省时功能
# https://github.com/MichaelAquilina/zsh-you-should-use
if directory_exists $ZSH_CUSTOM/plugins/you-should-use; then
	info "zsh-you-should-use 已安装"
else
	info "正在安装 zsh-you-should-use"
	omz_install_plugin "https://github.com/MichaelAquilina/zsh-you-should-use.git" \
		"you-should-use"
fi

# 安装 vscode 插件
# 为 VS Code 提供辅助函数
# https://github.com/valentinocossar/vscode
if directory_exists $ZSH_CUSTOM/plugins/vscode; then
	info "zsh-vscode 已安装"
else
	info "正在安装 zsh-vscode"
	omz_install_plugin "https://github.com/valentinocossar/vscode.git" \
		"vscode"
fi

# 安装 zsh-vi-mode 插件（已注释掉，因为未使用）
# 为 Zsh 提供类似 vi 的编辑模式
# https://github.com/jeffreytse/zsh-vi-mode
# if directory_exists $ZSH_CUSTOM/plugins/zsh-vi-mode; then
# 	info "zsh-vi-mode 已安装"
# else
# 	info "正在安装 zsh-vi-mode"
# 	omz_install_plugin "https://github.com/jeffreytse/zsh-vi-mode" \
# 		"zsh-vi-mode"
# fi

# 安装 fzf-tab 插件
# 用 fzf 替换 Zsh 的默认补全选择菜单
# https://github.com/Aloxaf/fzf-tab
if directory_exists $ZSH_CUSTOM/plugins/fzf-tab; then
	info "fzf-tab 已安装"
else
	info "正在安装 zsh-fzf-tab"
	omz_install_plugin "https://github.com/Aloxaf/fzf-tab" \
		"fzf-tab"
fi
