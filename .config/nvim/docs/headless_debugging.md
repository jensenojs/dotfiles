# 无头调试指南

## 概述

无头调试允许在没有完整GUI环境的情况下测试Neovim配置和插件。这对于以下场景至关重要：

- 自动化测试配置变更
- CI/CD流水线验证
- 调试LSP和插件加载问题
- 提交前验收测试

## 基本命令

### 无头运行Neovim

```bash
# 基本无头模式
nvim --headless

# 执行命令后退出
nvim --headless -c "echo 'Hello'" -c "qa"

# 加载并执行Lua脚本
nvim --headless -c "luafile script.lua"

# 直接执行Vim命令
nvim --headless -c "set number" -c "echo &number" -c "qa"
```

### 关键选项

- `--headless`: 无UI运行，输出到stdout/stderr
- `-c "command"`: 在加载文件前执行Vim命令
- `-S session.vim`: 加载Vim脚本
- `+command`: 在加载第一个文件后执行命令
- `-u NONE`: 跳过用户配置（用于最小化测试）

## 验收测试技术

### 1. 插件加载测试

```lua
-- test_plugin_loading.lua
print("测试插件加载...")

local ok, plugin = pcall(require, "plugin_name")
if ok then
    print("✅ 插件加载成功")
    -- 测试基本功能
    if plugin.some_function then
        print("✅ 核心功能可用")
    end
else
    print("❌ 插件加载失败:", plugin)
end

vim.cmd("qa!")
```

运行方式：

```bash
nvim --headless -c "luafile test_plugin_loading.lua"
```

### 2. LSP引导测试

```lua
-- test_lsp_bootstrap.lua
print("测试LSP引导...")

-- 测试LSP启用功能
local ok_enable, result = pcall(vim.lsp.enable, "gopls", {
    filetypes = {"go"},
    root_markers = {"go.mod", ".git"}
})

if ok_enable then
    print("✅ LSP启用成功")
else
    print("❌ LSP启用失败:", result)
end

-- 等待LSP初始化
vim.wait(2000)

-- 检查活跃客户端
local clients = vim.lsp.get_clients()
print("活跃LSP客户端:", #clients)

vim.cmd("qa!")
```

### 3. Neotest集成测试

```lua
-- test_neotest_integration.lua
print("测试Neotest集成...")

-- 加载neotest
local ok_neotest, neotest = pcall(require, "neotest")
if not ok_neotest then
    print("❌ Neotest加载失败:", neotest)
    vim.cmd("qa!")
    return
end

-- 加载适配器
local ok_adapter, adapter = pcall(require, "neotest-golang")
if not ok_adapter then
    print("❌ 适配器加载失败:", adapter)
    vim.cmd("qa!")
    return
end

-- 设置neotest
neotest.setup({
    adapters = { adapter() },
    status = { virtual_text = true }
})

print("✅ Neotest设置完成")

-- 测试适配器识别
local test_file = "test_file.go"
vim.cmd("edit " .. test_file)

if adapter.is_test_file(vim.fn.expand("%")) then
    print("✅ 测试文件已识别")
else
    print("❌ 测试文件未识别")
end

vim.cmd("qa!")
```

## 高级技术

### 模拟依赖

```lua
-- 为测试模拟LSP
_G.mock_lsp = {
    get_clients = function() return {{name = "mock_lsp"}} end,
    enable = function() return true end
}

-- 临时替换vim.lsp
local original_lsp = vim.lsp
vim.lsp = mock_lsp

-- 运行测试
require("your_plugin").test_function()

-- 恢复
vim.lsp = original_lsp
```

### 使用真实文件测试

```bash
# 创建测试文件并运行测试
echo 'package main

import "testing"

func TestExample(t *testing.T) {
    t.Log("Test example")
}' > test_example.go

# 在文件上运行neotest
nvim --headless -c "edit test_example.go" -c "lua require('neotest').run.run()" -c "qa"
```

### 捕获输出

```bash
# 重定向输出到文件
nvim --headless -c "luafile test.lua" > output.log 2>&1

# 检查结果
cat output.log
```

## 常见模式

### 错误处理包装器

```lua
local function test_with_error_handling(description, test_func)
    print("测试:", description)
    local ok, result = pcall(test_func)
    if ok then
        print("✅ 通过")
    else
        print("❌ 失败:", result)
    end
    return ok
end

-- 使用方法
test_with_error_handling("插件加载", function()
    require("some_plugin")
end)
```

