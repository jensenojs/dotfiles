# 命令别名 - Command Aliases

# ==============================================================================
# Editor Aliases
# ==============================================================================

alias ni='nvim'
alias vi='vim'
alias nf="fzf --bind 'enter:become(nvim {})'" # Open file in nvim via fzf
alias cf='cd $(find * -type d | fzf)'         # Change to directory via fzf

# ==============================================================================
# Shell Management
# ==============================================================================

alias reprofile='source ~/.zshenv; source $ZDOTDIR/.zshrc'
alias _=sudo

# ==============================================================================
# Development Tools
# ==============================================================================

# --- Git FZF 增强 ---
# gfp (Git File Preview): 浏览文件并查看其 Git 提交历史
# 原理: 列出所有 Git 管理的文件 -> 传给 fzf -> 预览窗口显示该文件的 git log
# alias gfp="git ls-files | fzf --preview 'git log --oneline --color=always -n 10 -- {}' --preview-window 'right:60%' --header 'Git File History'"

# glp (Git Log Preview): 交互式搜索 Commit
# 原理: 显示 git log -> fzf 搜索 -> 预览该 Commit 的具体改动 (diff)
# alias glp="git log --oneline --color=always | fzf --ansi --no-sort --preview 'git show --color=always {1}' --preview-window 'right:60%' --bind 'enter:execute(git show {1} | less -R)'"

# Python
alias pip='pip3'
alias python='python3'

# thefuck
alias fk="thefuck"

# ==============================================================================
# Safety Aliases (Interactive Mode)
# ==============================================================================

# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# ==============================================================================
# ls Improvements (BSD vs GNU)
# ==============================================================================

if [[ "$OSTYPE" == darwin* ]]; then
  # macOS (BSD ls)
  alias ls='ls -G'
  alias ll='ls -alF'
  alias la='ls -A'
  alias l='ls -CF'
else
  # Linux (GNU ls)
  alias ls='ls --color=auto'
  alias ll='ls -alF --color=auto'
  alias la='ls -A --color=auto'
  alias l='ls -CF --color=auto'
fi

# ==============================================================================
# grep with Colors
# ==============================================================================

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ==============================================================================
# Common Shortcuts
# ==============================================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='history'
alias j='jobs -l'
alias path='print -l $path'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

alias tf='tail -f'

# ==============================================================================
# System Information
# ==============================================================================

# 内存信息
if command_exists free; then
  alias meminfo='free -m -l -t'
elif command_exists vm_stat; then
  alias meminfo='vm_stat'
fi


# CPU 信息
if command_exists lscpu; then
  alias cpuinfo='lscpu'
elif is_macos && command_exists sysctl; then
  alias cpuinfo='sysctl -a | grep machdep.cpu'
fi

# 磁盘使用
alias diskusage='df -h'
if is_linux; then
  alias folderusage='du -h --max-depth=1'
else
  alias folderusage='du -hd 1'
fi

# Process search
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# ==============================================================================
# Modern Tool Replacements
# ==============================================================================

# 现代工具替代品
command_exists bat && alias cat='bat'
command_exists colormake && alias make='colormake'
command_exists gping && alias ping='gping'
command_exists ip && alias ip='ip -color=auto'
command_exists lnav && alias tf='lnav'

# ==============================================================================
# Tool Compatibility Aliases (Migration Support)
# ==============================================================================

# Node.js 版本管理器迁移支持 - fnm (替代 nvm)
# 注意：fnm 比 nvm 快 ~40x，但命令基本兼容
# 建议：熟悉 fnm 后可以删除此别名，直接使用 fnm 命令
if command_exists fnm; then
  alias nvm='fnm' # 向后兼容别名，提示使用新工具
  # 可选：添加使用提示(取消注释启用)
  # nvm() {
  #   echo "💡 提示：正在使用 fnm(推荐替代 nvm)" >&2
  #   fnm "$@"
  # }
fi
