# Homebrew 包管理器配置 - Homebrew Package Manager
# 支持 Apple Silicon 和 Intel Mac

if is_macos; then
  # 按顺序检测 Homebrew 安装位置并初始化
  for brew_path in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_path" ]]; then
      eval "$("$brew_path" shellenv)"
      break
    fi
  done
fi
