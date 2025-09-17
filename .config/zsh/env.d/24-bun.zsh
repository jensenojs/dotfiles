# Bun JavaScript 运行时 - Bun JavaScript Runtime

# Bun 安装目录(符合 XDG 规范)
export BUN_INSTALL="${XDG_DATA_HOME:-$HOME/.local/share}/bun"

# 加载 Bun 命令补全
source_if_exists "$BUN_INSTALL/_bun"

# 添加 Bun 可执行文件到 PATH
prepend_to_path_if_exists "$BUN_INSTALL/bin"
