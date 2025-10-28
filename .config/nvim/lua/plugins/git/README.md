# Git 插件模块

意图: 超越 VSCode GitLens 的 Git 集成体验, 核心诉求:

- 方便查看每个 commit 的具体修改
- 编辑器内完整的 Git 工作流

## GitLens 核心能力解析

GitLens 的核心价值在于将 Git 历史信息**无缝嵌入**编辑体验:

1. Blame 信息展示
    - Inline Blame: 当前行末显示最后修改的作者、时间、commit message
    - Status Bar Blame: 状态栏显示当前行的 blame 信息
    - Git CodeLens: 在文件/代码块顶部显示作者数、最近修改信息
    - Rich Hovers: 鼠标悬停查看完整 commit 详情
2. 文件注释视图
    - Toggle File Blame: 整个文件的行级 blame 注释
    - Toggle File Changes: 显示相对于某个版本的所有变更
    - Toggle File Heatmap: 热力图展示代码修改频率
3. Commit Graph (Pro)
    - 可视化仓库的 commit 历史图
    - 强大的搜索功能: 按 commit message、作者、文件、代码变更搜索
    - 快速定位任意 commit
4. Revision Navigation
    - 核心功能: 一键向前/向后浏览文件的历史版本
    - 对比任意两个版本之间的差异
    - 查看某一行在历史上的所有变更
5. 可视化与比较
    - Side-by-Side Diff 视图
    - 三方合并冲突解决界面
    - Timeline 视图: 文件的时间线变更历史

## Neovim Git 插件生态全景

Neovim 社区采用 Unix 哲学 — **专精单一职责的插件组合**，因此, 本配置下采用几个插件组合来实现 Git 集成, 而不是依赖一个庞大插件。

```text
工作流层次           对应插件            职责边界
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[宏观管理层]       Neogit             暂存、提交、分支管理
                   vim-fugitive       Git 命令包装器
                   
[可视化层]         diffview.nvim      Diff 视图、文件历史
                   
[编辑器集成层]     gitsigns.nvim      Gutter 标记、行级操作
                                      Blame 信息展示
```

```shell
├── gitsigns.nvim     - 编辑器内集成
│   ├── Gutter 标记(显示添加/修改/删除)
│   ├── 行内 Blame(虚拟文本)
│   └── Hunk 操作(暂存/重置/预览)
│
├── diffview.nvim     - Commit 历史与 Diff 可视化 ⭐核心
│   ├── 文件 Commit 历史(替代 GitLens Timeline)
│   ├── 查看任意 Commit 的所有修改
│   ├── 行级历史追踪(git log -L)
│   └── 三方合并冲突解决
│
└── neogit.nvim       - 交互式 Git 客户端
    ├── Git Status 面板
    ├── 交互式暂存/提交
    ├── Branch/Push/Pull/Rebase
    └── 原生 Neovim buffer(非 TUI)
```

本nvim配置下对git快捷键的配置如下所示

```shell
🌳 <leader>g - Git 操作树
│
├── 📊 核心查看(高频)
│   ├─ gf          → 当前文件的 Commit 历史 ⭐最常用
│   ├─ gF          → 整个仓库的 Commit 历史
│   ├─ gc          → 查看某个 Commit 的详情(输入 hash)
│   ├─ gl (visual) → 选中行的历史演变
│   └─ gx          → 关闭 Diffview
│
├── 🔍 Diff 与对比
│   ├─ gd          → 查看未提交的改动(vs Index)
│   └─ gD          → 对比当前文件 vs HEAD
│
├── 👤 Blame 信息
│   ├─ gb          → 切换行内 Blame(虚拟文本)
│   └─ gB          → 文件 Blame 视图(整个文件)
│
├── 📝 日常工作流
│   └─ gs          → Git Status(Neogit 面板)
│
└── 🧩 Hunk 操作(代码块级别)
    ├─ gh + s      → 暂存 Hunk(Stage)
    ├─ gh + r      → 重置 Hunk(Reset)
    ├─ gh + p      → 预览 Hunk(Preview)
    ├─ gh + u      → 撤销暂存 Hunk(Undo)
    ├─ gh + S      → 暂存整个文件
    ├─ gh + R      → 重置整个文件
    │
    └─ 🧭 Hunk 导航
       ├─ ]c       → 下一个改动
       └─ [c       → 上一个改动
```