### 异步测试

```lua
local function async_test()
    print("开始异步测试...")

    -- 延迟后调度测试
    vim.defer_fn(function()
        local result = perform_test()
        print("异步测试结果:", result)
        vim.cmd("qa!")
    end, 1000) -- 1秒延迟
end

async_test()
```

## 调试技巧

### 详细输出

```bash
# 启用详细日志
NVIM_LOG_FILE=/tmp/nvim.log nvim --headless -V3 -c "luafile test.lua"

# 检查日志
tail -f /tmp/nvim.log
```

### 检查状态

```lua
-- 转储当前状态
print("当前目录:", vim.fn.getcwd())
print("运行时路径:", vim.inspect(vim.opt.rtp:get()))
print("已加载模块:", vim.inspect(package.loaded))
```

### 内存和性能

```bash
# 分析启动时间
time nvim --headless -c "lua print('启动完成')" -c "qa"

# 检查内存使用（需要外部工具）
ps aux | grep nvim
```

## CI/CD集成

### GitHub Actions示例

```yaml
- name: 测试Neovim配置
  run: |
    nvim --headless -c "luafile test_config.lua" -c "qa"

- name: 测试插件加载
  run: |
    nvim --headless -c "luafile test_plugins.lua" > test_output.log
    if grep -q "❌" test_output.log; then
      echo "测试失败"
      cat test_output.log
      exit 1
    fi
```

## 最佳实践

1. **隔离**: 独立测试组件
2. **清理**: 总是调用`vim.cmd("qa!")`退出
3. **超时**: 对异步操作使用`vim.wait()`
4. **错误上下文**: 包含详细错误信息
5. **状态重置**: 在测试间清理全局状态
6. **文档**: 详细注释测试脚本
7. **版本控制**: 将测试脚本保存在仓库中

## 故障排除

### 常见问题

- **LSP不可用**: 某些LSP功能需要完整Neovim运行时
- **插件依赖**: 确保所有依赖都已安装
- **时序问题**: 对异步操作使用`vim.wait()`
- **路径问题**: 在无头模式中使用绝对路径
- **权限错误**: 检查文件权限

### 调试命令

```bash
# 检查Neovim版本和功能
nvim --version

# 测试Lua执行
nvim --headless -c "lua print(_VERSION)"

# 检查插件安装
nvim --headless -c "lua print(vim.fn.stdpath('data'))"
```

### Key Options

- `--headless`: Run without UI, output goes to stdout/stderr
- `-c "command"`: Execute Vim command before loading files
- `-S session.vim`: Source a Vim script
- `+command`: Execute command after loading first file
- `-u NONE`: Skip loading user config (for minimal testing)

## Acceptance Testing Techniques

### 1. Plugin Loading Tests

```lua
-- test_plugin_loading.lua
print("Testing plugin loading...")

local ok, plugin = pcall(require, "plugin_name")
if ok then
    print("✅ Plugin loaded successfully")
    -- Test basic functionality
    if plugin.some_function then
        print("✅ Core functions available")
    end
else
    print("❌ Plugin failed to load:", plugin)
end

vim.cmd("qa!")
```

Run with:

```bash
nvim --headless -c "luafile test_plugin_loading.lua"
```

### 2. LSP Bootstrap Tests

```lua
-- test_lsp_bootstrap.lua
print("Testing LSP bootstrap...")

-- Test LSP enable function
local ok_enable, result = pcall(vim.lsp.enable, "gopls", {
    filetypes = {"go"},
    root_markers = {"go.mod", ".git"}
})

if ok_enable then
    print("✅ LSP enable succeeded")
else
    print("❌ LSP enable failed:", result)
end

-- Wait for LSP to initialize
vim.wait(2000)

-- Check active clients
local clients = vim.lsp.get_clients()
print("Active LSP clients:", #clients)

vim.cmd("qa!")
```

### 3. Neotest Integration Tests

