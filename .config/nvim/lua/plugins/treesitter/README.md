# Treesitter 插件模块

## 模块设计意图

提供基于语法树的代码解析能力，支持精确的语法高亮、代码折叠、语义选择和导航等功能。

## 核心能力

- **精确语法高亮**: 基于语法树而非正则表达式
- **代码折叠**: 智能的语法感知折叠
- **语义选择**: 基于AST的文本对象
- **增量解析**: 只解析变化部分，性能优秀
- **多语言支持**: 50+ 语言 parser

## 重要说明

**当前使用 `main` 分支**（不是 `master` 分支）

原因：

- `neotest-golang v2` 强制要求 main 分支
- main 分支是活跃开发分支，性能更好
- master 分支已归档，不再维护

## 插件列表

### treesitter.lua

**插件**: `nvim-treesitter/nvim-treesitter`

**仓库**: <https://github.com/nvim-treesitter/nvim-treesitter>

**分支**: `main`

**功能**: Treesitter 核心插件

**配置特点**:

- 自动安装常用语言 parser
- 启用语法高亮、缩进、折叠
- 大文件自动禁用（>200KB）
- 使用新的折叠 API: `vim.treesitter.foldexpr()`

### treesitter-textobjects.lua

**插件**: `nvim-treesitter/nvim-treesitter-textobjects`

**仓库**: <https://github.com/nvim-treesitter/nvim-treesitter-textobjects>

**分支**: `main`

**功能**: 语义文本对象和导航

**配置特点**:

- 语义选择（`vif`, `vaf`, `vac`, `vic`）
- 语义跳转（`]m`, `[m`, `]]`, `[[`）
- 参数交换（默认禁用）
- 从 `utils/icons.lua` 获取图标（如需）

### treesitter-textsubjects.lua

**插件**: `RRethy/nvim-treesitter-textsubjects`

**仓库**: <https://github.com/RRethy/nvim-treesitter-textsubjects>

**功能**: 启发式语义选择

**配置特点**:

- 智能选择（`.` 键逐步扩大选择）
- 容器选择（`g;`, `gi;`）
- 降低记忆负担，与 textobjects 互补

### treesitter-context.lua

**插件**: `nvim-treesitter/nvim-treesitter-context`

**仓库**: <https://github.com/nvim-treesitter/nvim-treesitter-context>

**功能**: 固定当前上下文

**配置特点**:

- 滚动时在顶部显示函数/类签名
- 自动适配窗口大小
- 可配置显示行数

## 快捷键

### 语义选择 (Textobjects)

| 快捷键 | 功能 |
|--------|------|
| `vif` | 选中函数内部 |
| `vaf` | 选中整个函数 |
| `vic` | 选中类内部 |
| `vac` | 选中整个类 |
| `vid` | 选中条件内部 |
| `vad` | 选中整个条件 |

### 语义跳转 (Textobjects)

| 快捷键 | 功能 |
|--------|------|
| `]m` | 跳到下一个函数开始 |
| `[m` | 跳到上一个函数开始 |
| `]M` | 跳到下一个函数结束 |
| `[M` | 跳到上一个函数结束 |
| `]]` | 跳到下一个类开始 |
| `[[` | 跳到上一个类开始 |
| `][` | 跳到下一个类结束 |
| `[]` | 跳到上一个类结束 |
| `]d` | 跳到下一个条件 |
| `[d` | 跳到上一个条件 |

### 智能选择 (Textsubjects)

| 快捷键 | 功能 |
|--------|------|
| `.` | 智能选择（多次按逐步扩大） |
| `g;` | 选择外层容器 |
| `gi;` | 选择内层容器 |
| `,` | 回退到上一次选择 |

## Main vs Master 分支差异

### Master 分支（已归档）

- 旧版 API
- 包含 `incremental_selection` 模块
- 折叠使用 `nvim_treesitter#foldexpr()`
- 不再维护

### Main 分支（当前使用）

- 完全重写，性能更好
- 移除 `incremental_selection`（功能整合到 textobjects）
- 折叠使用 `v:lua.vim.treesitter.foldexpr()`
- 活跃开发
- **neotest-golang v2 强制要求**

### 迁移要点

1. **折叠配置**:

   ```lua
   -- 旧 (master)
   vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
   
   -- 新 (main)
   vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
   ```

2. **Textobjects 配置**:

   ```lua
   -- 旧 (master)
   main = "nvim-treesitter.configs",
   opts = { textobjects = {...} }
   
   -- 新 (main)
   config = function()
     require("nvim-treesitter-textobjects").setup({...})
   end
   ```

3. **Parser 检查**:

   ```lua
   -- 旧 (master)
   require("nvim-treesitter.parsers").has_parser("go")
   
   -- 新 (main) - API 可能变化，需要兼容性检查
   local ok, parsers = pcall(require, "nvim-treesitter.parsers")
   if ok and parsers.has_parser then
     parsers.has_parser("go")
   end
   ```

