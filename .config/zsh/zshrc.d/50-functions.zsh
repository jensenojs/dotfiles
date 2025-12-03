# 自定义 Shell 函数 - Custom Shell Functions

# ==============================================================================
# Yazi 文件管理器集成 - Yazi Integration
# ==============================================================================

# ya - 带目录切换支持的 Yazi 文件管理器
# 退出 yazi 时，shell 会自动切换到最后所在的目录
function ya() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# [bak] 快速备份文件
# 用法: bak filename -> 创建 filename.bak
# 增强: 如果文件是 filename.bak，自动还原为 filename
bak() {
  local file=$1
  if [[ -z "$file" ]]; then
    echo "用法: bak <filename>"
    return 1
  fi

  if [[ "$file" == *.bak ]]; then
    # 还原模式: remove .bak
    local new_name="${file%.bak}"
    echo "♻️  Restoring: $file -> $new_name"
    cp -i "$file" "$new_name"
  else
    # 备份模式: add .bak
    echo "💾 Backing up: $file -> $file.bak"
    cp -i "$file" "$file.bak"
  fi
}

# [mkcd] 创建目录并立即进入
# 这是一个非常经典的组合操作
mkcd() {
  if [[ -z "$1" ]]; then
    echo "用法: mkcd <directory>"
    return 1
  fi
  mkdir -p "$@" && cd "$_"
}

# [extract] 万能解压函数
# 根据扩展名自动选择解压命令，无需记忆 tar 的参数
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file>"
    return 1
  fi

  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xvjf "$1"    ;;
      *.tar.gz)    tar xvzf "$1"    ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xvf "$1"     ;;
      *.tbz2)      tar xvjf "$1"    ;;
      *.tgz)       tar xvzf "$1"    ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.xz)        unxz "$1"        ;;
      *.tar.xz)    tar xvJf "$1"    ;;
      *)           echo "❌ Unknown archive format: $1" ;;
    esac
  else
    echo "❌ File not found: $1"
  fi
}

hostip=127.0.0.1
port=7890

PROXY_HTTP="http://${hostip}:${port}"

set_proxy() {
  export http_proxy="${PROXY_HTTP}"
  export HTTP_PROXY="${PROXY_HTTP}"
  export https_proxy="${PROXY_HTTP}"
  export HTTPS_proxy="${PROXY_HTTP}"
  git config --global http.proxy "${PROXY_HTTP}"
  git config --global https.proxy "${PROXY_HTTP}"
}

unset_proxy() {
  unset http_proxy
  unset HTTP_PROXY
  unset https_proxy
  unset HTTPS_PROXY
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

test_proxy() {
  echo "Host ip:" ${hostip}
  echo "Current proxy:" $https_proxy
}

