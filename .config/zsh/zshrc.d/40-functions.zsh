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