## 常用命令

### Parser 管理

```vim
:TSInstall <language>        " 安装 parser
:TSUninstall <language>      " 卸载 parser
:TSUpdate                    " 更新所有 parser
:TSInstallInfo               " 查看 parser 状态
```

### 高亮调试

```vim
:TSHighlightCapturesUnderCursor  " 显示光标下的高亮组
:Inspect                          " Neovim 0.9+ 内置命令
```

### 健康检查

```vim
:checkhealth nvim-treesitter
```

## 语言支持

### 已配置的 Parser

在 `treesitter.lua` 的 `ensure_installed` 中：

```lua
ensure_installed = {
  "bash", "c", "cpp", "cmake",
  "go", "gomod", "gosum", "gowork",
  "python", "lua", "vim", "vimdoc",
  "rust", "toml",
  "javascript", "typescript", "tsx",
  "json", "yaml", "markdown",
  "dap_repl",  -- DAP REPL 高亮
}
```

### 添加新语言

1. 检查是否支持: <https://github.com/nvim-treesitter/nvim-treesitter#supported-languages>
2. 安装: `:TSInstall <language>`
3. 添加到 `ensure_installed` 列表

## 性能优化

### 大文件处理

自动禁用 Treesitter（>200KB）:

```lua
local st = vim.uv.fs_stat(name)
local max = 200 * 1024
if st and st.size > max then
  -- 不启用 treesitter
end
```

### 增量解析

Treesitter 自动进行增量解析，只解析变化的部分。

### 并发安装

```lua
auto_install = true,  -- 自动安装缺失的 parser
```

## 故障排查

### 语法高亮不正常

1. 检查 parser 是否安装: `:TSInstallInfo`
2. 重新安装: `:TSUninstall <lang>` 然后 `:TSInstall <lang>`
3. 检查健康: `:checkhealth nvim-treesitter`

### 折叠不工作

1. 检查 foldmethod: `:set foldmethod?` 应该是 `expr`
2. 检查 foldexpr: `:set foldexpr?` 应该是 `v:lua.vim.treesitter.foldexpr()`
3. 手动设置:

   ```vim
   :set foldmethod=expr
   :set foldexpr=v:lua.vim.treesitter.foldexpr()
   ```

### Textobjects 不工作

1. 检查插件是否加载: `:Lazy`
2. 检查分支: 应该是 `main`
3. 重新加载: `:Lazy reload nvim-treesitter-textobjects`

### Parser 编译失败

1. 检查编译工具: `gcc` 或 `clang`
2. macOS: `xcode-select --install`
3. 查看错误日志: `:TSInstallInfo` 中的错误信息

## 相关文档