```lua
-- test_neotest_integration.lua
print("Testing Neotest integration...")

-- Load neotest
local ok_neotest, neotest = pcall(require, "neotest")
if not ok_neotest then
    print("❌ Neotest load failed:", neotest)
    vim.cmd("qa!")
    return
end

-- Load adapter
local ok_adapter, adapter = pcall(require, "neotest-golang")
if not ok_adapter then
    print("❌ Adapter load failed:", adapter)
    vim.cmd("qa!")
    return
end

-- Setup neotest
neotest.setup({
    adapters = { adapter() },
    status = { virtual_text = true }
})

print("✅ Neotest setup complete")

-- Test adapter recognition
local test_file = "test_file.go"
vim.cmd("edit " .. test_file)

if adapter.is_test_file(vim.fn.expand("%")) then
    print("✅ Test file recognized")
else
    print("❌ Test file not recognized")
end

vim.cmd("qa!")
```

## Advanced Techniques

### Mocking Dependencies

```lua
-- Mock LSP for testing
_G.mock_lsp = {
    get_clients = function() return {{name = "mock_lsp"}} end,
    enable = function() return true end
}

-- Temporarily replace vim.lsp
local original_lsp = vim.lsp
vim.lsp = mock_lsp

-- Run tests
require("your_plugin").test_function()

-- Restore
vim.lsp = original_lsp
```

### Testing with Real Files

```bash
# Create test file and run tests
echo 'package main

import "testing"

func TestExample(t *testing.T) {
    t.Log("Test example")
}' > test_example.go

# Run neotest on the file
nvim --headless -c "edit test_example.go" -c "lua require('neotest').run.run()" -c "qa"
```

### Capturing Output

```bash
# Redirect output to file
nvim --headless -c "luafile test.lua" > output.log 2>&1

# Check results
cat output.log
```

## Common Patterns

### Error Handling Wrapper

```lua
local function test_with_error_handling(description, test_func)
    print("Testing:", description)
    local ok, result = pcall(test_func)
    if ok then
        print("✅ PASSED")
    else
        print("❌ FAILED:", result)
    end
    return ok
end

-- Usage
test_with_error_handling("Plugin loading", function()
    require("some_plugin")
end)
```

### Async Testing

```lua
local function async_test()
    print("Starting async test...")

    -- Schedule test after delay
    vim.defer_fn(function()
        local result = perform_test()
        print("Async test result:", result)
        vim.cmd("qa!")
    end, 1000) -- 1 second delay
end

async_test()
```

## Debugging Tips

### Verbose Output

```bash
# Enable verbose logging
NVIM_LOG_FILE=/tmp/nvim.log nvim --headless -V3 -c "luafile test.lua"

# Check logs
tail -f /tmp/nvim.log
```

### Inspecting State

```lua
-- Dump current state
print("Current directory:", vim.fn.getcwd())
print("Runtime path:", vim.inspect(vim.opt.rtp:get()))
print("Loaded modules:", vim.inspect(package.loaded))
```

### Memory and Performance

```bash
# Profile startup time
time nvim --headless -c "lua print('Startup complete')" -c "qa"

# Check memory usage (requires external tools)
ps aux | grep nvim
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Test Neovim Configuration
  run: |
    nvim --headless -c "luafile test_config.lua" -c "qa"

- name: Test Plugin Loading
  run: |
    nvim --headless -c "luafile test_plugins.lua" > test_output.log
    if grep -q "❌" test_output.log; then
      echo "Tests failed"
      cat test_output.log
      exit 1
    fi
```

## Best Practices

1. **Isolation**: Test components independently
2. **Cleanup**: Always call `vim.cmd("qa!")` to exit
3. **Timeouts**: Use `vim.wait()` for async operations
4. **Error Context**: Include detailed error messages
5. **State Reset**: Clean up global state between tests
6. **Documentation**: Comment test scripts thoroughly
7. **Version Control**: Keep test scripts in repository

## Troubleshooting

### Common Issues

- **LSP not available**: Some LSP features require full Neovim runtime
- **Plugin dependencies**: Ensure all dependencies are installed
- **Timing issues**: Use `vim.wait()` for async operations
- **Path issues**: Use absolute paths in headless mode
- **Permission errors**: Check file permissions for test files

### Debug Commands

```bash
# Check Neovim version and features
nvim --version

# Test Lua execution
nvim --headless -c "lua print(_VERSION)"

# Check plugin installation
nvim --headless -c "lua print(vim.fn.stdpath('data'))"
```</content>
<filePath>docs/headless_debugging.md
