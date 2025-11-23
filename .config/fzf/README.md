# 🚀 FZF 增强配置

一个针对开发者优化的 fzf 配置，提供强大的文件搜索、智能预览、实用工具函数和优雅的 Gruvbox Dark Soft 透明主题。

![fzf config preview](https://img.shields.io/badge/fzf-v0.67.0+-blue) ![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-lightgrey) ![Theme](https://img.shields.io/badge/Theme-Gruvbox%20Dark%20Soft-brightgreen)

## ✨ 特性概览

### 🔍 增强的文件搜索
- **fd 集成**: 使用 `fd` 替代 `find` 进行更快速、精确的文件搜索
- **智能路径**: 搜索 `$HOME/Projects`, `$HOME/.config`, `$HOME/Documents`
- **排除模式**: 自动忽略 `.git`, `.idea`, `.vscode`, `node_modules` 等无关目录
- **深度控制**: 最大搜索深度 5 层，避免性能问题
- **隐藏文件**: 支持搜索隐藏文件和符号链接

### 👁️ 智能预览系统
- **多重回退**: bat → file+head → head，确保在任何环境下都能工作
- **文件大小检查**: 自动检测大文件（>10MB）并显示警告
- **类型识别**: 智能识别文件类型，文本/二进制文件区别处理
- **目录预览**: 显示目录结构和文件统计信息
- **语法高亮**: 使用 bat 提供代码语法高亮（可选）

### 🎨 视觉主题
- **Gruvbox Dark Soft**: 护眼的深色主题
- **透明终端**: 支持终端透明度，融入桌面环境
- **圆角边框**: 现代化的界面设计
- **自定义符号**: 个性化的指针和标记符号

### ⌨️ 增强键位绑定
- **基础导航**: Ctrl+J/K (上下)，Ctrl+U/D (翻页)
- **选择操作**: Ctrl+A (全选)，Ctrl+X (取消选择)
- **排序控制**: Ctrl+R (切换排序)
- **预览切换**: Ctrl+P (开启/关闭预览)
- **快速导航**: Alt+Up/Down (首/尾)，Alt+J/K (上下)

### 🛠️ 实用工具函数
- **fkill()**: 交互式进程管理器
- **fdel()**: 安全的文件删除工具
- **check_fzf_deps()**: 依赖检查和安装建议

## 📦 安装指南

### 前置要求

#### 必需依赖
- **fzf 0.67.0+**: 核心工具
  ```bash
  # macOS
  brew install fzf
  
  # Ubuntu/Debian
  sudo apt install fzf
  
  # 或手动安装
  git clone https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
  ```

#### 推荐依赖 (可选，但强烈建议)
```bash
# macOS
brew install fd bat tree

# Ubuntu/Debian
sudo apt install fd-find bat tree
# Ubuntu 上的 fd 命令可能叫 fdfind，需要 symlink
sudo ln -s $(which fdfind) /usr/local/bin/fd
```

### 配置安装

1. **复制配置文件**
   ```bash
   # 将配置放置到标准位置
   mkdir -p ~/.config/fzf
   cp config ~/.config/fzf/config
   ```

2. **加载配置**
   ```bash
   # 添加到 shell 配置文件
   echo "source ~/.config/fzf/config" >> ~/.zshrc  # Zsh
   # 或
   echo "source ~/.config/fzf/config" >> ~/.bashrc  # Bash
   ```

3. **重新加载配置**
   ```bash
   # Zsh
   source ~/.zshrc
   
   # Bash
   source ~/.bashrc
   ```

4. **验证安装**
   ```bash
   # 检查依赖状态
   check_fzf_deps
   
   # 测试基本功能
   fzf
   ```

## 📚 详细配置说明

### 核心配置选项

#### 基础搜索配置
```bash
# 使用 fd 替代 find，提供更好的性能
export FZF_DEFAULT_COMMAND="fd \
  --type f \           # 仅搜索文件
  --hidden \           # 包含隐藏文件
  --follow \           # 跟随符号链接
  --max-depth 5 \      # 最大搜索深度
  --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build,target} \
  --search-path=$HOME/Projects \
  --search-path=$HOME/.config \
  --search-path=$HOME/Documents"
```

#### 通用选项
```bash
export FZF_DEFAULT_OPTS='--height 90%
  --layout=reverse     # 反向布局
  --multi              # 支持多选
  --border=rounded     # 圆角边框
  --prompt="∼ "        # 自定义提示符
  --pointer="▶"        # 自定义指针
  --marker="✓"         # 选中标记'
```

#### 主题配置
```bash
# Gruvbox Dark Soft 透明版本
local color01='#3c3836'  # 背景色
local color02='#504945'  # 边框色
local color03='#665c54'  # 分割线
local color06='#ebdbb2'  # 主文字色
local color0A='#fabd2f'  # 提示符颜色
local color0C='#8ec07c'  # 指针颜色
```

### 智能预览系统

`_fzf_preview()` 函数提供多级回退机制：

1. **优先级 1: bat** - 语法高亮的文件预览
2. **优先级 2: file + head** - 基础文件信息和内容预览
3. **优先级 3: head** - 最基础的文件预览

#### 预览功能特点
- **大小检查**: 自动跳过 >10MB 的大文件
- **类型识别**: 区分文本文件和二进制文件
- **目录统计**: 显示文件数量和子目录数量
- **树状显示**: 使用 tree 命令展示目录结构

### 预设配置

#### 文件搜索 (Ctrl+T)
```bash
export FZF_CTRL_T_OPTS="
  --preview '_fzf_preview {}'
  --preview-window right:60%:wrap
  --header '📋 CTRL-P: 切换预览 | CTRL-A: 全选'"
```

#### 历史搜索 (Ctrl+R)
```bash
export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window down:3:wrap
  --header '🕐 历史命令搜索'"
```

#### 目录导航 (Alt+C)
```bash
export FZF_ALT_C_OPTS="
  --preview '_fzf_preview {}'
  --preview-window right:60%:wrap
  --header '📁 ENTER: 进入目录'"
```

## 🎯 使用指南

### 基础使用

#### 基本文件搜索
```bash
# 启动文件搜索（使用配置的 fd 命令）
fzf

# 在指定目录中搜索
find /path/to/dir | fzf

# 结合其他命令使用
find . -name "*.py" | fzf
```

#### Shell 集成
```bash
# Ctrl+T: 文件搜索
# Ctrl+R: 历史命令搜索
# Alt+C: 目录导航

# 使用示例：
# 1. 按 Ctrl+T 开始搜索文件
# 2. 使用键位导航和搜索
# 3. 按 Enter 选择文件
```

#### 预览功能
```bash
# 搜索时按 Ctrl+P 切换预览窗口
# 预览窗口会显示文件内容或目录结构
# 大文件会自动警告并拒绝显示
```

### 高级功能

#### 多选操作
```bash
# 1. 使用 Ctrl+A 选择所有结果
# 2. 使用 Ctrl+X 取消所有选择
# 3. 使用空格键单独选择/取消项目
# 4. Tab 键也可以用于选择
```

#### 排序控制
```bash
# 按 Ctrl+R 切换排序方式
# 排序选项：文件名、修改时间、大小等
```

#### 快速导航
```bash
# Alt+Up/Down: 跳转到首项/末项
# Alt+K/Up: 向上移动
# Alt+J/Down: 向下移动
# Ctrl+U/D: 向上/向下翻页
```

### 实用工具函数

#### 进程管理 (fkill)
```bash
# 启动交互式进程管理器
fkill

# 功能：
# 1. 显示所有运行进程
# 2. 支持预览
# 3. 选择进程后强制杀死 (SIGKILL)
# 4. 包含确认机制防止误操作
```

#### 文件删除 (fdel)
```bash
# 启动交互式文件删除工具
fdel

# 功能：
# 1. 搜索和选择要删除的文件
# 2. 预览选中的文件
# 3. 多选支持
# 4. 强制确认机制
# 5. 批量删除操作
```

#### 依赖检查 (check_fzf_deps)
```bash
# 检查所有增强功能的依赖状态
check_fzf_deps

# 输出示例：
# ✅ bat (语法高亮): 已安装
# ✅ tree (目录树): 已安装
# ⚠️ fd (文件查找): 未安装 - 将使用 find 作为回退
```

## ⌨️ 完整键位绑定

### 导航键位
| 键位 | 功能 |
|------|------|
| `Ctrl+J` / `↓` | 向下移动 |
| `Ctrl+K` / `↑` | 向上移动 |
| `Alt+J` / `↓` | 向下移动（替代键） |
| `Alt+K` / `↑` | 向上移动（替代键） |
| `Ctrl+U` | 向上翻页 |
| `Ctrl+D` | 向下翻页 |
| `Alt+Up` | 跳转到首项 |
| `Alt+Down` | 跳转到末项 |

### 选择键位
| 键位 | 功能 |
|------|------|
| `Space` / `Tab` | 选中/取消选中 |
| `Ctrl+A` | 全选所有 |
| `Ctrl+X` | 取消全选 |
| `Alt+I` | 反向选择 |

### 功能键位
| 键位 | 功能 |
|------|------|
| `Ctrl+P` | 切换预览窗口 |
| `Ctrl+R` | 切换排序方式 |
| `Ctrl+T` | 触发文件搜索 |
| `Alt+C` | 触发目录导航 |
| `Esc` | 清除搜索查询 |
| `Enter` | 确认选择 |

### 预览窗口控制
- **显示**: Ctrl+P 切换预览窗口
- **位置**: 默认在右侧，60% 宽度
- **换行**: 自动换行显示长行
- **隐藏**: 再次按 Ctrl+P 隐藏

## 🔧 故障排除

### 常见问题

#### 1. 预览功能不工作
**问题**: 搜索时无法显示文件预览
**解决方案**:
```bash
# 检查预览函数
echo "test file" | fzf --preview '_fzf_preview {}'

# 检查依赖
check_fzf_deps

# 手动测试预览
echo "/path/to/file.txt" | fzf --preview 'head {}'
```

#### 2. fd 命令不可用
**问题**: 提示 "fd 命令不可用"
**解决方案**:
```bash
# 安装 fd
brew install fd  # macOS
sudo apt install fd-find  # Ubuntu

# 或者创建别名
alias fd='fdfind'

# 配置会自动回退到 find
```

#### 3. 预览窗口显示异常
**问题**: 预览窗口位置或显示不正常
**解决方案**:
```bash
# 重置预览配置
export FZF_CTRL_T_OPTS="--preview '_fzf_preview {}'"

# 测试基本预览
fzf --preview 'echo "test"'

# 检查终端尺寸
echo "终端行数: $(tput lines)"
echo "终端列数: $(tput cols)"
```

#### 4. 主题显示问题
**问题**: 颜色或透明度显示异常
**解决方案**:
```bash
# 检查终端是否支持 256 色
tput colors

# 手动设置主题
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --color=bg:-1"

# 重置为默认主题
unset _gen_fzf_default_opts
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --multi"
```

#### 5. 键位绑定失效
**问题**: 某些键位组合不响应
**解决方案**:
```bash
# 检查键位绑定
fzf --version

# 重新加载配置
source ~/.config/fzf/config

# 测试基本键位
fzf --bind ctrl-j:down,ctrl-k:up
```

### 性能优化

#### 搜索性能问题
```bash
# 减少搜索路径
export FZF_DEFAULT_COMMAND="fd --type f --max-depth 3"

# 增加排除模式
export FZF_DEFAULT_COMMAND="fd --exclude='*.log' --exclude='tmp/*'"

# 限制结果数量
fzf --bind 'ctrl-t:reload(fd --type f | head -1000)'
```

#### 预览性能问题
```bash
# 禁用大文件预览
# 配置文件已自动处理

# 简化预览命令
export FZF_CTRL_T_OPTS="--preview 'head -10 {}'"

# 使用更快的预览工具
export FZF_CTRL_T_OPTS="--preview 'cat {}' 2>/dev/null"
```

### 调试模式

#### 启用详细输出
```bash
# 开启调试模式
export FZF_DEBUG=1

# 查看实际执行的命令
export FZF_DEFAULT_COMMAND="fd --type f --hidden; echo 'FZF_DEFAULT_COMMAND executed'"

# 测试预览函数
_fzf_preview /path/to/test/file
```

#### 逐步排查
```bash
# 1. 检查基础配置
echo $FZF_DEFAULT_COMMAND
echo $FZF_DEFAULT_OPTS

# 2. 测试基本功能
fzf --version
echo "test" | fzf

# 3. 测试工具函数
fkill  # 应该显示进程列表
fdel   # 应该显示文件选择界面

# 4. 检查依赖状态
check_fzf_deps
```

### 兼容性说明

#### fzf 版本兼容性
- **最低要求**: fzf 0.67.0+
- **推荐版本**: fzf 0.45.0+
- **测试版本**: fzf 0.67.0, 0.69.0

#### 终端兼容性
- **支持终端**: iTerm2, Terminal.app, Hyper, Alacritty
- **颜色支持**: 256 色，True Color
- **特殊功能**: 透明度、emoji 支持

#### Shell 兼容性
- **支持 Shell**: Bash, Zsh, Fish
- **测试版本**: Bash 5.0+, Zsh 5.8+, Fish 3.0+

## 📝 自定义配置

### 修改搜索路径
```bash
# 编辑配置文件，添加或修改搜索路径
export FZF_DEFAULT_COMMAND="fd \
  --type f \
  --search-path=$HOME/Projects \
  --search-path=$HOME/Work \
  --search-path=$HOME/Documents"
```

### 自定义排除模式
```bash
# 添加更多排除模式
export FZF_DEFAULT_COMMAND="fd \
  --exclude='*.tmp' \
  --exclude='*.log' \
  --exclude='node_modules' \
  --exclude='.git'"
```

### 修改预览行为
```bash
# 更改预览窗口大小
export FZF_CTRL_T_OPTS="--preview-window right:50%"

# 更改预览命令
export FZF_CTRL_T_OPTS="--preview 'your-custom-preview-command {}'"
```

### 自定义主题
```bash
# 修改颜色方案
_gen_fzf_default_opts() {
  local bg='#282a36'      # Dracula 背景
  local fg='#f8f8f2'      # Dracula 前景
  local accent='#50fa7b'  # Dracula 强调色
  
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
    --color=bg:$bg,fg:$fg,accent:$accent"
}
```

## 🚀 高级技巧

### 与其他工具集成

#### 与 vim/neovim 集成
```bash
# 在 vim 中使用 fzf
vim $(fzf)

# 或者使用 fzf.vim 插件
# 在 .vimrc 中添加：Plug 'junegunn/fzf.vim'
```

#### 与 ranger 文件管理器集成
```bash
# 在 ranger 中使用 fzf 选择文件
set preview_images false
set use_preview_script true
```

#### 与其他 shell 工具组合
```bash
# 结合 ripgrep 使用
rg --files | fzf --preview 'rg --color=always --no-heading {}'

# 结合 git 使用
git ls-files | fzf --preview 'git show {}'

# 结合 ps 使用
ps aux | fzf --preview 'ps -p $(echo {} | awk "{print \$2}")'
```

### 批量操作

#### 批量重命名
```bash
# 选择多个文件并重命名
ls | fzf --multi | while read file; do
  mv "$file" "${file%.txt}_renamed.txt"
done
```

#### 批量移动文件
```bash
# 移动选中的文件到指定目录
fzf --multi | xargs -I {} mv {} ~/Desktop/Selected/
```

#### 批量复制路径
```bash
# 复制选中的文件路径到剪贴板
fzf --multi | pbcopy  # macOS
fzf --multi | xclip -selection clipboard  # Linux
```

### 效率优化技巧

#### 预设搜索
```bash
# 创建常用搜索别名
alias fzf-python='fzf --preview "head -10 {}" | grep "\.py$"'
alias fzf-md='fzf --preview "head -10 {}" | grep "\.md$"'
```

#### 搜索历史
```bash
# 在历史搜索中快速定位
# 1. 按 Ctrl+R
# 2. 输入关键词
# 3. 使用方向键选择历史记录
# 4. 按 Enter 执行
```

#### 快速切换目录
```bash
# 1. 按 Alt+C
# 2. 选择目标目录
# 3. 自动切换到该目录并显示内容
cd $(find . -type d | fzf)
```

## 📄 许可证

本配置基于 MIT 许可证开源。

## 🤝 贡献

欢迎提交问题和改进建议！

## 🙏 致谢

- [junegunn/fzf](https://github.com/junegunn/fzf) - 核心工具
- [sharkdp/fd](https://github.com/sharkdp/fd) - 改进的文件查找
- [bat-preview](https://github.com/eth-p/bat-extras) - 语法高亮预览
- [Gruvbox](https://github.com/morhetz/gruvbox) - 配色方案

---

**最后更新**: 2024-11-23  
**维护者**: Jensen  
**版本**: 1.0.0  

如果这个配置对您有帮助，请考虑给个项目点个 ⭐️！