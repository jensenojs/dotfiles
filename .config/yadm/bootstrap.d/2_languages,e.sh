#!/bin/zsh

# 编程语言安装脚本
# 此脚本安装 Node.js (通过 nvm)、Go 和 Rust。

source ${HOME}/.config/yadm/utils.sh

# 为特定语言的软件包创建目录
mkdir -p ${HOME}/Projects/site-package

# 使用 nvm (Node Version Manager) 安装 Node.js
# coc-nvim 需要 Node.js
if ! executable_exists node; then
	step "正在安装 Node.js ..."

	# 设置 NVM 目录
	if ! directory_exists "${XDG_DATA_HOME}/nvm"; then
		run mkdir "${XDG_DATA_HOME}/nvm"
	else
		run rm -rf "${XDG_DATA_HOME}/nvm"
		run mkdir "${XDG_DATA_HOME}/nvm"
	fi

	# 设置 npm 全局目录
	if ! directory_exists "${HOME}/Projects/site-package/npm"; then
		run mkdir "${HOME}/Projects/site-package/npm"
	else
		run rm -rf "${HOME}/Projects/site-package/npm"
		run mkdir "${HOME}/Projects/site-package/npm"
	fi

	export NVM_DIR="${XDG_DATA_HOME}/nvm"

	# 下载并安装 nvm
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

	# 加载 nvm 并安装最新 LTS 版本的 Node.js
	. "$NVM_DIR/nvm.sh" && nvm install --lts

	# 验证安装
	if executable_exists node; then
		info "node.js 安装成功"
	fi
else
	note "node.js 已安装"
fi

# 安装 Go
if ! executable_exists go; then
	step "正在安装 golang ..."

	# 确定正确的架构
	system_type=$(uname -s)
	if [ "$system_type" = "Darwin" ]; then
		toinstall="darwin-arm64"
	else
		toinstall="linux-amd64"
	fi

	# 设置 Go 目录
	if ! directory_exists "${HOME}/Projects/site-package/go"; then
		run mkdir "${HOME}/Projects/site-package/go"
	else
		run rm -rf "${HOME}/Projects/site-package/go"
		run mkdir "${HOME}/Projects/site-package/go"
	fi

	if ! directory_exists "${XDG_DATA_HOME}/go"; then
		run mkdir "${XDG_DATA_HOME}/go"
	else
		run rm -rf "${XDG_DATA_HOME}/go"
		run mkdir "${XDG_DATA_HOME}/go"
	fi

	# 获取最新的稳定版 Go 版本
	info "正在尝试从 go.dev 获取最新的稳定版 go 版本"
	lastest_stable_go_version=$(curl -s https://go.dev/dl/ | grep -oE 'go[0-9]+\.[0-9]+\.[0-9]+' | head -1)

	info "将安装的 go 版本是 $lastest_stable_go_version，平台是 $toinstall"

	# 下载并安装 Go
	run wget -P "${XDG_DATA_HOME}" "https://go.dev/dl/${lastest_stable_go_version}.${toinstall}.tar.gz"
	run tar -C "${XDG_DATA_HOME}" -xzf "${XDG_DATA_HOME}/${lastest_stable_go_version}.${toinstall}.tar.gz"

	# 验证安装
	if executable_exists ${XDG_DATA_HOME}/go/bin/go; then
		info "golang 安装成功"
	fi

	# 清理
	run rm -f "${XDG_DATA_HOME}/${lastest_stable_go_version}.${toinstall}.tar.gz"
else
	note "go 已安装"
fi

# 使用 rustup 安装 Rust
if ! executable_exists rustc; then
	step "正在安装 rustc ..."

	# 设置 Cargo 和 Rustup 目录
	if ! directory_exists "${HOME}/Projects/site-package/cargo"; then
		run mkdir "${HOME}/Projects/site-package/cargo"
	else
		run rm -rf "${HOME}/Projects/site-package/cargo"
		run mkdir "${HOME}/Projects/site-package/cargo"
	fi

	if ! directory_exists "${XDG_DATA_HOME}/rustup"; then
		run mkdir "${XDG_DATA_HOME}/rustup"
	else
		run rm -rf "${XDG_DATA_HOME}/rustup"
		run mkdir "${XDG_DATA_HOME}/rustup"
	fi

	export CARGO_HOME="${HOME}/Projects/site-package/cargo"
	export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

	# 下载并运行 rustup 安装程序
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

	# 加载 Rust 环境
	. "$CARGO_HOME/env"

	# 验证安装
	if executable_exists rustc; then
		info "rust 安装成功"
	fi
else
	note "rust 已安装"
fi

# Python
# TODO: 考虑使用 pyenv 或其他 Python 版本管理器
# 使用 PYTHONUSERBASE 指定第三方库安装路径
# 这可能不是最好的想法
