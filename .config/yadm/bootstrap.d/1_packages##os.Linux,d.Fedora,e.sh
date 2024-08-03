#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

# https://github.com/tarebyte/dotfiles/blob/0ae07065efde0e167b9395e302bdc8f6f5128c02/.config/yadm/bootstrap%23%23os.Linux#L4

# 包含了一系列用于开发的基本工具和库
info "install Devalopment tools"
run sudo dnf groupinstall -y "Development Tools"

run sudo dnf install -y readline-devel
run sudo dnf install -y SDL2-devel # 开发需要图形、声音或输入处理的应用程序
run sudo dnf install -y llvm-devel # 编译器基础设施项目，提供了与编译器相关的各种工具和库，包括优化器、代码生成器等


# NVIDIA
info "install things about NVIDIA"
run sudo dnf install nvidia-gpu-firmware
run sudo dnf install -y akmod-nvidia
run sudo modprobe nvidia

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
	fd-find # better find
	ripgrep # better grep
    dconf-editor
	the_silver_searcher # better ack
	# language-serer
    shfmt
    mysql
	rclone
	kubectl
    sysbench
	hyperfine
)

run sudo dnf install -y "${packages[@]}"


# ================================================================================================

# ================================================================================================
# 安装vscode
step "Install vscode"
run sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
run sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
run sudo dnf install -y code

# ================================================================================================
# 安装 Gnome 优化和扩展应用程序
# https://github.com/r0bobo/dotfiles/blob/main/.config/yadm/bootstrap.d/30-gsettings.sh

step "install Gnome extension"

run sudo dnf install gnome-tweaks gnome-extensions-app sassc murrine-engine gnome-themes-extra gtk-murrine-engine

# 使用 gsettings 工具来更改 GNOME Shell 的设置。gsettings 是 GNOME 桌面环境用来存储和检索配置数据的低级接口。这些命令通常在脚本中运行以自动化配置过程
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ next-tab '<Control>Tab'        #用于切换到下一个标签页
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ prev-tab '<Control><Shift>Tab' #用于切换到上一个标签页
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'                             #设置窗口管理器的按钮布局，这里设置为：应用菜单、最小化、最大化、关闭
# gsettings set org.gnome.desktop.interface enable-animations false
gsettings set org.gnome.desktop.wm.keybindings maximize ['<Super>k']                         # 设置窗口最大化的快捷键为 Super + k
gsettings set org.gnome.desktop.wm.keybindings unmaximize ['<Super>j']                       # 设置窗口还原（取消最大化）的快捷键为 Super + j
gsettings set org.gnome.mutter.keybindings toggle-tiled-right ['<Super>l']                   # 设置将窗口平铺到右侧的快捷键为 Super + l
gsettings set org.gnome.mutter.keybindings toggle-tiled-left ['<Super>h']                    # 设置将窗口平铺到左侧的快捷键为 Super + h
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right ['<Control><Super>l'] # 设置将窗口移动到右侧工作区的快捷键为 Ctrl + Super + l
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left ['<Control><Super>h']  # 设置将窗口移动到左侧工作区的快捷键为 Ctrl + Super + h
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 ['<Super>1']            # 设置切换到第一个工作区的快捷键为 Super + 1
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 ['<Super>2']
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 ['<Super>3']
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 ['<Super>4']
gsettings set org.gnome.TextEditor keybindings vim # 为 GNOME 文本编辑器设置 Vim 模式的快捷键

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