# Zsh 补全系统优化 - Completion System Optimization

# ==============================================================================
# 补全缓存 - Completion Cache
# ==============================================================================

# 启用补全缓存(加速重复补全)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# 创建缓存目录
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# ==============================================================================
# 补全行为优化 - Completion Behavior
# ==============================================================================

# 限制补全候选数量(避免在大目录中卡顿)
zstyle ':completion:*' max-matches 50

# 快速接受精确匹配(不等待其他候选)
zstyle ':completion:*' accept-exact '*(N)'

# 补全时忽略已存在的参数
zstyle ':completion:*' ignore-duplicate

# 补全菜单选择
zstyle ':completion:*' menu select

# ==============================================================================
# 补全显示优化 - Completion Display
# ==============================================================================

# 分组显示补全结果
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- 没有匹配 --%f'

# 使用 LS_COLORS 为补全着色
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ==============================================================================
# 特定命令优化 - Command-specific Optimization
# ==============================================================================

# Git 补全优化(只显示最近的分支)
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-*:*' recent-branches-only yes

# 路径补全优化
zstyle ':completion:*' path-completion true
zstyle ':completion:*' special-dirs true

# ==============================================================================
# fzf-tab 优化(如果启用)
# ==============================================================================

# 限制 fzf-tab 的预览大小
zstyle ':fzf-tab:complete:*' fzf-preview 'head -100 $realpath 2>/dev/null'

# fzf-tab 快捷键
zstyle ':fzf-tab:*' switch-group '<' '>'

# 禁用 continuous-trigger 避免误触发(可选，如果经常误触发路径补全)
# zstyle ':fzf-tab:*' continuous-trigger ''

# 在特定慢速命令中禁用 fzf-tab
# 如果 cd/ls 补全很慢，可以启用下面的配置
# zstyle ':fzf-tab:complete:cd:*' disabled-on files
# zstyle ':fzf-tab:complete:ls:*' disabled-on files

# 针对特定大目录禁用 fzf-tab(示例)
# zstyle ':fzf-tab:complete:cd:*:*node_modules*' disabled-on files
# zstyle ':fzf-tab:complete:cd:*:*/usr/bin*' disabled-on files

# Git 补全优化：禁用预览加速
zstyle ':fzf-tab:complete:git-checkout:*' fzf-flags --no-preview
zstyle ':fzf-tab:complete:git-*:*' fzf-min-height 15

# 限制 fzf 显示行数(避免大量候选卡顿)
zstyle ':fzf-tab:*' fzf-flags --height=15 --reverse
