# nvim-treesitter Main 分支迁移指南

## 已完成的修复

### 1. ✅ 核心插件分支更新

**treesitter.lua**

- 添加 `branch = "main"`
- 修复折叠配置：`nvim_treesitter#foldexpr()` → `v:lua.vim.treesitter.foldexpr()`
- 重新启用折叠功能

**treesitter-textobjects.lua**

- 添加 `branch = "main"`
- 配置保持不变（新版兼容）

### 2. ✅ API 变化适配

| 旧 API (master) | 新 API (main) | 状态 |
|----------------|--------------|------|
| `nvim_treesitter#foldexpr()` | `v:lua.vim.treesitter.foldexpr()` | ✅ 已修复 |
| `incremental_selection` 模块 | 由 `textobjects` 提供 | ✅ 已配置 |
| 自动折叠 | 需要明确设置 `foldmethod = "expr"` | ✅ 已配置 |

## Main vs Master 分支的主要区别

### Master 分支（已归档，不再维护）

- 旧版 API 和配置结构
- 包含 `incremental_selection` 模块用于智能选择
- 折叠表达式: `nvim_treesitter#foldexpr()`
- 某些配置项使用字符串格式

### Main 分支（新版，活跃开发）

- 完全重写的代码库，性能更好
- **移除了 `incremental_selection`** - 功能整合到 `nvim-treesitter-textobjects`
- 新的折叠 API: `vim.treesitter.foldexpr()`
- 配置结构更清晰
- 更好的 LSP 集成
- 依赖插件也需要切换到 main 分支

## 为什么需要迁移？

1. **Master 分支已归档** - 不再接收更新和 bug 修复
2. **neotest-golang v2 要求** - 必须使用 main 分支
3. **性能改进** - main 分支包含大量性能优化
4. **新特性** - 只有 main 分支会添加新功能
5. **社区趋势** - 大多数插件正在或已经迁移到 main 分支

## 受影响的功能检查清单

### ✅ 已修复的功能

- [x] 基础语法高亮
- [x] Treesitter 折叠 (使用新的 foldexpr API)
- [x] Textobjects 选择 (`af`, `if`, `ac`, `ic` 等)
- [x] Textobjects 跳转 (`]m`, `[m`, `]M`, `[M` 等)
- [x] vim-matchup 集成
- [x] neotest-golang 测试发现

### ⚠️  需要验证的功能

以下功能理论上应该正常工作，但需要你手动测试确认：

#### 1. Textsubjects 智能选择

- `.` - 智能选择
- `g;` - 选择外层容器
- `gi;` - 选择内层容器

**测试方法**：
在代码中按 `.` 多次，应该逐步扩大选择范围。

#### 2. Treesitter Context (顶部固定上下文)

- 在长函数中滚动时，函数头应该固定在窗口顶部

**测试方法**：
打开一个长函数，向下滚动，检查顶部是否显示函数签名。

#### 3. Aerial 大纲功能

- `<leader>lo` - 打开/关闭大纲
- `{` / `}` - 在大纲中跳转

**测试方法**：
在有 LSP 的文件中按 `<leader>lo`，应该显示函数/类的大纲。

#### 4. DAP REPL 高亮

- 调试时 REPL 窗口应该有语法高亮

**测试方法**：
启动调试会话，检查 REPL 窗口的语法高亮。

#### 5. Bigfile 禁用逻辑

- 大文件（>200KB）应该自动禁用 Treesitter

**测试方法**：
打开一个大文件，检查语法高亮是否被禁用。

#### 6. Flash 集成

- `s` / `S` - 快速跳转
- `r` - 远程操作

**测试方法**：
按 `s` 后输入字符，应该显示跳转标签。

## 已知兼容性问题

### 1. Incremental Selection 功能

**问题**: Main 分支移除了 `incremental_selection` 模块。

**解决方案**: 使用 Textobjects 的 `select` 功能作为替代。

**原有配置**（已不再支持）:

```lua
incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = "<c-i>",
    node_incremental = "<c-i>",
    node_decremental = "<bs>",
  },
},
```

**新的替代方案**（已配置）:

```lua
-- 使用 textobjects 的 select 功能
textobjects = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      -- ... 其他映射
    },
  },
}
```

### 2. 折叠表达式变化

