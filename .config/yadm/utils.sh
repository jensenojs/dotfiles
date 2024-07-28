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
	print $TERTIARY "\nEnter your password to begin with the installation\n"

	# Ask for sudo beforehand, so that the script doesn't halt installation in the
	# later sections.
	sudo -v

	# Keep sudo session persistent, taken from -- https://gist.github.com/cowboy/3118588
	while true; do
		sudo -n true
		sleep 60
		kill -0 "$$" || exit
	done 2>/dev/null &
}

# 检验某个命令是否可以执行
function executab地le_exists() {
	command -v "$1" >/dev/null 2>&1
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
	if [[ $dryrun == 0 ]]; then
		eval $*
	fi
}

# Usage example
# step "Initialize"
# note "This is a note."
# info "This is an informational message."
# warn "This is a warning."
# error "This is an error message."
