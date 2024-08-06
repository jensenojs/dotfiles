#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

# https://github.com/tarebyte/dotfiles/blob/0ae07065efde0e167b9395e302bdc8f6f5128c02/.config/yadm/bootstrap%23%23os.Linux#L4

# 包含了一系列用于开发的基本工具和库
info "install Devalopment tools"
run sudo dnf groupinstall -y development-tools

run sudo dnf install -y readline-devel
run sudo dnf install -y SDL2-devel # 开发需要图形、声音或输入处理的应用程序
run sudo dnf install -y llvm-devel # 编译器基础设施项目，提供了与编译器相关的各种工具和库，包括优化器、代码生成器等

# NVIDIA
info "install things about NVIDIA"
run sudo dnf install -y nvidia-gpu-firmware
run sudo dnf install -y akmod-nvidia #"kerner-devel-uname-r == $(uname -r)"
# run sudo modprobe nvidia

note "try nvidia-smi after reboot"

# https://github.com/r0bobo/dotfiles/blob/f64ac7373f589207e1e8ab6e66fd976867075340/.config/yadm/bootstrap.d/10-dnf.sh#L4
packages=(
	# 常用的脚本工具
	gh
	bat # better cat
	fzf
	vim
	zsh
	tmux
	wine
	wget
	btop # better top
	direnv
	neovim
	graphviz
	python3-pip
	fd-find # better find
	ripgrep # better grep
	dconf-editor
	the_silver_searcher # better ack
	# language-serer
	shfmt
	mysql
	#
	rclone
	sysbench
	hyperfine
)


run sudo dnf install -y "${packages[@]}"

step "Install from flatapk, you can view from https://flathub.org"

info "Configure the software source to sjtu"
wget https://mirror.sjtu.edu.cn/flathub/flathub.gpg
sudo flatpak remote-modify --gpg-import=flathub.gpg flathub

# ================================================================================================
# 安装QQ, 腾讯会议
step "Install tecents"
flatpak install -y flathub com.qq.QQ
flatpak install -y flathub com.tencent.wemeet
flatpak install -y flathub com.tencent.WeChat

# ================================================================================================
# Obsidian
step "Install Obsidian"
flatpak install -y flathub md.obsidian.Obsidian

# ================================================================================================
# zotero
step "Install zotero"
flatpak install -y flathub org.zotero.Zotero

# # ================================================================================================
# # VLC
# step "Install VLC"
# flatpak install -y flathub org.videolan.VLC

# ================================================================================================
# 安装 Gnome 优化和扩展应用程序
# https://github.com/r0bobo/dotfiles/blob/main/.config/yadm/bootstrap.d/30-gsettings.sh

step "install Gnome extension"

run sudo dnf install -y gnome-tweaks gnome-extensions-app sassc gnome-themes-extra gtk3-devel gtk4-devel gtk-murrine-engine

# 使用 gsettings 工具来更改 GNOME Shell 的设置。gsettings 是 GNOME 桌面环境用来存储和检索配置数据的低级接口。这些命令通常在脚本中运行以自动化配置过程
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Tab'        #用于切换到下一个标签页
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control><Shift>Tab' #用于切换到上一个标签页
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:menu'                                #设置窗口管理器的按钮布局，mac风格
gsettings set org.gnome.TextEditor keybindings vim # 为 GNOME 文本编辑器设置 Vim 模式的快捷键

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']" # 添加缩放因子的选项

# Calendar
gsettings set org.gnome.desktop.calendar show-weekdate "true"

info "go https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme to config further"
# https://github.com/atomjoy/gnome-desktop/blob/62144f817aa6c49918d8b3af037f82d037367265/themes/Gruvbox-Dark-Theme-Pack/Gruvbox-Dark-BL-MOD/theme-gsettings.sh#L17
# https://github.com/sweetbbak/hyprland-dots/blob/81aefd1597bafa2a8766fe171ab10b444837e27e/.config/hypr/configs/exec.conf#L23
# https://github.com/olafkfreund/nixos_config/blob/96f8f6dd618212d43d61c6b930072e37a6348726/home/desktop/hyprland/default.nix#L80

# 设置 GNOME Shell 使用 gruvbox-dark 主题
# gsettings set org.gnome.desktop.interface gtk-theme 'gruvbox-dark'

# 设置 GNOME 终端使用 gruvbox-dark 主题
# gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles/Default/ use-theme-colors false
# gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles/Default/ palette '#fbf1c7:#cc241d:#98971a:#d79921:#458588:#b16286:#689d6a:#a89984:#928374:#9d0006:#79740e:#b57614:#076678:#8f3f71:#427b58:#3c3836'

#  do these steps manually:
# 1. Install the following GNOME extensions:
#    - Caffeine (https://extensions.gnome.org/extension/517/caffeine/)
#    - Clipboard History (https://extensions.gnome.org/extension/4839/clipboard-history/)
#    - Just Perfection (https://extensions.gnome.org/extension/3843/just-perfection/)

# https://github.com/tmux-plugins/tpm/blob/master/docs/automatic_tpm_installation.md

# ================================================================================================
# 安装neovim 依赖
# https://github.com/gelguy/wilder.nvim/issues/16#issuecomment-547083057
# buggy
run sudo pip3 install pynvim
info "first time enter neovim, need to run :UpdateRemotePlugins"

# step "Install nvim plugins"
# run pip3 install pynvim
# run nvim --headless UpdateRemotePlugin
# run nvim --headless

# 获取当前用户
user=$(whoami)

# 使用 chsh 命令更改默认 shell 为 zsh
run sudo chsh -s /bin/zsh "$user"
