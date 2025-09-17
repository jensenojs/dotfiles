# 提示符配置 - Prompt Configuration

# 初始化 Starship 提示符(现代化、快速、功能丰富)
# 配置文件: ~/.config/starship.toml
if command_exists starship; then
  eval "$(starship init zsh)"
fi

# GPG TTY 设置(用于 git commit 签名等安全操作)
export GPG_TTY=$(tty)
