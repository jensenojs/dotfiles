#!/bin/bash

# https://mirrors.tuna.tsinghua.edu.cn/help/fedora/
# https://www.insidentally.com/articles/000028/
source ${HOME}/.config/yadm/utils.sh

system_type=$(uname -s)
if [ "$system_type" = "Linux" ]; then
    if grep -q "Fedora" /etc/os-release; then
        note "prepare to bootstrap on Fedora"
    else
        error "currently, only support bootstrap Fedora"
    fi
else
    error "should not bootstrap from this file"
fi

if ! directory_exists "${HOME}/Projects"; then
    run mkdir "${HOME}/Projects"
fi

# ================================================================================================
# 设置 XDG_CONFIG_HOME、XDG_DATA_HOME 以及 XDG_STATE_HOME 等, 尽可能将配置文件梳理干净
# https://ios.sspai.com/post/90480

# 检查操作系统类型
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    if grep -q "Ubuntu" /etc/os-release; then
        target_file="/etc/environment"
    elif grep -q "Fedora" /etc/os-release; then
        target_file="/etc/profile.d/xdg_config.sh"
    else
        error "Unsupported Linux distribution. Exiting."
    fi
else
    error "Unsupported operating system. Exiting."
fi

# 检查文件是否存在
if file_exists "$target_file"; then
    run sudo rm -f "$target_file"
fi

run sudo touch "$target_file"

# 创建并写入内容
sudo touch "/etc/profile.d/xdg_config.sh"
echo 'export XDG_CONFIG_HOME="${HOME}/.config"' | sudo tee -a "/etc/profile.d/xdg_config.sh"
echo 'export XDG_DATA_HOME="${HOME}/.local/share"' | sudo tee -a "/etc/profile.d/xdg_config.sh"
echo 'export XDG_STATE_HOME="${HOME}/.local/state"' | sudo tee -a "/etc/profile.d/xdg_config.sh"
echo 'export XDG_CACHE_HOME="${HOME}/.cache"' | sudo tee -a "/etc/profile.d/xdg_config.sh"
sudo chmod +x /etc/profile.d/xdg_config.sh

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"

# ================================================================================================
# 设置软件源

step "Configure the software source to tsinghua"
run sudo wget -O /etc/yum.repos.d/fedora.repo http://mirrors.aliyun.com/repo/fedora.repo
run sudo wget -O /etc/yum.repos.d/fedora-updates.repo http://mirrors.aliyun.com/repo/fedora-updates.repo
run sudo dnf makecache

# not maintain
# sudo sed -e 's|^metalink=|#metalink=|g' \
#     -e 's|^#baseurl=http://download.example/pub/fedora/linux|baseurl=https://mirrors.tuna.tsinghua.edu.cn/fedora|g' \
#     -i.bak \
#     /etc/yum.repos.d/fedora.repo \
#     /etc/yum.repos.d/fedora-updates.repo

# sudo dnf config-manager --add-repo https://repo.vivaldi.com/stable/vivaldi-fedora.repo
# sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# ================================================================================================
# 配置 DNF

step "Configuring /etc/dnf/dnf.conf"
# 检查配置文件是否存在，如果不存在则创建
if [ ! -f /etc/dnf/dnf.conf ]; then
    info "Creating /etc/dnf/dnf.conf"
    sudo touch /etc/dnf/dnf.conf
fi

sudo sed -i 's/^gpgcheck=.*/gpgcheck=True/' /etc/dnf/dnf.conf                                         # 启用 GPG 校验，确保软件包的来源是可信的
sudo sed -i 's/^installonly_limit=.*/installonly_limit=3/' /etc/dnf/dnf.conf                          #指定可以同时保留的同一软件包的不同版本数量为 3
sudo sed -i 's/^clean_requirements_on_remove=.*/clean_requirements_on_remove=True/' /etc/dnf/dnf.conf #在移除软件包时清理相关依赖
sudo sed -i 's/^skip_if_unavailable=.*/skip_if_unavailable=True/' /etc/dnf/dnf.conf                   # 在移除软件包时清理相关依赖
sudo sed -i 's/^defaultyes=.*/defaultyes=True/' /etc/dnf/dnf.conf                                     #在交互时默认回答“是”
sudo sed -i 's/^keepcache=.*/keepcache=False/' /etc/dnf/dnf.conf                                      #不保留下载的软件包缓存
sudo sed -i 's/^deltarpm=.*/deltarpm=False/' /etc/dnf/dnf.conf                                        # 不启用增量 RPM（节省空间的一种方式）
sudo sed -i 's/^fastestmirror=.*/fastestmirror=False/' /etc/dnf/dnf.conf                              #不启用自动选择最快的镜像源
sudo sed -i '/^minrate=/d' /etc/dnf/dnf.conf                                                          # 删除可能存在的 minrate 行
echo "minrate=200k" | sudo tee -a /etc/dnf/dnf.conf >/dev/null

# ================================================================================================
# 更换 RPM Fusion 软件源

step "enable RPM Fusion source"

run sudo yum install -y --nogpgcheck https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

for file in /etc/yum.repos.d/rpmfusion*.repo; do
    if [ -f "$file" ]; then
        info "use sed to replace $file to enable tsinghua mirrors"
        sudo sed -i 's|baseurl=http://download1.rpmfusion.org/|baseurl=https://mirrors.tuna.tsinghua.edu.cn/rpmfusion/|g' "$file"
    fi
done

# ================================================================================================
# 更新系统, 删除旧的内核以及其他不需要的旧软件包

step "update system"

run sudo dnf update -y && sudo dnf upgrade -y

info "remove old kernel and useless package"

run sudo dnf autoremove -y && sudo dnf remove --oldinstallonly

# ================================================================================================
# 安装用于电池健康管理的 TLP

run sudo dnf install -y tlp tlp-rdw
# 卸载有冲突的 power-profiles-daemon 软件包
run sudo dnf remove -y power-profiles-daemon
# 设置开机启动 TLP 的服务
run sudo systemctl enable tlp.service
# 屏蔽以下服务以避免冲突，确保 TLP 的无线设备(蓝牙、wifi等)切换选项的能够正确操作
sudo sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket

# ================================================================================================
# 配置 NTP 以获得准确的时间

step "config Network Time Protocol"

# 检查是否存在 chrony.conf.bak，如果不存在则备份
if ! file_exists /etc/chrony.conf.bak ; then
    sudo sudo cp /etc/chrony.conf /etc/chrony.conf.bak
fi

# 使用 sed 命令修改 pool 的值
sed -i '/^pool.*/pool cn.ntp.org.cn/' /etc/chrony.conf

# 重新启动 chronyd 服务以使更改生效
run sudo systemctl restart chronyd

# ================================================================================================
# 启动蓝牙
sudo systemctl enable --now bluetooth