- [Treesitter 迁移指南](../../../docs/TREESITTER_MIGRATION.md)
- [Treesitter 验证清单](../../../docs/验证treesitter.md)
- [nvim-treesitter 官方文档](https://github.com/nvim-treesitter/nvim-treesitter)

---

# 使用指南

- 大纲
    - 这部分讨论: 插件各自的能力、现成的键位怎么用、它们如何协作、常见工作流
    - 可视化: mermaid 结构图、ascii-tree 调用路径

## 组合概览

这套 treesitter 组合已经配置好, 可以直接用:

- nvim-treesitter: 解析语法树, 提供高亮/折叠/增量选择等核心能力。
    - 配置: `lua/plugins/treesitter/treesitter.lua` 中 `opts.highlight`、自动折叠初始化见(33-60), 应用配置见(61-63)
    - 仓库: <https://github.com/nvim-treesitter/nvim-treesitter>
- nvim-treesitter-textobjects: 基于查询的选择/跳转/交换/LSP 互操作。
    - 配置: `lua/plugins/treesitter/treesitter-textobjects.lua` 的 `opts` 与 `config()`(61-84)
    - 仓库: <https://github.com/nvim-treesitter/nvim-treesitter-textobjects>
- nvim-treesitter-textsubjects: 基于光标位置的“智能/容器内外”选择, 降低记忆成本。
    - 配置: `lua/plugins/treesitter/treesitter-textsubjects.lua` 的 `opts`(7-17)
    - 仓库: <https://github.com/RRethy/nvim-treesitter-textsubjects>
- nvim-treesitter-context: 窗口顶部显示当前语法上下文, 聚焦所在函数/类头部。
    - 说明: 本仓库保持默认行为; 如需自定义, 取消注释 `treesitter-context.lua` 的 `setup()`(15-17)
    - 仓库: <https://github.com/nvim-treesitter/nvim-treesitter-context>

```mermaid
flowchart LR
  K[按键输入] -->|af/if/ac/...| TO[textobjects.select]
  K -->|]m [[ ]M [M ...| TO_MOVE[textobjects.move]
  K -->|; ,| TO_REPEAT[repeatable_move]
  K -->|g; gi; .| TSUB[textsubjects]
  Parser[nvim-treesitter 解析器] -->|queries| TO & TSUB
  View[treesitter-context 顶部上下文] --> UI
  TO & TSUB --> UI[编辑器状态: 选区/光标/跳转]
```

## 键位与用法

- textobjects.select
    - `af`/`if`: 选择函数(外/内)。`treesitter-textobjects.lua`(13-14)
    - `ac`/`ic`: 选择类(外/内)。`treesitter-textobjects.lua`(15-16)
    - `as`: 选择语言作用域(scope)。`treesitter-textobjects.lua`(17)
    - `ad`/`id`: 选择条件语句(外/内)。`treesitter-textobjects.lua`(18-19)
    - 选择模式: 函数按行、类按块等。`treesitter-textobjects.lua`(21-25)

- textobjects.move
    - `]m`/`[m`: 到函数起始/上一个。`treesitter-textobjects.lua`(33,44)
    - `]]`/`[[` 与 `][`/`[]`: 到类开始/结束/上一个/下一个。`treesitter-textobjects.lua`(34-45,39-49)
    - `]o`: 到循环; `]s`: 到作用域; `]z`: 到折叠。`treesitter-textobjects.lua`(35-37)
    - `]d`/`[d`: 在条件间跳转。`treesitter-textobjects.lua`(51-52)

- textobjects.repeatable_move
    - `;`: 重复上一次语义跳转(向前)。`,`: 向后。绑定见 `treesitter-textobjects.lua`(70-80)

- textobjects.swap(默认关闭)
    - `<leader>a`/`<leader>A`: 交换参数(下一个/上一个)。`treesitter-textobjects.lua`(55-58)

- textsubjects(与 select 互补, 更“就近/智能”)
    - `.`: 智能选择(根据语境挑最相关)。`treesitter-textsubjects.lua`(11)
    - `g;`: 选择容器(外)。`treesitter-textsubjects.lua`(15)
    - `gi;`: 选择容器(内)。`treesitter-textsubjects.lua`(16)
    - 提示: 默认的 `;`/`i;` 已改为 `g;`/`gi;` 以避开可重复移动的 `;`/`,` 冲突。

- treesitter-context
    - 自动显示语法上下文行; 默认配置即可使用。
    - 若要细化(如 max_lines/分隔线), 取消注释 `treesitter-context.lua` 的 `setup()`(15-17)

## 执行流与调用路径

- 调用路径

```
treesitter.lua (config) ──▶ require("nvim-treesitter.configs").setup(opts)   # treesitter.lua(61-63)
                                                 │
                                                 ├─ highlight/indent/fold...
                                                 └─ matchup

treesitter-textobjects.lua ──▶ configs.setup({ textobjects = opts })          # textobjects.lua(61-64)
                              └─ 绑定 ; , 可重复移动                         # textobjects.lua(70-80)

treesitter-textsubjects.lua ──▶ configs.setup({ textsubjects = opts })        # textsubjects.lua(19-21)

treesitter-context.lua ──▶ 默认生效; 如需 opts, 调用 setup(opts)              # context.lua(15-17 注释)
```

- 折叠自动化
    - 首次读入 buffer 时, 当解析器可用且文件不大时启用 expr 折叠并设置 `foldlevel=10`。
    - 触发逻辑: `treesitter.lua` 的 `init()` 自动命令组, 见(33-60)

## 常见操作流

- 粗选容器 → 细化内容
    - g; 选函数/类外层 → gi; 进入内部 → . 智能微调选区

- 语义跳转 → 重复
    - 先用 ]m/[[/]] 等跳转 → `;`/`,` 重复上次方向

- 参数重排(需手动启用 swap)
    - 开启 `swap.enable=true` 后, 用 `<leader>a`/`<leader>A` 在参数间调序

## 设计取舍与注意

- 键位冲突的平衡
    - 我们将 textsubjects 默认的 `;`/`i;` 改为 `g;`/`gi;`, 把 `;`/`,` 让给 repeatable_move, 实现“所有语义跳转都可重复”。
    - `,` 在 textobjects.repeat 与 textsubjects.prev_selection 都有用途。当前两者并存, 若出现冲突可在 `treesitter-textsubjects.lua` 改 `prev_selection`(9) 或将其置空禁用。

- 状态与能力边界
    - textobjects 面向命名节点, 需要你知道“大概想要什么对象”。textsubjects 倾向“就近选你想要的”。
    - 两者组合: 先粗定位(跳转/容器), 再智能细化(智能/内层)。

## 参考链接

- nvim-treesitter: <https://github.com/nvim-treesitter/nvim-treesitter>
- textobjects: <https://github.com/nvim-treesitter/nvim-treesitter-textobjects>
- textsubjects: <https://github.com/RRethy/nvim-treesitter-textsubjects>
- treesitter-context: <https://github.com/nvim-treesitter/nvim-treesitter-context>
