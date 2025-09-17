# 本地环境变量覆盖 - Local Environment Overrides
# 此文件在所有其他环境配置之后加载
# 可以覆盖或添加机器特定的环境变量

# 加载机器特定的环境配置(如果存在)
source_if_exists "$HOME/.local/bin/env"

source_if_exists "$HOME/.config/secrets/llm"