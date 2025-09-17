#!/bin/bash

# Ubuntu Linux 的 Bootstrap 准备脚本
# 此脚本为 Ubuntu 系统设置基本环境。

source ${HOME}/.config/yadm/utils.sh
source ${HOME}/.config/yadm/constants.sh

# 验证我们是否在正确的操作系统上
system_type=$(uname -s)
if [ "$system_type" = "Linux" ]; then
    if grep -q "Ubuntu" /etc/os-release; then
        note "准备在 Ubuntu 上进行 bootstrap"
    else
        error "目前仅支持在 Ubuntu 上进行 bootstrap"
    fi
else
    error "不应从该文件进行 bootstrap"
fi

# 创建默认的 Projects 目录
if ! directory_exists "${HOME}/Projects"; then
    run mkdir "${HOME}/Projects"
fi

# ================================================================================================
# 设置 XDG 基础目录规范环境变量
# 这有助于通过组织配置、数据、状态和缓存文件来保持主目录的整洁
# 参见: https://ios.sspai.com/post/90480

# 对于 Ubuntu，我们使用 /etc/profile.d/ 来系统级设置 XDG 目录
target_file="/etc/profile.d/xdg_config.sh"

# 如果文件存在则删除
if file_exists "$target_file"; then
    run sudo rm -f "$target_file"
fi

# 创建文件并添加 XDG 环境变量
run sudo touch "$target_file"
echo 'export XDG_CONFIG_HOME="${HOME}/.config"' | sudo tee -a "$target_file"
echo 'export XDG_DATA_HOME="${HOME}/.local/share"' | sudo tee -a "$target_file"
echo 'export XDG_STATE_HOME="${HOME}/.local/state"' | sudo tee -a "$target_file"
echo 'export XDG_CACHE_HOME="${HOME}/.cache"' | sudo tee -a "$target_file"
sudo chmod +x "$target_file"

# 同时为当前会话导出
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"

# ================================================================================================
# 配置软件包仓库以使用清华大学镜像

step "配置软件源为清华大学镜像"

# 备份原始 sources.list
if ! file_exists "/etc/apt/sources.list.bak"; then
    run sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
fi

# 获取 Ubuntu 版本代号
ubuntu_codename=$(lsb_release -c -s)

# 生成新的 sources.list 内容
sudo tee /etc/apt/sources.list > /dev/null <<EOF
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename} main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename} main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-security main restricted universe multiverse

# 预发布软件源，不建议启用
# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ ${ubuntu_codename}-proposed main restricted universe multiverse
EOF

# 更新软件包列表
run sudo apt update

# ================================================================================================
# 配置 APT 包管理器

step "配置 APT 包管理器"

# 创建 APT 配置目录(如果不存在)
if ! directory_exists "/etc/apt/apt.conf.d"; then
    run sudo mkdir -p /etc/apt/apt.conf.d
fi

# 配置各种 APT 选项以获得更好的性能和可靠性
# 创建配置文件
sudo tee /etc/apt/apt.conf.d/99custom > /dev/null <<EOF
// 启用详细输出
Verbose "1";

// 在安装前下载所有包
APT::Get::Download-Only "false";

// 删除已下载的包文件
APT::Get::Clean "always";

// 安装推荐的包
APT::Install-Recommends "true";

// 安装建议的包
APT::Install-Suggests "false";

// 在删除包时自动删除不需要的依赖
APT::AutoRemove::RecommendsImportant "false";
APT::AutoRemove::SuggestsImportant "false";

// 处理破损的包
APT::Get::Fix-Broken "true";
APT::Get::Fix-Missing "true";
EOF

# ================================================================================================
# 更新系统并清理旧软件包

step "更新系统"

# 更新所有软件包
run sudo apt upgrade -y

info "移除无用软件包"
# 删除未使用的软件包
run sudo apt autoremove -y

# ================================================================================================
# 安装和配置 TLP 以进行电源管理(如果系统是笔记本电脑)

# 检查系统是否为笔记本电脑
if [ -d "/proc/acpi/button/lid" ]; then
    step "安装和配置 TLP 以进行电源管理"
    
    # 安装 TLP 及相关软件包
    run sudo apt install -y tlp tlp-rdw
    
    # 删除冲突的电源管理软件包
    # 在 Ubuntu 上，通常是 power-profiles-daemon 与 TLP 冲突
    run sudo apt remove -y power-profiles-daemon
    
    # 启用 TLP 服务以在启动时启动
    run sudo systemctl enable tlp.service
    
    # 屏蔽冲突的服务以确保 TLP 正常工作
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
fi

# ================================================================================================
# 配置网络时间协议 (NTP) 以获得准确时间

step "配置网络时间协议"

# 在 Ubuntu 上，我们使用 systemd-timesyncd 作为默认的 NTP 客户端
# 启用并启动 systemd-timesyncd 服务
run sudo systemctl enable --now systemd-timesyncd

# 配置 NTP 服务器
# 编辑 /etc/systemd/timesyncd.conf 文件
sudo tee /etc/systemd/timesyncd.conf > /dev/null <<EOF
[Time]
NTP=ntp.aliyun.com cn.ntp.org.cn pool.ntp.org
FallbackNTP=ntp.ubuntu.com
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
EOF

# 重新启动 timesyncd 服务以应用更改
run sudo systemctl restart systemd-timesyncd

# ================================================================================================
# 启用蓝牙服务(如果系统有蓝牙硬件)

# 检查系统是否有蓝牙硬件
if [ -d "/proc/bluetooth" ] || command -v hciconfig > /dev/null 2>&1; then
    step "启用蓝牙服务"
    sudo systemctl enable --now bluetooth
fi