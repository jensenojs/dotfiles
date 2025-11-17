# Neovim 快捷键体系（2025-11-17）

> 本文取代旧版 `docs/keymap.md`，继承“体系审计”的写法，但完全基于 2025-11-17 的实测结果（`docs/keymap_dump_2025-11-17.txt`）。
>
> - **环境**：Neovim + LazyVim，配套的 WezTerm 键位位于 `~/.config/wezterm/config/keymaps.lua`。
> - **导出命令**：在 Neovim 里运行
>   ```vim
>   :redir > ~/dev/dotfiles/nvim/docs/keymap_dump_2025-11-17.txt
>   :silent verbose map
>   :silent verbose map!
>   :redir END
>   ```
>   每次升级后重跑即可得到“权威”键位表。
>
> - **名词**：`<leader>` = 空格，`mod` = 系统级修饰键（WezTerm 上 Mac=Cmd，Linux=Alt)。

---

## 1. 设计原则（复盘确认）

1. **强化原生而非胡乱覆盖**：只有当插件明显增强默认体验时才重载（例：`flash.nvim` 完全接管 `f/t/s/S`，`accelerated-jk` 接管 `j/k`）。
2. **零延迟命名空间**：任何键位不能既是“完整命令”又是后续前缀，`which-key` 只负责 `<leader>` 层的“发现”。
3. **模态分工**：
   - `<leader>` = Normal 模式主动调用插件（工具箱）；
   - `Ctrl` = Normal 模式高频管理（窗口/缓冲/文件/临时工具）；
   - `Alt` = Insert 模式被动助手（Minuet 虚拟文本）；
   - `WezTerm Leader (Ctrl+,)` = 终端级命名空间，避免影响 Neovim。
4. **助记+分组**：`<leader>l`=LSP, `<leader>t`=Test, `<leader>d`=Debug, `<leader>g/G`=Git, `<leader>p`=Persistence, `<leader>m`=Mark, `<leader>s`=Substitute, `<leader>f/F`=Format。
5. **工具不互相踩踏**：Aerial & Telescope 只在缓冲区挂接键位，DAP UI 临时接管 `K`，离开调试会话后即撤销。

---

## 2. 模式与命名空间地图

### 2.1 `<leader>`（Normal 模式主动操作）

| 入口 | 代表键位 & 插件 | 记忆提示 |
|------|----------------|-----------|
| `<leader>l` LSP | `lo` Aerial 大纲、`lO` Workspace Symbols、`lwa/lwd/lwl` 工作区、`lca/lci/lco` Code Action & Call Hierarchy、`ltc/ltp` Type Hierarchy、`lf` 漂浮诊断、`dl/dL` Telescope 诊断列表 | 由 `lua/config/lsp/attach.lua` 给出原始语义，`aerial.nvim` 接管 `lo`，`telescope` (`lua/plugins/fuzzy_finder/lsp_takeover.lua`) 在有 LSP 的 buffer 中覆盖 `lO/lc*/dl*`，因此它们总是跳到统一的 Telescope UI。|
| `<leader>d` Debug (DAP) | `db/dB` 持久断点、`dc` 继续、`dr` REPL、`dt` 终止，加上 `F5/F7/F9~F12` 快捷键。调试会话开启时 `dap-ui` 临时夺取 `K` 为 `eval` | 不记得 `F` 键也行：照着 `<leader>d` 菜单即可。|
| `<leader>t` Test (Neotest) | `tn/tf/tA/tl/ts` 运行/停止/重跑，`td/tD` 调试，`to/tO/tS` 输出与摘要，`tw` Watch，外加 `[t ]t [T ]T` 跳转 | `<leader>t` 整套十个键已经写死在 `lua/plugins/test/neotest.lua`，全部走统一提示。|
| `<leader>g` Git | `gs` Neogit、`gd/gc/gf/gF/gl` Diffview、Visual `gl` 查选中行历史 | Git 相关全部集中，不会与 `g` 原生导航冲突。|
| `<leader>p` Persistence | `pc` 当前目录 session、`pl` 最近 session、`px` 退出时别保存 | 拔电重进一键恢复。|
| `<leader>m` Bookmarks | `mm` toggle、`mn/mp` 导航、`mi` 注释、`mc/mC` Telescope 查询 | 搭配内置 Telescope adapter。|
| `<leader>s` Quick Substitute | `ss` 当前行、Visual `ss` 选区、`sS` 全缓冲区 -> 触发 `lua/config/quick_substitute.lua` 的交互式 `:s` | `s` = substitute。|
| `<leader>f/F` Conform | `<leader>f` = 仅修改区域、`<leader>F` = 全文件 | 自动触发 stylua/ruff_format/goimports... |
| `<leader>/` 搜索 | Live Grep（Telescope），取代传统 `/` | `/` 键本身改成“当前缓冲模糊搜索”，详见 3.1。|
| `<leader>r` Registers | Telescope registers | 用得少但有固定入口。|
| `<leader>q/w/Q/W` | 智能关 Buffer (`close_or_quit`)、保存当前/全部、强制退出 | 默认保留；会根据真实 buffer 数量决定退还是关。|
| `<leader>a` | **预留**：AI 主动功能命名空间（当前空） | TODO 见第 6 节。|

