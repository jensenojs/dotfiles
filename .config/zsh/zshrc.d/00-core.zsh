# Zsh 核心配置 - Core Zsh Settings

# ==============================================================================
# 历史记录配置 - History Configuration
# ==============================================================================

# 创建历史记录目录(如果不存在)
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"

# 历史记录文件位置(符合 XDG 规范)
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000

# ==============================================================================
# Zsh 选项 - Zsh Options
# ==============================================================================

# 目录导航
setopt autocd              # 省略 cd 命令直接切换目录

# 文件匹配
setopt extendedglob        # 启用扩展的文件匹配模式
setopt numericglobsort     # 按数字顺序排序文件

# 用户界面
setopt nobeep              # 禁用提示音

# 历史记录选项
setopt histappend                # 总是追加历史记录
setopt HIST_SAVE_NO_DUPS         # 不保存重复的历史条目
setopt hist_ignore_space         # 忽略以空格开头的命令
setopt share_history             # 在会话间共享历史记录
setopt hist_expire_dups_first    # 历史记录满时优先删除重复项
