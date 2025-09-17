#!/bin/bash

# 学习自 https://github.com/gwww/dotfiles/blob/b0fdf99cd24620110f9ded4b6ef3032fe8ea81c9/.config/yadm/bootstrap-utils.sh
# 此文件包含 yadm bootstrap 过程的工具函数。

# 定义终端输出的颜色代码
# \033[ 是 ESC 字符，用于开始一个控制序列。
# \033[ 后面的数字指定了颜色属性。
# 'm' 在末尾应用这些属性。
RED='\033[0;31m'    # 红色，用于错误信息
GREEN='\033[0;32m'  # 绿色，用于信息和成功消息
YELLOW='\033[0;33m' # 黄色，用于警告信息
BLUE='\033[0;34m'   # 蓝色，用于注意事项
PURPLE='\033[0;35m' # 紫色，用于调试信息
NC='\033[0m'        # 无颜色 - 重置为终端默认颜色

# 全局变量
step_number=1
LOG_FILE="${HOME}/yadm_bootstrap.log"
dryrun=0 # 干运行模式标志, 0 = 禁用, 1 = 启用

# 初始化日志系统
# 创建日志文件并将 stdout/stderr 重定向到终端和日志文件
init_logging() {
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
    fi
    # 重定向文件描述符:
    # 3 -> 原始 stdout
    # 4 -> 原始 stderr
    # 1 -> 通过管道传递给 tee 的 stdout (同时写入终端和日志文件)
    # 2 -> 重定向到 stdout 的 stderr (也通过管道传递给 tee)
    exec 3>&1 4>&2 1> >(tee -a "$LOG_FILE") 2>&1
}

# 在脚本开始时初始化日志
init_logging

# 记录指定级别的消息
# 用法: log LEVEL MESSAGE
# 级别: INFO, WARN, ERROR, DEBUG
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)
            printf "${GREEN}[INFO]${NC} [%s] %s\n" "$timestamp" "$message" >&3
            ;;
        WARN)
            printf "${YELLOW}[WARN]${NC} [%s] %s\n" "$timestamp" "$message" >&3
            ;;
        ERROR)
            printf "${RED}[ERROR]${NC} [%s] %s\n" "$timestamp" "$message" >&3
            ;;
        DEBUG)
            printf "${PURPLE}[DEBUG]${NC} [%s] %s\n" "$timestamp" "$message" >&3
            ;;
        *)
            printf "[UNKNOWN] [%s] %s\n" "$timestamp" "$message" >&3
            ;;
    esac
}

# 打印步骤头以跟踪进度
# 用法: step "步骤描述"
step() {
    echo -e "Step ${step_number}: ========== ${1}" >&3
    log "INFO" "开始步骤: $1"
    ((step_number++))
}

# 在开始时询问用户密码以保持 sudo 会话活跃
# 这可以防止脚本在稍后需要 sudo 时暂停
ask_password() {
    note "请输入密码以开始安装"

    # 事先请求 sudo
    sudo -v || {
        echo "请输入 sudo 密码:" >&3
        read -s sudo_password
        sudo -S <<< "$sudo_password"
    }

    # 保持 sudo 会话活跃
    # 来源: https://gist.github.com/cowboy/3118588
    while true; do
        sudo -n true         # 检查 sudo 会话是否仍然有效 (-n 选项)
        sleep 60             # 每 60 秒检查一次
        # kill -0 检查进程(脚本本身)是否仍在运行
        # 如果不在运行，则退出循环(从而结束保活)
        kill -0 "$" || exit
    done 2>/dev/null &    # 在后台运行
}

# 检查命令是否存在(是否可执行)
# 用法: executable_exists command_name
# 返回 0 如果存在, 1 如果不存在
executable_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查文件是否存在
# 用法: file_exists /path/to/file
# 返回 0 如果存在, 1 如果不存在
file_exists() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# 检查目录是否存在
# 用法: directory_exists /path/to/directory
# 返回 0 如果存在, 1 如果不存在
directory_exists() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# 打印注意事项消息
# 用法: note "这是一条注意事项"
note() {
    printf "${BLUE}Note: %s${NC}\n" "$*" >&3
    log "INFO" "Note: $*"
}

# 打印信息消息
# 用法: info "这是一条信息消息"
info() {
    printf "${GREEN}Info: %s${NC}\n" "$*" >&3
    log "INFO" "$*"
}

# 打印警告消息
# 用法: warn "这是一条警告消息"
warn() {
    printf "${YELLOW}Warn: %s${NC}\n" "$*" >&3
    log "WARN" "$*"
}

# 打印错误消息并退出
# 用法: error "这是一条错误消息"
error() {
    printf "${RED}Error: %s${NC}\n" "$*" >&3
    log "ERROR" "$*"
    exit 1
}

# 打印调试消息(仅在 DEBUG=1 时)
# 用法: debug "这是一条调试消息"
debug() {
    if [[ "${DEBUG:-0}" == "1" ]]; then
        printf "${PURPLE}[DEBUG]${NC} %s\n" "$*" >&3
        log "DEBUG" "$*"
    fi
}

# 执行命令并记录日志和处理错误
# 在干运行模式下，仅打印命令而不执行
# 用法: run command arg1 arg2 ...
run() {
    local cmd="$*"
    
    echo "Run: $cmd" >&3
    log "INFO" "正在执行: $cmd"
    
    if [[ $dryrun == 1 ]]; then
        note "干运行: 命令未执行"
        log "INFO" "干运行: 命令未执行"
        return 0
    fi
    
    # 使用 eval 执行命令并捕获 stdout 和 stderr
    if ! eval "$cmd" 2>&1; then
        local exit_code=$?
        log "ERROR" "命令执行失败，退出码 $exit_code: $cmd"
        error "命令执行失败: $cmd (退出码: $exit_code)"
    fi
}

# 使用 bash -c 安全地执行复杂命令
# 适用于包含管道、重定向等的命令
# 在干运行模式下，仅打印命令而不执行
# 用法: run_safe "包含 | 和 > 的复杂命令"
run_safe() {
    local cmd="$*"
    
    echo "Run (safe): $cmd" >&3
    log "INFO" "正在执行 (safe): $cmd"
    
    if [[ $dryrun == 1 ]]; then
        note "干运行: 命令未执行"
        log "INFO" "干运行: 命令未执行"
        return 0
    fi
    
    # 使用 bash -c 执行命令以更好地处理复杂命令
    if ! bash -c "$cmd" 2>&1; then
        local exit_code=$?
        log "ERROR" "命令执行失败，退出码 $exit_code: $cmd"
        error "命令执行失败: $cmd (退出码: $exit_code)"
    fi
}

# 检查是否处于干运行模式
# 用法: if is_dryrun; then ...
is_dryrun() {
    [[ $dryrun == 1 ]]
}