**问题**: 旧的 `nvim_treesitter#foldexpr()` 不再可用。

**解决方案**: 使用新的 `v:lua.vim.treesitter.foldexpr()`。

**已修复**：

```lua
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"  -- 新 API
```

## 立即验证步骤

### 1. 重新加载插件

```vim
:Lazy clean
:Lazy sync
:TSUpdate
```

### 2. 重启 Neovim

完全退出并重新打开 Neovim。

### 3. 检查 Treesitter 状态

```vim
:checkhealth nvim-treesitter
```

应该看到所有检查通过。

### 4. 测试核心功能

#### 4.1 语法高亮

打开任何支持的文件，检查是否有正确的语法高亮。

#### 4.2 折叠

```vim
" 在函数上按 zc 折叠，zo 展开
zc
zo
```

#### 4.3 Textobjects 选择

```vim
" 光标在函数内，按 vif 选择函数内部
vif

" 按 vaf 选择整个函数
vaf
```

#### 4.4 Textobjects 跳转

```vim
" 跳到下一个函数
]m

" 跳到上一个函数
[m
```

#### 4.5 Neotest

```vim
" 打开 add_test.go，打开测试摘要
<leader>tS

" 应该看到完整的测试树，不再是 "No tests found"
```

## 回退方案

如果遇到严重问题需要回退到 master 分支：

### 1. 修改配置

**treesitter.lua**:

```lua
"nvim-treesitter/nvim-treesitter",
branch = "master",  -- 改回 master
-- ...
init = function()
  -- 使用旧的 foldexpr
  vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
end,
```

**treesitter-textobjects.lua**:

```lua
"nvim-treesitter/nvim-treesitter-textobjects",
-- 移除 branch = "main" 或改为 branch = "master"
```

### 2. 重新同步

```vim
:Lazy clean
:Lazy sync
:TSUpdate
```

### 3. 注意事项

回退后，neotest-golang v2 将无法工作，你需要：

- 降级到 neotest-golang v1，或
- 使用其他 Go 测试适配器

## 常见问题排查

### Q: 语法高亮消失或不正常

**A**:

1. 检查 Treesitter 是否正确安装：`:TSInstall <language>`
2. 更新所有 parsers：`:TSUpdate`
3. 查看健康检查：`:checkhealth nvim-treesitter`

### Q: 折叠不工作

**A**:

1. 确认 foldmethod 和 foldexpr 设置正确
2. 尝试手动设置：

   ```vim
   :set foldmethod=expr
   :set foldexpr=v:lua.vim.treesitter.foldexpr()
   ```

3. 检查文件是否有 Treesitter parser

### Q: Textobjects 键位不工作

**A**:

1. 确认 nvim-treesitter-textobjects 使用 main 分支
2. 重新加载插件：`:Lazy reload nvim-treesitter-textobjects`
3. 检查是否有键位冲突：`:verbose map af`

### Q: Neotest 仍然显示 "No tests found"

**A**:

1. 确认 Go parser 已安装：`:TSInstall go`
2. 重启 LSP：`:LspRestart gopls`
3. 运行诊断脚本：`:luafile test_dir/neotest_debug.lua`

### Q: 某个插件报错或不工作

**A**:

1. 检查该插件是否依赖 Treesitter
2. 查看插件文档是否有 main 分支迁移说明
3. 尝试更新到最新版本：`:Lazy update <plugin-name>`

## 相关资源

- [nvim-treesitter main 分支公告](https://github.com/nvim-treesitter/nvim-treesitter/commit/42fc28ba918343ebfd5565147a42a26580579482)
- [nvim-treesitter-textobjects main 分支](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)
- [neotest-golang 文档](https://fredrikaverpil.github.io/neotest-golang/)
- [Reddit 讨论: Main 分支迁移](https://www.reddit.com/r/neovim/comments/1kuj9xm/)

## 总结

Main 分支迁移主要涉及：

1. ✅ 更新 `branch = "main"` 到核心 Treesitter 插件
2. ✅ 修复折叠表达式 API
3. ✅ 更新依赖插件分支
4. ⚠️  验证所有 Treesitter 相关功能

大部分问题已经修复，剩余的只需要验证即可。如果遇到问题，请查看本文档的"常见问题排查"部分。
