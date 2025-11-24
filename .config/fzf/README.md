# 🚀 FZF 增强配置

> "A precise, ergonomic, and visual fzf setup for Zsh & WezTerm."

这份配置经过了重构，旨在解决进程隔离问题，增强预览体验（WezTerm 图片支持），并打磨了一套符合直觉的键位逻辑。

## 📂 文件结构

* **`config`**: 核心配置文件。定义环境变量、颜色（Gruvbox Transparent）、默认命令（fd）和键位绑定。
* **`preview.sh`**: 增强版预览脚本。支持图片(Chafa)、目录统计、文件元数据、语法高亮等。
* **`README.md`**: 你现在看到的说明文档。
* **`~/.config/zsh/zshrc.d/50-fzf.zsh`**: (外部关联) Zsh 加载器，包含 `fkill`, `fdel` 函数和 `Ctrl-G` 映射。

---

## 🎹 键位逻辑 (Key Bindings)

这是最需要记忆的部分。采用了 **"Tab 移动 / Ctrl-J 选择"** 的分离策略。

### 核心操作 (Inside FZF)

| 键位 | 动作 | 逻辑说明 |
| :--- | :--- | :--- |
| **`Tab`** | **向下移动** | 快速浏览列表 (Move Down) |
| **`Shift-Tab`** | **向上移动** | 快速浏览列表 (Move Up) |
| **`Ctrl-J`** | **选中 + 下移** | **核心多选键**。类似 Checkbox 打钩 (Toggle + Down) |
| **`Ctrl-K`** | **选中 + 上移** | 反向打钩 (Toggle + Up) |
| **`Space`** | 选中 + 下移 | 备用的多选方式 |
| **`Ctrl-/`** | **预览开关** | 显隐预览窗口 (Toggle Preview) |
| **`Ctrl-Y`** | **复制到剪贴板** | 不执行命令，直接复制选中的路径或历史命令 |
| **`Alt-Up/Down`** | 跳转首尾 | 快速跳转到列表最开始或最末尾 |

### 触发入口 (Triggers)

| 键位 | 模式 | 说明 |
| :--- | :--- | :--- |
| **`Ctrl-T`** | **找文件** | (Target) 插入文件路径到命令行 |
| **`Ctrl-R`** | **找历史** | (Recall) 搜索并粘贴历史命令 |
| **`Alt-C`** | **进目录** | (Change) 选中后直接 `cd` 进入 |
| **`Ctrl-G`** | **进目录** | `Alt-C` 的替身 (在 `50-fzf.zsh` 中定义的 Zsh 别名) |

---

## 👁️ 预览功能 (Preview Features)

预览脚本 (`preview.sh`) 会自动检测文件类型和终端能力：

1.  **目录**: 显示包含的文件/文件夹数量，以及磁盘占用大小 (`du -sh`)。
2.  **图片**: 在 WezTerm 中使用 `chafa` 协议直接渲染高清图片。
3.  **代码**: 使用 `bat` 进行语法高亮。
4.  **压缩包**: 自动列出 zip/tar/gz 的内容清单。
5.  **元数据**: 顶部常驻显示文件大小、权限、行数、MIME 类型。

---

## 🛠️ 实用工具 (Utility Functions)

定义在 `50-fzf.zsh` 中：

* **`fkill`**: 交互式杀进程。支持 Tab 多选，带预览。
* **`fdel`**: 交互式删文件。支持 Tab 多选，带确认保护，WezTerm 图片预览生效。

---

## 📦 依赖管理

如果换了新机器，确保安装以下工具以获得完整体验：