### 2.2 `Ctrl` 层（Normal 模式高频）

- 窗口：`<C-h/j/k/l>` = `<C-w>` 导航（`lua/config/keymaps.lua:194-197`）。
- Buffer：`<C-[>` / `<C-]>` 或 `<S-h>/<S-l>` 切换缓冲，`<leader>q` 关掉智能 buffer（保布局）。
- 文件/工程：`<C-P>` 查文件（Telescope），`<C-E>` / `<C-S-E>` 打开 Yazi（当前文件 / CWD）。
- 临时内容：`<C-S-N>` 新 Scratch、`<C-S-O>` 打开 scratch list。
- 终端：`<C-\>` ToggleTerm 浮窗，`<C-S-P>` 打开 btop（存在即浮窗），`<C-S-Q>` 打开 `qwen` CLI。
- 路径复制：`<C-Y>` 复制相对路径、`<C-S-Y>` 复制绝对路径。

### 2.3 `Alt` 层（Insert 模式助手）

- Minuet 虚拟文本：`<A-y>` 接受、`<A-[>` 上一个建议、`<A-]>` 下一个、`<A-e>` 关闭。自动触发文件类型：Go/C/C++/Python/Rust/SQL。
- Blink `<Tab>` 链：插入模式按 `Tab` -> 先检查 Minuet 虚拟文本 -> snippet 占位 -> PUM 选择 -> Tabout 跳出括号；`<S-Tab>` 反向。使用时记得“Tab 总能跳到更 smart 的下一步”。

### 2.4 WezTerm 层

- 全部默认键禁用，`Ctrl+,` 作为终端 Leader（`config.leader`）。
- `Leader + h/j/k/l` = Pane split/导航、`Leader + x` = 关 Pane、`Leader + Enter` = 全屏、`Leader + w` 进入 Workspace 子模式（c 创建/切换、r 重命名、n/p 导航）。
- 系统级 `mod`（Mac=Cmd）仍用于拷贝/粘贴/开关 Tab，不影响 Neovim 的 `Ctrl`/`Alt` 分工。

---

## 3. 重载行为一览

### 3.1 搜索
- `/` -> `telescope.builtin.current_buffer_fuzzy_find`（模糊搜索当前文件）。
- `<leader>/` -> `live_grep`（跨项目搜索，自动携带 `--hidden`）。
- `n` / `N` -> 直接触发 “查找光标所在单词” 向下/向上（等价先 `*` / `#` 再 `n/N`），避免手动 `/`。
- `ShowKey` 命令：执行 `:ShowKey`，按任意键即可显示修饰符和 CSI-u 序列，用来调试键位冲突。

### 3.2 光标/移动核心（重点补充）

