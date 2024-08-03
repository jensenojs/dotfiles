#!/bin/bash

source ${HOME}/.config/yadm/utils.sh

TMUX_PLUGIN_MANAGER_PATH="${HOME}/.tmux/plugins/tpm"

if ! [ -d "${HOME}/.tmux/plugins/tpm" ]; then
    run git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGIN_MANAGER_PATH"
fi

# 安装tmux 插件管理器
if ! executable_exists tmux; then
    step "bootstrap tmux ..."
    run bash "$TMUX_PLUGIN_MANAGER_PATH/bin/install_plugins"
    run bash "$TMUX_PLUGIN_MANAGER_PATH/bin/update_plugins" all
fi

# 以下是一些好用的 tmux 插件推荐：
# tmux-battery：可以在 tmux 的状态栏中显示当前电池的百分比和状态图标。它能够无缝集成到 tmux 配置中，无需额外安装软件（通常系统中已经预装了依赖），支持 macOS、Linux 以及 Android 模拟器等多种操作系统。
# tmux-sessionist：这是一个轻量级的 tmux 插件，提供了用于操作 tmux 会话的各种实用工具，如通过快捷键prefix+g提示输入会话名称并直接切换（支持智能补全）、按下prefix+c（或shift+c）创建新的命名会话、使用prefix+x（或shift+x）关闭当前会话但不退出 tmux 等。它具有易用性、定制化、扩展性和跨平台等特点。
# tmux-copycat：该插件不仅提供了正则表达式搜索，还支持高亮显示和预定义搜索。它使用 grep 作为后端进行搜索，支持大小写不敏感的字符串和正则表达式，与 tmux-yank 配合使用效果更佳，适用于代码浏览、文件管理、git 操作等场景。
# tmux-yank：一个小巧但功能强大的 tmux 插件，可让 tmux 无缝地与系统的剪贴板进行交互。通过与各种系统剪贴板工具配合，实现在 tmux 会话中直接将文本拷贝到系统剪贴板的功能，支持 Linux、macOS、Cygwin 以及 Windows Subsystem for Linux 等。只需通过简单的前缀键+y 即可完成复制。
# tmux-sidebar：能够快速打开当前路径下的树状目录列表。它利用 tmux 的扩展功能，通过自定义快捷键绑定展示并切换当前工作路径的文件结构，具有速度优化、智能大小调整、一键开关、不打断工作流和保持窗格布局等特点，适用于多窗口环境中查看和导航文件结构等场景。
# tmux-resurrect：自动保存和恢复 tmux 工作环境的插件，通过简单的键绑定（默认为prefix+ctrl-s和prefix+ctrl-r），可以轻松保存和还原包括会话、窗口、panes、工作目录以及它们的顺序等所有细节，甚至能恢复 vim 和 neovim 的会话，适用于任何依赖 tmux 进行日常开发的场景。
# tmux-cpu 和 gpu 状态显示插件：可以在 tmux 的状态栏中自定义显示 cpu 和 gpu 的信息，如使用率、温度等。通过简单配置可选择不同图标和颜色来表示不同级别的负载，其基于 tmux 插件管理器安装和更新，支持各种操作系统，并利用特定命令行工具获取硬件信息。
# tmux-urlview：整合了 urlview 或 extract_url 的功能，在 tmux 环境中添加新的快捷键绑定（默认为 u）后，能将当前会话中的所有 url 列出于底部窗格，方便在浏览文本或代码时迅速捕获并打开其中的 url，适用于开发、运维、日常信息检索等需要在终端中快速访问 url 的场景。
# tmux-powerline：为 tmux 状态栏带来美观且高度可定制的电力线样式显示。它允许创建和管理各种“段”，可以是系统信息、邮件通知、音乐播放信息等，并自动检测目录变更实时反映在状态栏上。采用纯 bash 实现，具有易扩展性、跨平台、低门槛和社区活跃等特点。
# tmux 的插件丰富多样，可以根据个人需求和使用习惯选择适合自己的插件来增强 tmux 的功能和使用体验。安装插件时，通常可以使用 tmux 插件管理器（如 tpm）进行安装，或者按照插件的说明进行手动安装和配置。
# 在安装和使用插件之前，确保已经正确安装了 tmux，并且了解了基本的 tmux 操作和配置方法。同时，不同的插件可能有特定的依赖和配置要求，需要仔细阅读插件的文档以确保正确安装和使用。
