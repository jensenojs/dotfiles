#!/bin/bash

# Fedora Linux 的 Bootstrap 准备脚本
# 此脚本为 Fedora 系统设置基本环境。
# 参考资料:
# - https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
# - https://www.insidentally.com/articles/000028/

source ${HOME}/.config/yadm/utils.sh
source ${HOME}/.config/yadm/constants.sh

# 验证我们是否在正确的操作系统上
system_type=$(uname -s)
if [ "$system_type" = "Linux" ]; then
    if grep -q "Fedora" /etc/os-release; then
        note "准备在 Fedora 上进行 bootstrap"
    else
        error "目前仅支持在 Fedora 上进行 bootstrap"
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

# 对于 Fedora，我们使用 /etc/profile.d/ 来系统级设置 XDG 目录
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
run sudo wget -O /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo
run sudo wget -O /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo
run sudo dnf makecache

# ================================================================================================
# 配置 DNF (Dandified YUM) 软件包管理器

step "配置 /etc/dnf/dnf.conf"
# 如果配置文件不存在则创建
if [ ! -f /etc/dnf/dnf.conf ]; then
    info "正在创建 /etc/dnf/dnf.conf"
    sudo touch /etc/dnf/dnf.conf
fi

# 配置各种 DNF 选项以获得更好的性能和可靠性
sudo sed -i 's/^gpgcheck=.*/gpgcheck=True/' /etc/dnf/dnf.conf                    # 启用 GPG 检查以验证软件包
sudo sed -i 's/^installonly_limit=.*/installonly_limit=3/' /etc/dnf/dnf.conf     # 仅保留 3 个仅安装软件包的版本
sudo sed -i 's/^clean_requirements_on_remove=.*/clean_requirements_on_remove=True/' /etc/dnf/dnf.conf # 删除软件包时清理依赖项
sudo sed -i 's/^skip_if_unavailable=.*/skip_if_unavailable=True/' /etc/dnf/dnf.conf # 跳过不可用的软件包
sudo sed -i 's/^defaultyes=.*/defaultyes=True/' /etc/dnf/dnf.conf                # 对所有提示假设为 "yes"
sudo sed -i 's/^keepcache=.*/keepcache=False/' /etc/dnf/dnf.conf                 # 不保留下载的软件包
sudo sed -i 's/^deltarpm=.*/deltarpm=False/' /etc/dnf/dnf.conf                  # 禁用 Delta RPM 以节省带宽
sudo sed -i 's/^fastestmirror=.*/fastestmirror=False/' /etc/dnf/dnf.conf         # 禁用最快镜像检测
sudo sed -i '/^minrate=/d' /etc/dnf/dnf.conf                                     # 删除任何现有的 minrate 设置
echo "minrate=200k" | sudo tee -a /etc/dnf/dnf.conf >/dev/null                  # 设置最小下载速率

# ================================================================================================
# 启用使用清华大学镜像的 RPM Fusion 仓库

step "启用 RPM Fusion 源"

# 从清华大学镜像安装 RPM Fusion 仓库配置包
run sudo yum install -y --nogpgcheck https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# 更新 RPM Fusion 仓库文件中的基础 URL 以使用清华大学镜像
for file in /etc/yum.repos.d/rpmfusion*.repo; do
    if [ -f "$file" ]; then
        info "使用 sed 替换 $file 以启用清华大学镜像"
        sudo sed -i 's|baseurl=http://download1.rpmfusion.org/|baseurl=https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/|g' "$file"
    fi
done

# ================================================================================================
# 更新系统并清理旧软件包

step "更新系统"

# 更新所有软件包
run sudo dnf update -y && sudo dnf upgrade -y

info "移除旧内核和无用软件包"

# 删除未使用的软件包和旧内核版本
run sudo dnf autoremove -y && sudo dnf remove --oldinstallonly

# ================================================================================================
# 安装和配置 TLP 以进行电源管理

# 安装 TLP 及相关软件包
run sudo dnf install -y tlp tlp-rdw

# 删除冲突的电源管理软件包
run sudo dnf remove -y power-profiles-daemon

# 启用 TLP 服务以在启动时启动
run sudo systemctl enable tlp.service

# 屏蔽冲突的服务以确保 TLP 正常工作
sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

# ================================================================================================
# 配置网络时间协议 (NTP) 以获得准确时间

step "配置网络时间协议"

# 如果尚未备份，则备份 chrony.conf
if ! file_exists /etc/chrony.conf.bak ; then
    sudo cp /etc/chrony.conf /etc/chrony.conf.bak
fi

# 配置 chronyd 以使用中国 NTP 服务器
sed -i 's/^pool.*/pool cn.ntp.org.cn/' /etc/chrony.conf

# 重新启动 chronyd 服务以应用更改
run sudo systemctl restart chronyd

# ================================================================================================
# 启用蓝牙服务

sudo systemctl enable --now bluetooth
