# PATH 基础配置 - Base PATH Configuration
# 添加常用的用户路径

# 添加 XDG 标准的用户可执行文件目录
prepend_to_path_if_exists "$XDG_BIN_HOME"

# 添加 /usr/local/bin(某些工具的默认安装位置)
prepend_to_path_if_exists "/usr/local/bin"
