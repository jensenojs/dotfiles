#!/bin/bash

# study from https://github.com/gwww/dotfiles/blob/b0fdf99cd24620110f9ded4b6ef3032fe8ea81c9/.config/yadm/bootstrap-utils.sh

# Define color codes
# \033[ 也称为 ESC[ 是控制序列引导符 (Control Sequence Introducer, CSI),它告诉终端接下来的字符是控制命令, 后面的内容指定具体的颜色属性, m表示设置模式(即应用这些属性)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'

NC='\033[0m' # 用于重置文本属性到终端的默认设置，从而关闭之前设置的颜色

step_number=1
work_dir=$(mktemp -d /tmp/rebuild.XXXXXX)

function step() {
	# 添加 -e 选项，解析转义字符
	echo -e "Step ${step_number}: ========== ${1}"
	((step_number++))
}

function ask_password() {
	note "Enter your password to begin with the installation"

	# Ask for sudo beforehand, so that the script doesn't halt installation in the
	# later sections.
    sudo -v || {
        echo "Please enter your sudo password:"
        read -s sudo_password
        sudo -S <<< "$sudo_password"
    }


	# Keep sudo session persistent, taken from -- https://gist.github.com/cowboy/3118588
	while true; do
		sudo -n true         # 使用 -n 选项检查当前的 sudo 会话是否仍然有效
		sleep 60             # 每隔 60 秒执行一次检查。
		kill -0 "$$" || exit # 使用 kill -0 检查当前进程（即脚本自身）是否仍然存活，如果进程不存在了就退出循环(也就是结束保活操作)
	done 2>/dev/null &    # 将整个保活操作放在后台执行
}

# 检验某个命令是否可以执行
function executable_exists() {
	command -v "$1" >/dev/null 2>&1
}

# 检验某个路径下的文件是否存在
function file_exists() {
	if [ -f "$1" ]; then
		return 0
	else
		return 1
	fi
}

# 检验某个路径下的目录是否存在
function directory_exists() {
	if [ -d "$1" ]; then
		return 0
	else
		return 1
	fi
}

# 当 $* 不被双引号包围时(即 $*), 它会被扩展为所有的位置参数,
# 这些参数被视为一个单独的字符串, 参数之间由 IFS (内部字段分隔符, 默认为空格、制表符和换行符) 的第一个字符分隔
#
# 对于 $@
#   无论是否被双引号包围，$@ 都会将每个位置参数视为一个独立的字符串, 这个在大多数时候都会更常用
#   这使得在循环或函数调用中传递参数时非常有用，因为它允许参数中的空格和特殊字符被正确处理

function note() {
	printf "${BLUE}Note: %s${NC}\n" "$*"
}

function info() {
	printf "${GREEN}Info: %s${NC}\n" "$*"
}

function warn() {
	printf "${YELLOW}Warn: %s${NC}\n" "$*"
}

function error() {
	printf "${RED}Error: %s${NC}\n" "$*"
	exit 1
}

function run() {
	echo "Run:" $*
	if [[ $dryrun == 1 ]]; then
		note "not execute this command because dryrun is set"
	else
		result=$(eval $* 2>&1)
		if [[ $? -ne 0 ]]; then
			error "failed becase of $result"
		fi
	fi
}

# Usage example
# step "Initialize"
# note "This is a note."
# info "This is an informational message."
# warn "This is a warning."
# error "This is an error message."
