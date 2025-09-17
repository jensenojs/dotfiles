# Node.js 配置 - Node.js Configuration
# 使用 fnm (Fast Node Manager) 替代 NVM，性能提升 ~40x
# 安装: brew install fnm
# 迁移: fnm install <version>

export FNM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"

# NPM XDG 配置
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"

# 初始化 fnm(自动根据 .node-version 或 .nvmrc 切换版本)
if command_exists fnm; then
  eval "$(fnm env --use-on-cd)"
fi

# 添加 npm 全局包到 PATH
prepend_to_path_if_exists "${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin"
