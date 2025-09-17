#!/usr/bin/env zsh
# Zsh 补全性能诊断脚本
# 用法: source ~/.config/zsh/debug-completion.zsh

echo "🔍 Zsh 补全性能诊断"
echo "===================="
echo ""

# 1. 检查 fzf-tab 是否启用
echo "1️⃣ 检查 fzf-tab 插件:"
if zstyle -L ':fzf-tab:*' &>/dev/null; then
    echo "   ✅ fzf-tab 已加载"
    echo "   💡 提示: fzf-tab 在大目录/复杂补全时可能较慢"
else
    echo "   ❌ fzf-tab 未加载"
fi
echo ""

# 2. 检查补全缓存
echo "2️⃣ 检查补全缓存:"
zcompdump_file="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -f "$zcompdump_file" ]]; then
    zcompdump_age=$(( $(date +%s) - $(stat -f %m "$zcompdump_file") ))
    echo "   📁 缓存文件: $zcompdump_file"
    echo "   ⏰ 文件年龄: $((zcompdump_age / 86400)) 天"
    if [[ $zcompdump_age -gt 604800 ]]; then
        echo "   ⚠️  缓存超过 7 天，建议重新生成"
    else
        echo "   ✅ 缓存较新"
    fi
else
    echo "   ❌ 缓存文件不存在"
fi
echo ""

# 3. 测试补全速度
echo "3️⃣ 测试补全性能:"
echo "   测试中..."

# 测试简单文件补全
test_dir=$(mktemp -d)
touch "$test_dir"/test{1..100}.txt
cd "$test_dir" || exit

time_start=$(date +%s.%N)
# 模拟补全
_wanted files expl 'files' _files &>/dev/null
time_end=$(date +%s.%N)
completion_time=$(echo "$time_end - $time_start" | bc)

echo "   ⏱️  100个文件的补全耗时: ${completion_time}s"
if (( $(echo "$completion_time > 0.5" | bc -l) )); then
    echo "   ⚠️  补全较慢 (>0.5s)"
else
    echo "   ✅ 补全速度正常"
fi

# 清理
cd - > /dev/null
rm -rf "$test_dir"
echo ""

# 4. 列出加载的补全函数
echo "4️⃣ 已加载的补全函数 (前 10 个):"
compdef | head -10
echo "   💡 共 $(compdef | wc -l) 个补全函数"
echo ""

# 5. 优化建议
echo "📋 优化建议:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 快速修复:"
echo "   1. 重新生成补全缓存:"
echo "      rm ~/.config/zsh/.zcompdump*"
echo "      exec zsh"
echo ""
echo "   2. 临时禁用 fzf-tab 测试:"
echo "      在 ~/.config/sheldon/plugins.toml 中注释掉 [plugins.fzf-tab]"
echo "      sheldon lock --update && exec zsh"
echo ""
echo "   3. 排除慢速目录补全:"
echo "      zstyle ':completion:*' accept-exact '*(N)'"
echo ""
echo "⚡ 性能优化:"
echo "   4. 限制补全候选数量:"
echo "      zstyle ':completion:*' max-matches 50"
echo ""
echo "   5. 缓存补全结果:"
echo "      zstyle ':completion:*' use-cache on"
echo "      zstyle ':completion:*' cache-path ~/.cache/zsh/zcompcache"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
