#!/bin/bash
# =============================================================================
# FZF 预览脚本 (Final Version)
# 功能: 目录大小/文件行数 + WezTerm图片 + 智能回退
# =============================================================================

file="$1"
if [ -z "$file" ]; then exit 0; fi

# --- 0. 辅助: 检查命令 ---
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# --- 1. 目录处理 (Directory) ---
if [ -d "$file" ]; then
  # [统计] 文件数
  num_files=$(find "$file" -maxdepth 1 -type f 2>/dev/null | wc -l)
  num_dirs=$(find "$file" -maxdepth 1 -type d 2>/dev/null | wc -l)
  num_dirs=$((num_dirs - 1))
  [ "$num_dirs" -lt 0 ] && num_dirs=0

  # [统计] 目录大小 (使用 du -sh, 加 timeout 防止卡死)
  # macOS 和 Linux 的 du 参数略有不同，这里取通用输出
  if has_cmd timeout; then
    dir_size=$(timeout 1s du -sh "$file" 2>/dev/null | cut -f1)
  else
    dir_size=$(du -sh "$file" 2>/dev/null | cut -f1)
  fi
  [ -z "$dir_size" ] && dir_size="计算中..."

  # [显示头部信息]
  echo -e "\033[1;34m📁 目录: $file\033[0m"
  echo -e "\033[0;33m📊 统计: ${num_files} 文件 | ${num_dirs} 子目录 | \033[1;32m💾 大小: ${dir_size}\033[0m"
  echo "----------------------------------------"

  # [显示内容] 优先 eza -> tree -> ls
  if has_cmd eza; then
    eza --tree --level=2 --color=always --icons --git "$file" | head -200
  elif has_cmd tree; then
    tree -C -L 2 "$file" | head -200
  else
    ls -la --color=always "$file" | head -200
  fi
  exit 0
fi

# --- 2. 文件元数据 (Metadata) ---
# 获取文件大小, 类型, 权限
if [[ "$OSTYPE" == "darwin"* ]]; then
  size=$(stat -f%z "$file" 2>/dev/null)
  perm=$(stat -f%Sp "$file" 2>/dev/null)
else
  size=$(stat -c%s "$file" 2>/dev/null)
  perm=$(stat -c%A "$file" 2>/dev/null)
fi

# 计算人类可读大小
human_size=$(awk -v sum="$size" 'BEGIN {
    hum[1024^3]="GB"; hum[1024^2]="MB"; hum[1024]="KB";
    if (sum<1024) { printf sum " B" } 
    else {
        for (x=1024^3; x>=1024; x/=1024) {
            if (sum>=x) { printf "%.2f %s", sum/x, hum[x]; break }
        }
    }
}')

mime=$(file -b --mime-type "$file")
ext="${file##*.}"
# 兼容性处理：转换为小写
if command -v tr >/dev/null 2>&1; then
  ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
else
  ext="${ext,,}"  # 回退到 bash 语法
fi

# [统计] 行数 (如果是文本文件)
line_info=""
if [[ "$mime" =~ ^text/ ]] || [[ "$mime" == "application/json" ]]; then
  lines=$(wc -l <"$file" 2>/dev/null)
  # 移除空白字符
  lines=${lines// /}
  line_info="| \033[1;36m📝 行数: ${lines} lines\033[0m"
fi

# [显示头部信息]
echo -e "\033[1;32m📄 文件: $file\033[0m"
echo -e "\033[0;33m📏 大小: ${human_size} \033[0;37m| \033[0;35m🔒 权限: ${perm} ${line_info}\033[0m"
echo -e "\033[0;36m🏷️  类型: ${mime}\033[0m"
echo "----------------------------------------"

# --- 3. 智能内容预览 (Content) ---

# [A] 图片 (WezTerm/Chafa)
if [[ "$mime" =~ ^image/ ]]; then
  if has_cmd chafa; then
    img_lines=${FZF_PREVIEW_LINES:-20}  # 默认20行预览高度
    img_lines=$((img_lines - 4))
    [ "$img_lines" -lt 1 ] && img_lines=1
    chafa -s "${FZF_PREVIEW_COLUMNS}x${img_lines}" --animate=false "$file"
    exit 0
  fi
fi

# [B] 压缩包
case "$ext" in
zip | jar | war | ear) has_cmd unzip && unzip -l "$file" && exit 0 ;;
tar | gz | bz2 | xz) has_cmd tar && tar -tf "$file" && exit 0 ;;
7z) has_cmd 7z && 7z l "$file" && exit 0 ;;
esac

# [C] 文档/数据
case "$ext" in
pdf) has_cmd pdftotext && pdftotext -l 10 -nopgbrk -layout "$file" - && exit 0 ;;
json) has_cmd jq && jq -C . "$file" | head -200 && exit 0 ;;
csv) has_cmd csvlook && csvlook "$file" | head -200 && exit 0 ;;
md) has_cmd glow && glow -s dark -w "$FZF_PREVIEW_COLUMNS" "$file" && exit 0 ;;
esac

# [D] 二进制防护
if [[ "$mime" =~ binary ]] && [[ ! "$mime" =~ ^image/ ]]; then
  echo "⚠️  二进制文件，不显示内容"
  exit 0
fi

# [E] 文本回退
if has_cmd bat; then
  bat --color=always --style=numbers --line-range :500 "$file" 2>/dev/null
else
  head -n 500 "$file"
fi
