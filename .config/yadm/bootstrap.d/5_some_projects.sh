#!/bin/zsh

# 项目目录创建脚本
# 此脚本在 ~/Projects 下创建常见的项目目录。

source ${HOME}/.config/yadm/utils.sh

# 切换到 Projects 目录
run cd ~/Projects

# 创建常见的项目目录
run mkdir -p Databases  # 用于数据库相关项目
run mkdir -p Paper      # 用于研究论文和文档
run mkdir -p Labs       # 用于实验项目和代码片段
run mkdir -p scripts    # 用于工具脚本
run mkdir -p quant      # 用于量化分析项目
