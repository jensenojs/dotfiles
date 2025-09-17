#!/bin/bash

# macOS (Darwin) 的软件包安装脚本
# 此脚本安装 Homebrew 和 Brewfile 中定义的软件包。

source ${HOME}/.config/yadm/utils.sh

# 将 Homebrew 添加到 PATH
path=(/opt/homebrew/bin /usr/local/bin $path)

# 安装 Homebrew 及其依赖项
step "正在安装 XCode 命令行工具..."
run xcode-select --install
info "XCode 工具安装完成后按回车键..."

firstly_install_brew=false
# 如果缺少 Homebrew 则安装
if ! executable_exists brew; then
	step "正在安装 Homebrew..."
	firstly_install_brew=true
	run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
fi

# 如果安装了 Homebrew，则更新它并从 Brewfile 安装软件包
if [ "$executable_exists brew" ] && [ "$firstly_install_brew" = "true" ]; then
	step "更新 brew"
	run brew update

	# 从 Brewfile 安装软件包
	# Brewfile 允许用户定义一组软件包及其版本
	# 以便于安装、更新和管理
	if [[ -f ${HOME}/.config/yadm/Brewfile ]]; then
		step "正在安装 Homebrew bundle"
		run brew bundle install --verbose --file=${HOME}/.config/yadm/Brewfile
	fi
fi
