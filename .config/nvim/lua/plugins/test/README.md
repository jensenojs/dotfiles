# Test 插件模块

## 模块设计意图

统一的测试框架集成，提供跨语言的测试发现、运行、调试和结果可视化能力。

## 核心能力

- **跨语言支持**: Go, Python, C/C++, Rust
- **测试发现**: 基于 Treesitter 的智能测试发现
- **调试集成**: 与 nvim-dap 无缝集成
- **结果可视化**: 虚拟文本 + 摘要树 + 输出面板
- **监视模式**: 文件变化自动重跑测试

## 插件列表

### neotest.lua

**插件**: `nvim-neotest/neotest`

**仓库**: <https://github.com/nvim-neotest/neotest>

**功能**: 统一的测试运行和调试框架

**配置特点**:

- 基于 Treesitter 的精确测试发现
- 多语言适配器支持（Go, Python, C/C++）
- 完整的 DAP 调试集成
- 丰富的测试状态图标（从 `utils/icons.lua` 获取）
- 自动检测 Python 虚拟环境
- 可配置的日志级别（生产/调试）

## 使用说明

### Neotest 使用说明

Neotest 是一个Neovim测试框架，提供统一的测试发现、运行和调试体验。

#### 目标

- 在各种语言下统一"发现-运行-调试-查看结果"的测试体验
- 与 nvim-dap 集成, 实现对"最近的测试/单个用例"的断点调试

#### 当前配置概览

- 插件: `nvim-neotest/neotest`(见 `lua/plugins/test/neotest.lua`)
- 依赖: `nvim-nio`, `plenary.nvim`, `nvim-treesitter`
- 适配器:
    - Rust: `rustaceanvim.neotest`(依赖 rustaceanvim 提供的适配)
    - Go: `neotest-golang`
    - C/C++: `neotest-gtest`
    - Python: `neotest-python`

#### 快捷键 (以 `<leader>t` 为前缀)

##### 运行测试

| 快捷键 | 功能 |
|--------|------|
| `<leader>tn` | 运行光标所在的最近测试 |
| `<leader>tf` | 运行当前文件的所有测试 |
| `<leader>tA` | 运行整个项目的所有测试 |
| `<leader>tl` | 重新运行上一次的测试 |
| `<leader>ts` | 停止正在运行的测试 |

##### 调试测试

| 快捷键 | 功能 |
|--------|------|
| `<leader>td` | 使用 DAP 调试光标所在的最近测试 |
| `<leader>tD` | 使用 DAP 调试当前文件的所有测试 |

##### 查看输出和摘要

| 快捷键 | 功能 |
|--------|------|
| `<leader>to` | 显示测试输出(进入输出窗口) |
| `<leader>tO` | 切换输出面板(持续显示所有测试输出) |
| `<leader>tS` | 切换测试摘要树(显示所有测试的层级结构) |

##### 跳转

| 快捷键 | 功能 |
|--------|------|
| `[t` | 跳转到上一个测试 |
| `]t` | 跳转到下一个测试 |
| `[T` | 跳转到上一个失败的测试 |
| `]T` | 跳转到下一个失败的测试 |

##### 监视

| 快捷键 | 功能 |
|--------|------|
| `<leader>tw` | 监视当前文件(文件变化时自动重新运行测试) |

#### 常见使用场景

1. 调试单个测试用例
   - 在测试函数上设置断点
   - 将光标置于该测试函数内
   - 按 `<space>td` 使用 DAP 策略运行；命中断点后可步进/查看变量

2. 查看失败原因
   - `<space>to` 打开输出, 或打开 Trouble 查看聚合问题(失败为 0 会自动关闭)

3. 持续集成式开发
   - `<space>tw` 打开当前 buffer 的 watch, 文件改动后自动重跑最近的测试

#### 适配器扩展

- Rust 已启用 `rustaceanvim.neotest`
- Go 使用 `neotest-golang` 适配器
- C/C++ 使用 `neotest-gtest` 适配器支持 GoogleTest
- Python 使用 `neotest-python` 适配器支持 pytest

#### 运行策略与 DAP

- `require("neotest").run.run({ strategy = "dap" })` 会以 dap 会话方式运行所选测试
- 断点由 nvim-dap 管理, `dap-ui` 会随会话自动开启/关闭, 你的 `<F10>/<F11>/<F12>` 步进键照常可用

