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

# 3. 额外键位绑定 (Extra Key Bindings)
# -----------------------------------------------------------------------------
# 将 Ctrl-G 映射为 Alt-C 的功能 (目录跳转)
bindkey '^g' fzf-cd-widget

# [fkill] 交互式杀进程
# 增强点：自动预览进程详细信息
fkill() {
  local pid
  if ! command_exists ps; then
    echo "❌ ps 命令不可用"
    return 1
  fi

  # 使用 fzf 选择进程
  # header 提示用户操作
  pid=$(ps -ef | sed 1d | fzf \
    --header '[🎯 Tab多选 | Enter杀死]' \
    --multi \
    --preview-window 'down:3:wrap' \
    --preview 'echo {}' | awk '{print $2}')

  if [ -n "$pid" ]; then
    # 将换行符转换为空格，以便一次性杀死多个进程
    pid=$(echo "$pid" | xargs)
    echo "🎯 正在杀死进程: $pid"
    # 使用 kill -9 强杀，您可以根据需要改为 -15
    kill -9 $pid && echo "✅ 进程已终止" || echo "❌ 无法终止进程"
  fi
}

# [fdel] 交互式文件删除
fdel() {
  local files
  # 优先使用 fd，回退到 find
  local cmd="find . -type f"
  if command_exists fd; then
    cmd="fd --type f --hidden --exclude .git"
  fi

  # 调用 fzf，使用我们统一的预览脚本
  files=$(eval "$cmd" | fzf \
    --multi \
    --header '[🗑️  Tab多选 | Enter删除]' \
    --preview "$HOME/.config/fzf/preview.sh {}")

  if [ -n "$files" ]; then
    echo "🗑️  准备删除以下文件:"
    echo "$files" | sed 's/^/  - /' # 增加缩进美化显示
    echo ""

    # Zsh 特有的 read -q (不需要按回车)，带兼容性检查
    if [[ -o interactive ]] && read -q "confirm?⚠️  确认删除? (y/N) "; then
      echo "" # 补一个换行
      # 使用 tr 处理换行符，防止文件名带空格出问题
      echo "$files" | tr '\n' '\0' | xargs -0 rm -v
      echo "✅ 删除完成"
    else
      # 非交互模式或 read -q 失败，回退到普通 read
      if [[ -o interactive ]]; then
        echo -e "\n⚠️  read -q 不可用，回退到普通输入"
      fi
      echo -n "⚠️  确认删除? (y/N) "
      read confirm
      if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo ""
        # 使用 tr 处理换行符，防止文件名带空格出问题
        echo "$files" | tr '\n' '\0' | xargs -0 rm -v
        echo "✅ 删除完成"
      else
        echo -e "\n❌ 操作已取消"
      fi
    fi
  fi
}


# [fport] 端口占用检查
# 核心价值: 快速查看谁占用了端口，支持杀进程
fport() {
  local pid
  if [[ "$OSTYPE" == darwin* ]]; then
    # macOS 版
    pid=$(lsof -iTCP -sTCP:LISTEN -P -n | tail -n +2 | fzf --header '[🎯 端口占用 | Enter:杀进程]' --preview 'echo "Process info:"; ps -p {2} -o pid,ppid,user,cpu,time,command' | awk '{print $2}')
  else
    # Linux 版
    pid=$(lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | tail -n +2 | fzf --header '[🎯 端口占用 | Enter:杀进程]' | awk '{print $2}')
  fi
  if [ -n "$pid" ]; then
    echo "🎯 选中进程 PID: $pid"
    if read -q "confirm?⚠️  确认杀死该进程? (y/N) "; then
        echo "" && kill -9 "$pid" && echo "✅ 进程已终止"
    else
        echo "\n❌ 操作取消"
    fi
  fi
}

# [sysz] Systemd 服务管理 (Linux Only)
if [[ "$OSTYPE" == linux-gnu* ]]; then
  sysz() {
    if ! command_exists systemctl; then echo "❌ 仅支持 Systemd 系统"; return; fi
    sudo systemctl list-units --type=service --state=running,failed --no-legend | \
    fzf --header '[Systemd | Enter:重启 | Ctrl-S:停止 | Ctrl-R:重载]' \
        --preview 'sudo systemctl status {1}' \
        --bind 'enter:execute(sudo systemctl restart {1})+reload(sudo systemctl list-units --type=service --state=running,failed --no-legend)' \
        --bind 'ctrl-s:execute(sudo systemctl stop {1})+reload(sudo systemctl list-units --type=service --state=running,failed --no-legend)'
  }
fi

# [logwatch] 日志实时监控 (Log Watcher)
# 核心价值: 搜索当前目录及系统日志 -> 预览 -> 实时追踪 (tail -f)
# 智能选择: 有 lnav 就用 lnav，没有就用 tail -f
logwatch() {
  local dirs="."
  [[ -d "/var/log" ]] && dirs=". /var/log"

  local viewer="tail -f"
  if command -v lnav >/dev/null 2>&1; then
    viewer="lnav"
  fi

  find $dirs -type f -name "*.log" 2>/dev/null | \
  fzf --preview 'tail -n 50 {} | bat --color=always --style=numbers --language=log' \
      --preview-window 'right:60%' \
      --header "查看日志 | Viewer: $viewer" \
      --bind "enter:execute($viewer {})"
}

# ==============================================================================
# 4. 开发工作流增强 (Dev Workflows)
# ==============================================================================