| 工具 | 映射 | 用法 | 提示 |
|------|------|------|------|
| `flash.nvim` | `s` 任意模式 -> 输入字符提示并跳转；`S` Treesitter 模式按语法节点跳转；`f/F` 也由 flash 接管 | 想象成“超级 f/t”，会弹出标记，输入两个字符快速定位 | 用 `;`/`,` 回溯；`s` 后可继续 `s` 链接。|
| `accelerated-jk` | `j/k` | 按住不放速度变快，但仍遵循 `gj/gk` 行逻辑 | 长段落快速下滑。|
| `nvim-treesitter-textobjects` | `af/if` 函数、`ac/ic` 类、`ad/id` 条件、`as` 作用域、`[% ]%` 类跳转、`[m ]m` 函数跳转、`[d ]d` 条件跳转、`[z ]z` 折叠跳转 | 更语义化的 `vim-textobj`。`select` 模式可与 `c/d/y` 组合，例如 `daf` 删除整个函数 | 背口诀：“a=outer, i=inner, m=function, z=fold, s=scope, d=conditional, [ / ] = 上/下”。|
| `vim-matchup` | `%` | Treesitter 感知下的 `%`，可在 `if/else`、`HTML` 标签之间跳 | 光标上 `%` 即扩展选择，配合 `z%` 可折叠。|
| `nvim-various-textobjs` | `viL` 选 URL、`vin` 选数字、`vii` 选同缩进块、`vi!` 选诊断等（详见 `lua/plugins/cursor/nvim-various-textobjs.lua` 与官方 README） | 需要记忆时按 `vi` + 记忆字母。例如 `vii` = current indent block | `ox` 模式同样适用（可配 `d`/`c`/`y`)。|
| `Aerial` | `{` / `}` 切换上/下一个 symbol（在 attach 时缓冲区映射） | 任何 LSP buffer 都可 `}` 看“下一个函数/类” | 相当于“结构跳转”，配合 `<leader>lo` 打开 outline。|
| `quick_substitute` | `<leader>ss` 当前行、`<leader>sS` 全局、Visual `<leader>ss` 选区 | 输入旧/新字符串时会自动选择分隔符、判断大小写、预览 `:s` 命令 | 视作“无需记 `:%s/pat/repl/g` 的 GUI”。|
| `nvim-surround` | `ysiw"` 包裹单词、`yss)` 包一整行、`ds"` 删除、`cs"'` 替换 | Normal 模式 `ys` = “you surround”，加 textobject；`ds/cs` 操作已有包裹 | 常用三招：`ysiw"`、`ds"`、`cs"'`。|

> **练习建议**：挑 `flash` + `treesitter move` + `surround` 三件套做 muscle memory。例：`s` 跳到符号 -> `dair` 删除 if 语句 -> `cs"'` 改引号。

---

## 4. 插件命名空间速查

### 4.1 LSP / Diagnostics（`lua/config/lsp/attach.lua` 等）
- `gd/gi/gt/gr` -> Telescope 版本的跳转（`reuse_win=true`，不会疯狂开窗口）。
- `<leader>lo` -> Aerial toggle，`<leader>lO` -> Workspace Symbols (Telescope)。
- `<leader>lwa/lwd/lwl` -> 工作区目录增删列。
- `<leader>lca` -> Code Action（Telescope 界面），`<leader>lci/lco` -> Call Hierarchy。
- `<leader>ltc/ltp` -> Type Hierarchy（LSP server 支持才会启用）。
- `<leader>lf` -> 漂浮诊断，`<leader>dl/dL` -> 当前文件 / 全项目诊断列表。
- `[d ]d` -> 上一个/下一个诊断，结合 `vim.diagnostic`。

### 4.2 Testing & Debugging
- **Neotest**：所有 `<leader>t*` 映射都在插件 spec 里；`[t ]t` 跳测试，`[T ]T` 跳失败测试，`tw` watch 当前文件。
- **DAP**：`F5`~`F12` + `<leader>d*`；`<F7>` 打开 DAP UI；`dap-ui` 在启动时会挟持 `K`（Normal/Visual）执行 `eval()`——停止会话后自动恢复原 `K`。

### 4.3 Git / 工具
- `Neogit` = `<leader>gs` → tab 界面，深度结合 Diffview。
- `Diffview`: `<leader>gd` = 未提交 diff、`<leader>gc` = 查看指定 commit（交互输入哈希）、`<leader>gf/gF/gl` 查看文件/仓库 commit 历史，Visual `<leader>gl` 仅选中行。
- `Yazi` / `Scratch` / `ToggleTerm` 键位参见 2.2。

