# ==============================================================================
# Zsh 按键绑定与 ZLE (Zsh Line Editor) 配置
# ==============================================================================
# 作用: 集中管理所有快捷键、自定义 Widget 和 Vi 模式增强
# 依赖: 必须在 Sheldon (20-plugins.zsh) 之后加载
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. 自定义 Widget (小部件)
#    这里定义了一些原生 Zsh 做不到或做得不够好的自定义功能函数
# ------------------------------------------------------------------------------

# [自定义删除] 细腻的向左删除 (Stop at separators)
# 作用：模拟 VSCode/Sublime 的删除行为，遇到 / - . _ 等符号就停下，而不是删掉整个路径
function my-backward-kill-word() {
    # 临时修改单词边界定义 (WORDCHARS)
    # 默认 Zsh 把 /-. 等都视为单词一部分，这里设为空字符串 ''
    # 意味着只有 字母和数字 被视为单词，其他符号都是“边界”
    local WORDCHARS=''

    # 执行删除操作
    # ⚠️ 关键点：使用 .backward-kill-word (前面加点)
    # 含义：强制调用 Zsh 内核原始的删除功能，绕过 zsh-syntax-highlighting 等插件的劫持
    # 如果不加点，可能会报错 "No such widget" 或导致死循环
    zle .backward-kill-word
}
# 将函数注册为 ZLE Widget，名为 my-backward-kill-word
zle -N my-backward-kill-word

# [智能历史] 向上搜索
# 作用：如果命令行有输入内容，就按前缀搜索；如果是空的，就单纯向上翻
function my-history-up() {
    if [[ -n $BUFFER ]]; then
        # 如果缓冲区有字，调用内置的前缀搜索
        zle history-beginning-search-backward
    else
        # 如果没字，模拟按“上箭头”
        zle up-line-or-history
    fi
}
zle -N my-history-up

# [智能历史] 向下搜索
# 作用：同上，方向向下
function my-history-down() {
    if [[ -n $BUFFER ]]; then
        zle history-beginning-search-forward
    else
        zle down-line-or-history
    fi
}
zle -N my-history-down

# ------------------------------------------------------------------------------
# 2. 基础组件加载
# ------------------------------------------------------------------------------

# 加载 edit-command-line 组件 (允许在 Vim 中编辑当前长命令)
autoload -Uz edit-command-line
zle -N edit-command-line

# ------------------------------------------------------------------------------
# 3. Vi 模式增强 (Vi-Mode Enhancements)
#    bindkey -M viins : 仅在 Vi 插入模式 (Insert Mode) 下生效
#    bindkey -M vicmd : 仅在 Vi 普通模式 (Normal Mode) 下生效
# ------------------------------------------------------------------------------

# --- A. 全屏编辑 (Edit Command Line) ---
# 场景：命令太长写错了，在 Shell 里改太累，想用 Vim 的强大功能改
# Normal 模式：按 v
bindkey -M vicmd 'v' edit-command-line
# Insert 模式：按 Alt+v (发送的是 Esc+v)
bindkey -M viins '^[v' edit-command-line


# --- B. 历史记录智能导航 ---
# 场景：输入 git 此时按 Ctrl+p，只显示 git 开头的历史命令
# Insert 模式：Ctrl+p / Ctrl+n
bindkey -M viins '^p' my-history-up
bindkey -M viins '^n' my-history-down
# Normal 模式：k / j (让 Vi 的上下移动也变聪明)
bindkey -M vicmd 'k' my-history-up
bindkey -M vicmd 'j' my-history-down


# --- C. 单词级操作 (Word Operations - 你的定制版) ---

# [Alt + d] 向左/向前删除 (Backward Kill Word)
# 这是一个极其顺手的键位 (d 就在左手区)
# 使用上面定义的 my-backward-kill-word，遇到 / 或 - 会停下
bindkey -M viins '^[d' my-backward-kill-word

# [Alt + Backspace] 向右/向后删除 (Kill Word)
# 这里的配置是按照你的要求：Alt+BS 删除光标“后面”的内容
# 注意：'^[^?' 代表 Esc + Backspace
bindkey -M viins '^[^?' kill-word

# [Alt + .] 插入上一个命令的最后一个参数 (Insert Last Word)
# 场景：刚运行完 `mkdir long/path/name`，想 `cd` 进去，按 Alt+. 自动补全路径
bindkey -M viins '^[.' insert-last-word


# ------------------------------------------------------------------------------
# 4. 插件特定快捷键 (Plugin Adaptations)
# ------------------------------------------------------------------------------

# --- zsh-autosuggestions ---

# [Ctrl + f] 接受建议 (部分/按单词)
# 这是 Emacs 风格的标准键位，肌肉记忆通用性最强
bindkey -M viins '^f' forward-word

# [Alt + f] 接受建议 (部分/按单词) - WezTerm/macOS 修复版
# 原理：WezTerm 将 Option+f 发送为 Esc+f (^[f)
# 默认行为：Zsh 收到 Esc 退出插入模式，收到 f 进入查找模式
# 修正行为：强制在插入模式下，将 Esc+f 解析为“向右移动一个词”
bindkey -M viins '^[f' forward-word

# [Ctrl + y] 接受所有建议
# 一次性接受整行建议
bindkey '^Y' autosuggest-accept
