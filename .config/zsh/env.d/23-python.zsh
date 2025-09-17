# Python 配置 - Python Configuration

# Pip XDG 配置
export PIP_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/pip/pip.conf"
export PIP_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/pip"

# Python 用户基础目录 (默认 ~/.local 已符合 XDG)
export PYTHONUSERBASE="${HOME}/.local"

# 加载 Rye 环境配置
source_if_exists "$HOME/.rye/env"
