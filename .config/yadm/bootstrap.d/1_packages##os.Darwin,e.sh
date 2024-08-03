#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

path=(/opt/homebrew/bin /usr/local/bin $path)

## Install Homebrew + dependencies ##
step "Installing XCode Command Line Tools..."
run xcode-select --install
info "Press enter after XCode tools install is complete..."

firstly_install_brew=false
# install homebrew if it's missing
if ! executable_exists brew; then
	step "Installing Homebrew..."
	firstly_install_brew=true
	run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'
fi

# if [executable_exists brew] && [$firstly_install_brew ]; then
if [ "$executable_exists brew" ] && [ "$firstly_install_brew" = "true" ]; then
	step "Update brew"
	run brew update

	# 允许用户通过创建一个配置文件（通常是 Brewfile）来定义需要通过 Homebrew 安装和管理的一组软件包及其具体版本等信息
	# 可以方便地对多个相关软件包进行统一的安装、更新和管理操作
	if [[ -f ${HOME}/.config/yadm/Brewfile ]]; then
		step "Installing Homebrew bundle"
		run brew bundle install --verbose --file=${HOME}/.config/yadm/Brewfile
	fi

	# 主要用于管理 macOS 上的图形化应用程序
	# 它提供了一种方便的方式来安装和管理像浏览器、文本编辑器、媒体播放器等之类的图形界面应用程序
	# 这些应用程序通常不像传统的通过代码编译安装的软件包，而是以预编译的形式提供给用户安装。通过 Homebrew Casks，可以更轻松地发现、安装和更新这些图形化应用程序
	# if [[ -f ${HOME}/.config/yadm/Casks ]]; then
	# 	step "Installing Homebrew Casks"
	# 	while IFS= read -r cask; do
	# 		run brew install $cask
	# 		run rm -rf /opt/homebrew/Caskroom/$cask
	# 	done <${HOME}/.config/yadm/Casks
	# fi

fi