## 插件列表

### gitsigns.nvim

**功能定位**: 在编辑器内实时显示 Git 状态

- 核心特性:
    - Gutter 标记: 显示添加、修改、删除的行
    - 行内 Blame: 虚拟文本显示提交信息(替代 git-blame.nvim)
    - Hunk 操作: 暂存、重置、预览单个代码块
    - Diff 视图: 与 HEAD 或任意 revision 对比

### diffview.nvim

**功能定位**: 查看 commit 历史和每个 commit 的具体修改

- 核心特性:
    - **Commit Log 视图**: 左边列表，右边 diff(对应 GitLens Timeline)
    - 查看任意 commit 的所有文件修改
    - 三方合并冲突解决界面

Diffview 内部键位:

| 键位 | 功能 | 说明 |
|------|------|------|
| `j` / `k` | 上下移动 | 在左侧 commit/文件列表中 |
| `<cr>` | 选择/打开 | 查看 commit 或打开文件 |
| `<tab>` | 下一个文件 | 切换到该 commit 的下一个文件 |
| `<s-tab>` | 上一个文件 | 切换到该 commit 的上一个文件 |
| `q` | 关闭 | 退出 Diffview |
| `<leader>gx` | 关闭 | 退出 Diffview(备用) |

**视觉布局**:

```shell
┌─────────────────────────────────────────────┐
│ File History                                │
├──────────────┬──────────────────────────────┤
│ Commits      │ Diff                         │
│              │                              │
│ ● feat: xxx  │ + 新增代码(绿色)               │
│ ● fix: yyy   │ - 删除代码(红色)               │
│ ● docs: zzz  │ ~ 修改代码(蓝色)               │
│              │                              │
│ j/k move     │ <tab> next file              │
│ <cr> show    │ q close                      │
└──────────────┴──────────────────────────────┘
```

### neogit.nvim

- **功能定位**: 交互式 Git 界面(替代 LazyGit)
- 核心特性:
    - 原生 Neovim buffer，支持所有 Vim 操作
    - 交互式 Status 面板
    - Popup 操作菜单(Commit/Push/Pull/Branch)

Neogit 内部键位:

| 键位 | 功能 | 说明 |
|------|------|------|
| `j` / `k` | 上下移动 | 在文件列表中 |
| `s` | Stage | 暂存文件或 hunk |
| `u` | Unstage | 取消暂存 |
| `c` | Commit | 打开 commit popup，再按 `c` 编写 message |
| `P` | Push | 打开 push popup |
| `F` | Fetch | 抓取远程分支 |
| `p` | Pull | 拉取 |
| `b` | Branch | 分支管理 |
| `z` | Stash | 暂存工作区 |
| `<tab>` | 展开/折叠 | 展开文件查看 diff |
| `q` | 关闭 | 退出 Neogit |

## 使用场景

### 场景 1: 查看文件的所有 commit(对应 GitLens Timeline)

```vim
" 1. 打开当前文件
" 2. 按 <leader>gf
" 3. 左边会显示所有修改过这个文件的 commit 列表
" 4. j/k 选择 commit，回车查看这个 commit 的修改
" 5. Tab 切换该 commit 中修改的其他文件
```

### 场景 2: 查看某个 commit 改了什么

```vim
" 方法 1: 通过 commit hash
<leader>gc
" 输入 commit hash(可以是短 hash)
" 左边显示该 commit 的所有文件，右边显示 diff

" 方法 2: 先打开仓库历史
<leader>gF
" j/k 选择 commit，回车查看详情
```

### 场景 3: 日常提交工作流

```vim
" 1. 修改代码后，查看改动
<leader>gd

" 2. 打开 Neogit 进行暂存和提交
<leader>gs

" 3. 在 Neogit 中: 
"    - j/k 移动到要暂存的文件
"    - s 暂存文件
"    - c 打开 commit popup
"    - c 再次按 c 编写 commit message
"    - P 打开 push popup
"    - p 推送到远程
```

### 场景 4: 追踪某行代码的历史