#### 注意事项

- 需要 Treesitter 解析以获取稳定的测试发现能力
- 某些语言适配器需要额外依赖(例如 Go 的 golang/test 工具)
- 如遇无法发现测试的情况, 先确认对应 adapter 已安装并被正确 setup

#### 语言特定配置

##### Go 测试

**适配器**: `neotest-golang`

**配置**:

```lua
require("neotest-golang")({
  go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
  dap_go_enabled = true,
  runner = "go",
})
```

**特性**:

- 支持表驱动测试
- 集成 Delve 调试器
- 竞态检测 (`-race`)

##### Python 测试

**适配器**: `neotest-python`

**配置**:

```lua
require("neotest-python")({
  runner = "pytest",
  python = function()
    -- 自动检测虚拟环境
    local venv = vim.env.VIRTUAL_ENV
    if venv then
      return venv .. "/bin/python"
    end
    return vim.fn.executable("python3") == 1 and "python3" or "python"
  end,
})
```

**特性**:

- 自动检测虚拟环境 (venv, conda)
- 支持 pytest fixtures
- 支持参数化测试

##### C/C++ 测试

**适配器**: `neotest-gtest`

**配置**:

```lua
require("neotest-gtest")
```

**特性**:

- 支持 GoogleTest 框架
- 支持测试夹具 (Fixtures)
- 支持参数化测试

##### Rust 测试

**适配器**: `rustaceanvim.neotest`

通过 rustaceanvim 插件提供的内置适配器。

#### 测试发现机制

Neotest 使用 Treesitter 解析代码来发现测试用例：

- **精确性**: 基于语法树，而非正则表达式
- **性能**: 增量解析，只解析变化部分
- **并发**: 配置 `concurrent = 1` 避免资源竞争

#### 测试结果展示

**虚拟文本**: 在测试函数旁显示状态图标

- ✓ 通过
- ✗ 失败
- ⟳ 运行中
- ⊘ 跳过
- ? 未知

**摘要树**: `<leader>tS` 打开分层结构

```
neotest-golang
├─ 📁 project
│  └─ 📄 add_test.go
│     └─ TestAdd ✓
```

**输出面板**: `<leader>tO` 持久显示所有测试输出

**Signs 标记**: 在行号栏显示测试状态

#### 调试集成

与 nvim-dap 无缝集成：

1. **设置断点**: `<leader>db` 或 `<F9>`
2. **调试测试**: `<leader>td`
3. **使用 DAP 快捷键**:
   - `<F5>`: 继续
   - `<F10>`: 单步跳过
   - `<F11>`: 单步进入
   - `<F12>`: 单步跳出
4. **查看变量**: 调试窗口自动打开显示作用域变量
5. **REPL 交互**: 在 REPL 中执行表达式

#### 图标配置

所有测试图标统一从 `lua/utils/icons.lua` 的 `test` 分类获取：

```lua
local icons = require("utils.icons").get("test")
icons = {
  passed = "✓",
  running = "⟳",
  failed = "✗",
  skipped = "⊘",
  unknown = "?",
  watching = "󰈈",
  running_animated = { "/", "|", "\\", "-" },
}
```

#### 日志级别

可在 `neotest.lua` 中调整：

```lua
log_level = vim.log.levels.WARN  -- 生产环境
-- log_level = vim.log.levels.DEBUG  -- 调试时启用
```

#### 故障排查

**测试未发现**:

1. 检查 Treesitter parser 是否安装: `:TSInstallInfo`
2. 检查 LSP 是否 attach: `:LspInfo`
3. 运行诊断脚本: `:luafile test_dir/neotest_debug.lua`

**调试无法启动**:

1. 检查 DAP 配置: `:lua print(vim.inspect(require('dap').configurations))`
2. 检查适配器 DAP 支持: `dap_go_enabled = true`

**Python 虚拟环境未检测**:

1. 检查环境变量: `:lua print(vim.env.VIRTUAL_ENV)`
2. 手动指定 python 路径

## 相关文档

- [DAP 调试配置](../diagnostics/README.md)
- [Treesitter 配置](../treesitter/README.md)
- [Neotest 官方文档](https://github.com/nvim-neotest/neotest)
