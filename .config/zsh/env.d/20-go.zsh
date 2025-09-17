# Go 工具链配置 - Go Toolchain Configuration

# Go 环境变量(符合 XDG 规范)
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GOBIN="${XDG_BIN_HOME:-$HOME/.local/bin}"
export GOMODCACHE="${XDG_CACHE_HOME:-$HOME/.cache}/go/mod"

# 如果 Go 不在 PATH 中，尝试添加标准安装路径
if ! command_exists go; then
  prepend_to_path_if_exists "/usr/local/go/bin"
fi