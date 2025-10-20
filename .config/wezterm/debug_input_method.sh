#!/bin/bash

# 输入法按键调试脚本
# 用于诊断中文输入法下的 Leader 键问题

echo "=========================================="
echo "WezTerm 输入法调试工具"
echo "=========================================="
echo ""

# 检查 im-select 是否可用
if ! command -v im-select &> /dev/null; then
    echo "❌ im-select 未安装"
    echo "安装方法: brew install im-select"
    exit 1
fi

echo "✅ im-select 已安装"
echo ""

# 显示当前输入法
echo "📌 当前输入法:"
current_im=$(im-select)
echo "   $current_im"
echo ""

# 常见输入法列表
echo "📋 常见输入法 ID:"
echo "   com.apple.keylayout.ABC              - ABC 键盘（英文）"
echo "   com.apple.keylayout.US               - 美国键盘（英文）"
echo "   com.apple.inputmethod.SCIM.ITABC     - 简体拼音"
echo "   com.apple.inputmethod.TCIM.Cangjie   - 仓颉"
echo ""

# 测试说明
echo "=========================================="
echo "🔍 调试步骤"
echo "=========================================="
echo ""
echo "1. 重载 WezTerm 配置 (Cmd+r)"
echo "   - 现在 debug_key_events 已启用"
echo "   - 所有按键事件会显示在终端"
echo ""
echo "2. 在英文输入法下测试:"
echo "   - 切换到英文输入法"
echo "   - 按 Ctrl+, (你的 Leader 键)"
echo "   - 观察终端输出的按键事件"
echo ""
echo "3. 在中文输入法下测试:"
echo "   - 切换到中文输入法"
echo "   - 按 Ctrl+, (你的 Leader 键)"
echo "   - 观察终端输出的按键事件"
echo ""
echo "4. 对比两种情况的输出:"
echo "   - 英文输入法下是否能看到 Ctrl 键事件？"
echo "   - 中文输入法下是否能看到 Ctrl 键事件？"
echo "   - 是否有任何按键事件被输出？"
echo ""
echo "=========================================="
echo "💡 预期观察"
echo "=========================================="
echo ""
echo "如果在中文输入法下:"
echo "- 看不到任何按键事件 → 输入法完全拦截了按键"
echo "- 看到按键但没有 CTRL 修饰符 → 输入法吃掉了修饰符"
echo "- 看到完整的 CTRL+, 事件 → WezTerm 配置问题"
echo ""
echo "=========================================="
echo "🛠️  快速切换输入法（用于测试）"
echo "=========================================="
echo ""
echo "切换到英文: im-select com.apple.keylayout.ABC"
echo "切换到中文: im-select com.apple.inputmethod.SCIM.ITABC"
echo ""

# 提供交互式测试
echo "=========================================="
echo "按回车开始测试，或按 Ctrl+C 退出"
read -r

echo ""
echo "开始测试..."
echo ""
echo "1️⃣ 当前输入法: $current_im"
echo ""
echo "请按 Ctrl+, 然后观察上方的输出"
echo "按任意键继续到下一步..."
read -n 1 -s
echo ""
echo ""

# 切换到英文测试
echo "2️⃣ 切换到英文输入法测试"
im-select com.apple.keylayout.ABC
echo "   已切换到: $(im-select)"
echo ""
echo "请按 Ctrl+, 然后观察上方的输出"
echo "按任意键继续到下一步..."
read -n 1 -s
echo ""
echo ""

# 切换到中文测试
echo "3️⃣ 切换到中文输入法测试"
im-select com.apple.inputmethod.SCIM.ITABC
echo "   已切换到: $(im-select)"
echo ""
echo "请按 Ctrl+, 然后观察上方的输出"
echo "按任意键结束测试..."
read -n 1 -s
echo ""
echo ""

# 恢复原始输入法
echo "恢复到原始输入法: $current_im"
im-select "$current_im"
echo ""

echo "=========================================="
echo "✅ 测试完成"
echo "=========================================="
echo ""
echo "请根据观察到的按键事件判断问题原因。"
echo ""
echo "调试完成后，记得在 config/options.lua 中"
echo "将 config.debug_key_events = true 改为 false"
echo ""
