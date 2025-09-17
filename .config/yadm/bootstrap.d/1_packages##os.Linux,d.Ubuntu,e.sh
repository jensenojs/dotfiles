#!/bin/bash

# Ubuntu Linux 的软件包安装脚本
# 此脚本使用 APT 安装软件包。

source ${HOME}/.config/yadm/utils.sh

# 更新软件包列表
step "更新 APT 软件包列表"
run sudo apt update

# 升级已安装的软件包
step "升级已安装的软件包"
run sudo apt upgrade -y

# 安装开发工具和库
info "安装开发工具"
run sudo apt install -y build-essential man gcc-doc gdb libreadline-dev libsdl2-dev cmake pkg-config

# 安装系统工具
info "安装系统工具"
run sudo apt install -y htop tree jq fzf ripgrep fd-find

# 安装编程语言环境
info "安装编程语言环境"
run sudo apt install -y python3 python3-pip nodejs npm

# 安装其他有用的工具
# TODO : neovim 需要手动安装
info "安装其他有用的工具"
run sudo apt install -y zsh tmux openssh-server neovim

# 安装 neovim 依赖
info "安装 neovim 依赖"
run sudo pip3 install pynvim

# 执行自动清理
step "清理 APT 缓存"
run sudo apt autoremove -y
run sudo apt clean