# ==============================================================================
# Git FZF 增强 (Git Workflows)
# ==============================================================================

# [gst] Git 交互式控制台 (Git Stage & Commit)
# 核心价值: 提交代码前的最后检查，替代 git add -p
# 功能增强:
#   - Enter:  切换暂存 (Stage/Unstage)
#   - Alt-C:  提交 (Commit) -> 唤起编辑器
#   - Alt-P:  推送 (Push) -> 执行 git push
#   - Ctrl-E: 编辑 (Edit) -> 用默认编辑器打开文件
unalias gst 2>/dev/null

gst() {
  local files
  files=$(git status --porcelain | fzf \
    --multi \
    --preview '
       file={2}
       # 重新获取文件的精确状态 (XY)，解决 FZF 吞掉前导空格的问题
       # stat output: "XY" (2 chars)
       stat=$(git status --porcelain -- "$file" | cut -c 1-2)
       X=${stat:0:1}
       Y=${stat:1:1}

       if [[ "$stat" == "??" ]]; then
         # 新文件: 直接预览内容
         if command -v bat >/dev/null; then
           bat --color=always --style=numbers -- "$file"
         else
           cat -- "$file"
         fi
       elif [[ "$Y" != " " ]]; then
         # Unstaged (Y位有值): 显示工作区改动
         git diff --color=always -- "$file"
       elif [[ "$X" != " " ]]; then
         # Staged (X位有值): 显示暂存区改动
         git diff --cached --color=always -- "$file"
       fi' \
    --bind 'enter:execute(
       file={2}
       # 逻辑: 如果有未暂存的改动 -> add; 如果全是已暂存 -> reset
       stat=$(git status --porcelain -- "$file" | cut -c 1-2)
       X=${stat:0:1}
       Y=${stat:1:1}

       if [[ "$stat" == "??" || "$Y" != " " ]]; then
         git add -- "$file"
       elif [[ "$X" != " " ]]; then
         git reset HEAD -- "$file"
       fi
    )+reload(git status --porcelain)' \
    --bind 'alt-c:execute(git commit -v < /dev/tty > /dev/tty)+reload(git status --porcelain)' \
    --bind 'alt-p:execute(git push < /dev/tty > /dev/tty)+reload(git status --porcelain)' \
    --bind 'ctrl-e:execute(${EDITOR:-vim} {2} < /dev/tty > /dev/tty)' \
    --header 'Git控制台 | Enter:暂存/撤销 | Alt-C:提交 | Alt-P:推送 | Ctrl-E:编辑' \
    --query "$*"
  )
}

# [glp] Git Log Preview (交互式搜索提交)
# 核心价值: 在茫茫 Commit 中搜索代码变更，右侧实时预览 Diff
# ------------------------------------------------------------------------------
unalias glp 2>/dev/null

glp() {
  # 1. --graph: 显示分支树状图
  # 2. grep -o: 精准提取 Hash (防止树状图的 * | 符号干扰 {1} 的提取)
  # 3. "$@": 允许透传参数，比如 glp -n 10
  git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
  fzf --ansi --no-sort --reverse \
      --header 'Git Log | Enter:详情 | Ctrl-Y:复制Hash' \
      --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1)' \
      --preview-window 'right:60%' \
      --bind 'enter:execute(git show --color=always $(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1) | less -R)' \
      --bind 'ctrl-y:execute-silent(echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | tr -d "\n" | (pbcopy || xclip -selection clipboard))+abort'
}

# [gfp] Git File Preview (文件历史回溯)
# 核心价值: 浏览文件列表，右侧预览该文件的最近 10 次提交
# ------------------------------------------------------------------------------
# 同样 unalias 防御性编程 (虽然 gfp 冲突概率较小，但以防万一)
unalias gfp 2>/dev/null

gfp() {
  # "$@" 允许传参: gfp src/ (只搜 src 目录)
  git ls-files "$@" | \
  fzf --preview 'git log --oneline --color=always -n 10 -- {}' \
      --preview-window 'right:60%' \
      --header 'Git File History'
}

# [dexec] Docker 容器交互
dexec() {
  if ! command_exists docker; then echo "❌ Docker 未安装"; return; fi
  local cid
  cid=$(docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}" | \
    fzf --header-lines=1 --header '进入容器 (Enter to exec)' --preview 'docker logs --tail 50 {1}' | awk '{print $1}')
  [ -n "$cid" ] && (docker exec -it "$cid" /bin/bash || docker exec -it "$cid" /bin/sh)
}

# [nr] NPM 脚本运行器
nr() {
  if [ ! -f "package.json" ]; then echo "❌ 无 package.json"; return; fi
  if ! command_exists jq; then echo "❌ 需要安装 jq"; return; fi
  local script
  script=$(jq -r '.scripts | keys[]' package.json | \
    fzf --preview 'jq -r ".scripts.\"{}\"" package.json' --header '运行 NPM 脚本' --height 40%)
  [ -n "$script" ] && npm run "$script"
}


# [check_fzf_deps] 依赖检查
check_fzf_deps() {
  local deps=(bat tree fd chafa jq poppler)
  echo "🔍 检查 FZF 增强依赖..."

  for dep in $deps; do
    if command_exists $dep; then
        echo "✅ $dep: 已安装"
    else
        echo "⚠️  $dep: 未安装 (brew install $dep)"
    fi
  done
}
