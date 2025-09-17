# FZF 模糊查找器配置 - FZF (Fuzzy Finder) Configuration

# 加载 FZF 配置文件(如果存在)
source_if_exists "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/config"

# 加载 FZF 快捷键与补全(跨平台检测安装目录)
# Ctrl-R: 历史命令搜索
# Ctrl-T: 文件搜索
# Alt-C:  目录跳转
typeset -a __fzf_share_candidates

if command_exists fzf-share; then
    __fzf_share_candidates+=("$(fzf-share)")
fi

if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
    __fzf_share_candidates+=("${HOMEBREW_PREFIX}/opt/fzf/shell")
fi

__fzf_share_candidates+=(
    "/usr/local/opt/fzf/shell"
    "/usr/share/fzf"
)

for __candidate in "${__fzf_share_candidates[@]}"; do
    if dir_exists "$__candidate"; then
        __fzf_share_dir="$__candidate"
        break
    fi
done

if [[ -n ${__fzf_share_dir:-} ]]; then
    source_if_exists "$__fzf_share_dir/key-bindings.zsh"
    source_if_exists "$__fzf_share_dir/completion.zsh"
fi

unset __fzf_share_candidates __fzf_share_dir __candidate