```vim
" 1. Visual 模式选中若干行
" 2. 按 <leader>gl
" 3. 查看这些行在历史中的所有变更
```

### 场景 5: Hunk 级别的暂存

**目标**: 只暂存当前代码块(不是整个文件)

```vim
" 1. 光标移到某个改动的代码块
" 2. 暂存这个块
<leader>ghs

" 或者 visual 模式选中若干行
V
jjj
<leader>ghs
```

### 场景 6: Reset Soft/Hard (撤销 Commit)

**目标**: 撤销最近的 commit，但保留或丢弃改动

```vim
" 打开 Neogit
<leader>gs

" 在 Neogit 中:
" 1. 按 l (小写 L) 打开 Log
" 2. 找到要 reset 到的 commit
" 3. 按 X (大写 X) 打开 Reset popup
" 4. 选择:
"    - s (soft)  → 撤销 commit，保留改动在暂存区
"    - m (mixed) → 撤销 commit，保留改动在工作区(未暂存)
"    - h (hard)  → 撤销 commit，丢弃所有改动 ⚠️
```

**命令行方式**:

```vim
" Reset soft (保留改动在暂存区)
:!git reset --soft HEAD~1

" Reset mixed (保留改动在工作区)
:!git reset HEAD~1

" Reset hard (丢弃所有改动) ⚠️
:!git reset --hard HEAD~1
```

### 场景 7: Amend Commit (修改最后一次提交)

**目标**: 修改最后一次 commit 的内容或 message

#### 方法 1: 使用 Neogit (推荐)

```vim
" 1. 如果需要添加新的改动，先暂存
<leader>gs
" 在文件上按 s 暂存

" 2. 按 c 打开 Commit popup
" 3. 按 a (amend) 而不是 c (commit)
" 4. 编辑 commit message (或保持不变)
" 5. 保存并关闭
```

#### 方法 2: 只修改 Commit Message

```vim
" 打开 Neogit
<leader>gs

" 按 c (Commit popup)
" 按 w (reword) → 只修改 message，不改内容
" 编辑 message
" 保存并关闭
```

#### 方法 3: Amend No-Edit (不改 message)

```vim
" 1. 暂存新的改动
<leader>ghs  " 或在 Neogit 中按 s

" 2. 命令行 amend
:!git commit --amend --no-edit
```

### 场景 8: 查看 Neogit 的所有操作

```vim
<leader>gs

" 在 Neogit 面板中按 ? 查看所有快捷键
" 常用操作:
"   c → Commit popup
"   P → Push popup  
"   p → Pull popup
"   F → Fetch popup
"   b → Branch popup
"   X → Reset popup
"   l → Log (查看历史)
"   z → Stash popup
```

## ❓ 常见问题

### Q1: 为什么看不到行内 Blame？

**A**: 有两种可能:

1. 需要等待 500ms(这是延迟设置，避免干扰编辑)
2. 手动切换: `<leader>gb`

### Q2: Diffview 显示 "E21: Cannot make changes, 'modifiable' is off"

**A**: 这是**正常的**！左侧的 commit 列表和文件列表是只读的。你应该:

- 用 `j/k` 导航
- 用 `<cr>` 选择
- 不要尝试编辑这些面板

### Q3: 如何快速查看某个文件的修改历史？

**A**: 打开文件后按 `<leader>gf`，这是最常用的操作。

### Q4: Neogit 和 LazyGit 有什么区别？

**A**:

- **LazyGit**: 独立的 TUI 应用，在浮动窗口运行
- **Neogit**: 原生 Neovim buffer，支持所有 Vim 操作

Neogit 的体验更好，因为它是编辑器的一部分，而非外部工具。

### Q5: 左侧面板太窄了？

**A**: 修改 `diffview.lua` 中的配置:

```lua
win_config = {
    position = "left",
    width = 35,  -- 改成 40 或 50
},
```

### Q6: 需要 vim-fugitive 吗？

**A**: **不需要**。当前三件套(gitsigns + diffview + neogit)已经覆盖所有需求:

- diffview 负责查看历史(你的核心诉求)
- gitsigns 负责 Blame 和 Hunk 操作
- neogit 负责日常 Git 工作流

vim-fugitive 是给喜欢命令驱动的用户用的，与 neogit 功能重叠。