### 4.4 文件、会话
- `close_or_quit` (`<leader>q`) 逻辑：如果只剩一个“真实 buffer”，直接 `confirm qa`；否则换到下个 buffer 再 `:bd` 当前，保持窗口布局。
- `persistence.nvim` (`<leader>pc/pl/px`) 控制 session；默认只有打开真实文件后才会自动保存。

---

## 5. 交互工作流示例

1. **打开/跳转结构**：`<C-P>` 找文件 -> `gd`（Telescope）跳定义 -> `}`（Aerial hook）跳下一个 symbol -> `<leader>lo` 打开大纲定位 -> `<leader>tn` 运行最近测试。
2. **冲浪式移动**：`/` 模糊搜索行 -> `s`（flash）跳到特定符号 -> `vaS` (`nvim-various-textobjs`) 选中 subword -> `cs"'` 改引号 -> `<leader>f` 只格式化修改处。
3. **Debug + 测试**：`<leader>td` 调试最近测试 -> `F9` 持久断点 -> `F5`/`F10` 走流程 -> 会话结束自动恢复 `K` 和布局。
4. **Scratch + 会话**：`<C-S-N>` 打临时文件记录笔记 -> `ScratchOpen` 随时回看 -> `<leader>pl` 恢复上一工作区 session。

---

## 6. TODO / 未来打算

1. **`<leader>a` 命名空间**：规划主动 AI 功能（例如 opencode.nvim prompt、代码解释、重构模板）。保持与 Insert `Alt` 被动补全互补，建议定义：
   - `aa` = 问题询问
   - `ap` = Prompt 选择
   - `at` = Toggle 面板等。
2. **Alt 键策略**：你暂时不想依赖 `Alt`，但 Minuet 目前占用了 `<A-y/[/>]`。长期可评估改用 `<leader>a` 接管接受/拒绝动作，让 Insert 模式回归无修饰状态。
3. **运动肌肉记忆**：挑以下组合练习并写在 Cheatsheet：`s`（flash）→`daf`、`[m/ ]m`（函数跳）、`as`（选择 scope）、`viL`（URL）、`ysiw"`（surround）、`<leader>ss`（行替换）。
4. **文档自动化**：把 `:redir` 命令写进 `Makefile`（例如 `make keymap-dump`），避免手动敲命令。

---

## 7. 参考文件索引

- `docs/keymap_dump_2025-11-17.txt`：最新 `verbose map` 输出。
- `lua/config/keymaps.lua`：基础 `<leader>`/`Ctrl` 键位、`ShowKey`、路径复制、`close_or_quit`。
- `lua/config/lsp/attach.lua` + `lua/plugins/ui/aerial.lua` + `lua/plugins/fuzzy_finder/lsp_takeover.lua`：LSP & 诊断。
- `lua/plugins/test/neotest.lua`、`lua/plugins/diagnostics/dap.lua`、`lua/plugins/diagnostics/dap-ui.lua`：测试 & 调试。
- `lua/plugins/cursor/flash.lua`、`lua/plugins/treesitter/treesitter-textobjects.lua`、`lua/plugins/cursor/nvim-various-textobjs.lua`、`lua/plugins/cursor/nvim-surround.lua`、`lua/plugins/cursor/accelerated-jk.lua`、`lua/plugins/cursor/vim-matchup.lua`：移动/选择/环绕工具。
- `lua/plugins/file/yazi.lua`、`lua/plugins/file/temporary_file.lua`、`lua/plugins/terminal/terminal.lua`：外部工具与 Scratch。
- `lua/plugins/format/conform.lua`、`lua/config/quick_substitute.lua`：格式化与替换。
- `~/.config/wezterm/config/keymaps.lua`：终端层键位结构。

> **提示**：任何插件键位都能在 `lua/plugins/**` 中找到 `keys = { ... }`。当你怀疑某键来自哪里时，优先检索 `keymap_dump`（有 `Last set from ...`），再跳到对应 Lua 文件定位。