```bash
# 核心组件
brew install fzf fd bat

# 增强预览组件
brew install chafa      # 图片支持 (关键)
brew install tree       # 目录树
brew install jq         # JSON 预览
brew install poppler    # PDF 预览

---

## 🧠 高阶用法手册 (Advanced Usage)

这里记录了 FZF 官方文档中容易被忽视但极具威力的功能。

### 1. 搜索语法 (Search Syntax)

不要只是随机输入字母。使用修饰符可以极大提高搜索效率。**空格表示 AND**。

| 符号 | 作用 | 示例 | 解释 |
| :--- | :--- | :--- | :--- |
| **(空格)** | **AND** | `foo bar` | 同时包含 foo 和 bar |
| **`|`** | **OR** | `jpg | png` | 包含 jpg **或者** png |
| **`!`** | **NOT** | `!test` | **不**包含 test |
| **`'`** | **精确** | `'main` | 精确匹配 main (不匹配 maintain) |
| **`^`** | **前缀** | `^src` | 以 src **开头** |
| **`$`** | **后缀** | `.md$` | 以 .md **结尾** |

> **💡 组合技示例**:
> `^src .py$ !test`
> *"查找以 src 开头，且是 .py 结尾，但文件名里不包含 test 的文件"*

### 2. 模糊补全 (Fuzzy Completion)

这是 FZF 最强大的隐藏功能。在命令后输入 `**` 再按 `Tab` 键触发。

* **文件补全**:
    ```bash
    vim src/**<TAB>      # 搜索 src 下的文件并用 vim 打开
    ls **<TAB>           # 搜索文件并 ls
    ```

* **目录补全**:
    ```bash
    cd **<TAB>           # 搜索并进入目录 (替代 Alt-C)
    ```

* **进程补全** (智能识别 kill):
    ```bash
    kill **<TAB>         # 自动列出进程列表，选中后自动填入 PID
    ```

* **SSH 主机补全**:
    ```bash
    ssh **<TAB>          # 从 ~/.ssh/config 搜索 Host
    ```

* **环境变量补全**:
    ```bash
    unset **<TAB>        # 搜索当前环境变量
    export **<TAB>
    ```

### 3. 管道协同 (Pipeline)

FZF 可以作为管道中间件，过滤任何命令的输出。

* **Git 操作**:
    ```bash
    # 检出分支
    git checkout $(git branch -a | fzf)
    ```

* **搜索历史并立即执行**:
    ```bash
    # 可以在 zshrc 中定义别名: fh
    history | fzf | sh
    ```

* **结合 ripgrep (rg) 搜索内容**:
    ```bash
    # 在文件中搜索字符串，选中后用 vim 打开
    rg --line-number "pattern" . | fzf | awk -F: '{print $1, $2}'
    ```

---

## 💡 最佳实践流 (Workflow)

基于您的 **Ctrl-J (多选)** 配置：

1.  **批量操作**:
    * 输入 `Ctrl-T`。
    * 输入 `.jpg$` (搜图)。
    * 按 `Tab` (下移) 浏览，看到要删的图按 `Ctrl-J` (选中)。
    * 选了 5 张图后，按 `Enter`。
    * 命令行变成: `rm img1.jpg img2.jpg ...` -> 回车执行。

2.  **快速复制路径**:
    * 输入 `Ctrl-T`。
    * 找到那个藏得很深的文件。
    * 直接按 `Ctrl-Y`。
    * 路径已在剪贴板，去微信或 Slack 粘贴给同事。

3.  **拯救长命令**:(但是针对这个, 有更好的方式)
    * 刚敲了一个巨长的 curl 命令但失败了？
    * 按 `Ctrl-R`。
    * 输入 `curl` 找到它。
    * 按 `Ctrl-E` (如果 Zsh 配置了 edit) 或者直接回车放到命令行修改。

## 🧩 FZF 扩展功能矩阵 (Extended Functions)

这些高级命令定义在 `50-fzf.zsh` (函数) 和 `30-aliases.zsh` (别名) 中，它们将 FZF 从单纯的“搜索工具”变成了“工作流引擎”。

### 🛠️ 系统与运维 (System & DevOps)

| 命令 | 来源 | 功能描述 | 核心价值 |
| :--- | :--- | :--- | :--- |
| **`fkill`** | 函数 | **杀进程**。列出进程 -> 预览详情 -> 多选查杀。 | 比 `kill -9` 直观，防止手滑杀错。 |
| **`fdel`** | 函数 | **删文件**。多选文件 -> 预览内容/图片 -> 确认删除。 | 带“垃圾桶”般的确认机制，支持 WezTerm 图片预览。 |
| **`fport`** | 函数 | **查端口**。查看端口占用情况，支持一键杀掉占用进程。 | 开发时端口被占用的救星 (兼容 macOS/Linux)。 |
| **`logview`**| 函数 | **看日志**。搜索 `/var/log`，使用 `bat` 进行语法高亮预览。 | 运维排查利器，比直接 `cat` 清晰得多。 |
| **`dexec`** | 函数 | **进容器**。列出 Docker 容器 -> 预览 Logs -> 进入 Shell。 | 省去 `docker ps` 找 ID 再 `exec` 的繁琐步骤。 |
| **`sysz`** | 函数 | **管服务**。管理 Systemd 服务 (Start/Stop/Restart)。 | *(Linux Only)* 快速重启崩溃的服务。 |

### 💻 开发工作流 (Development Workflow)

| 命令 | 来源 | 功能描述 | 核心价值 |
| :--- | :--- | :--- | :--- |
| **`gst`** | 函数 | **Git 暂存**。交互式查看 Diff，按 `Enter` 切换 `add/reset`。 | **纯键盘流 Git**。比 `git add -p` 快，比 GUI 轻。 |
| **`nr`** | 函数 | **跑脚本**。解析 `package.json`，选择 `npm run ...` 脚本。 | 记不住 `dev`, `build:prod`, `test:unit` 等脚本名时的助手。 |
