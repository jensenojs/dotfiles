# 插件管理 - Plugin Management (Sheldon)

# ==============================================================================
# Sheldon 配置 - Sheldon Configuration
# ==============================================================================

if command_exists sheldon; then
  # 定义缓存路径
  sheldon_cache="${XDG_CACHE_HOME:-$HOME/.cache}/sheldon/sheldon.zsh"
  sheldon_toml="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"

  # 如果缓存不存在或配置文件更新，重新生成缓存
  # 这是性能优化的关键！避免每次启动都运行 sheldon source
  if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
    mkdir -p "${sheldon_cache:h}"
    sheldon source > "$sheldon_cache"
  fi

  # 加载缓存(非常快)
  source "$sheldon_cache"

  unset sheldon_cache sheldon_toml
else
  echo "⚠️  Sheldon not found. Install with: brew install sheldon"
fi

# ==============================================================================
# 插件特定设置 - Plugin-specific Settings
# ==============================================================================

# you-should-use: 自定义提示消息
export YSU_MESSAGE_FORMAT="💡 Hey! I found this %alias_type for %command: %alias"

# fzf-tab: 配置补全样式
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group '<' '>'
