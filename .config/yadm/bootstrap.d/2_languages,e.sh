#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

# 安装node.js, coc-nvim 需要它
if ! executable_exists node; then
	step "Installing Node.js ..."

	if ! directory_exists "${XDG_DATA_HOME}/nvm"; then
		run mkdir "${XDG_DATA_HOME}/nvm"
	else
		run rm -rf "${XDG_DATA_HOME}/nvm"
		run mkdir "${XDG_DATA_HOME}/nvm"
	fi

	if ! directory_exists "${HOME}/Projects/npm"; then
		run mkdir "${HOME}/Projects/npm"
	else
		run rm -rf "${HOME}/Projects/npm"
		run mkdir "${HOME}/Projects/npm"
	fi

	export NVM_DIR="${XDG_DATA_HOME}/nvm"

	# layouts.download.codeBox.installsNvm
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

	. "$NVM_DIR/nvm.sh" && nvm install --lts

	# Your user’s .npmrc file (${HOME}/.npmrc)
	# has a `globalconfig` and/or a `prefix` setting, which are incompatible with nvm.
	# Run `nvm use --delete-prefix v22.5.1` to unset it.
	# Creating default alias: default -> 22 (-> v22.5.1)
	# run npm config set prefix "${HOME}/Projects/npm"

	if executable_exists node; then
		info "node.js install successfully"
	fi

else
	note "node.js already installed"
fi

# 安装golang
if ! executable_exists go; then
	step "Installing golang ..."

	system_type=$(uname -s)
	if [ "$system_type" = "Darwin" ]; then
		toinstall="darwin-arm64"
	else
		toinstall="linux-amd64"
	fi

	if ! directory_exists "${HOME}/Projects/go"; then
		run mkdir "${HOME}/Projects/go"
	else
		run rm -rf "${HOME}/Projects/go"
		run mkdir "${HOME}/Projects/go"
	fi

	# 得到最新的稳定版本的编号
	info "trying to get lastest statle go version from go.dev"
	lastest_stable_go_version=$(curl -s https://go.dev/dl/ | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | head -1)

	info "to install go version is $lastest_stable_go_version on $toinstall"

	# 下载安装包
	run wget -P "${XDG_DATA_HOME}" "https://go.dev/dl/${lastest_stable_go_version}.${toinstall}.tar.gz"

	if file_exists "${XDG_DATA_HOME}/go"; then
		run sudo rm -rf "${XDG_DATA_HOME}/go"
	fi

	run tar -C "${XDG_DATA_HOME}" -xzf "${lastest_stable_go_version}.${toinstall}.tar.gz"

	if executable_exists ${XDG_DATA_HOME}/go/bin/go; then
		info "golang install successfully"
	fi

	run rm -f "${XDG_DATA_HOME}/${lastest_stable_go_version}.${toinstall}.tar.gz"

else
	note "go already installed"
fi

# 安装rust
if ! executable_exists rustc; then
	step "Installing rustc ..."

	if ! directory_exists "${HOME}/Projects/cargo"; then
		run mkdir "${HOME}/Projects/cargo"
	else
		run rm -rf "${HOME}/Projects/cargo"
		run mkdir "${HOME}/Projects/cargo"
	fi

	if ! directory_exists "${XDG_DATA_HOME}/rustup"; then
		run mkdir "${XDG_DATA_HOME}/rustup"
	else
		run rm -rf "${XDG_DATA_HOME}/rustup"
		run mkdir "${XDG_DATA_HOME}/rustup"
	fi

	export CARGO_HOME="${HOME}/Projects/cargo"
	export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

	# 将rust装载入环境变量
	. "$CARGO_HOME/env"

	if executable_exists rustc; then
		info "rust install successfully"
	fi
else
	note "rust already installed"
fi

# python
# todo
# 用 PYTHONUSERBASE 来指定第三方库的安装路径
# 万一这不见得是个好主意呢
