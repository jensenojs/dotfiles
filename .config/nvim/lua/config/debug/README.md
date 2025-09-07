# Neovim调试配置指南

## 目录结构

```
lua/config/debug/
├── init.lua              # 表驱动配置注册和初始化
├── go.lua               # Go语言：adapter + configurations
├── python.lua           # Python语言：adapter + configurations
├── cpp.lua              # C/C++/Rust：adapter + configurations
└── README.md            # 本文档
```

## 概述

本文档详细说明了如何在Neovim中配置和使用调试功能。调试功能基于Debug Adapter Protocol (DAP)实现，通过nvim-dap插件提供支持。

## 核心概念

### 语言配置文件结构

每种语言的配置文件都采用统一的结构，包含Adapter和Configuration两部分：

```lua
-- 示例：Go语言配置文件 (go.lua)
return {
  -- Adapter配置：定义如何启动调试器
  adapter = {
    type = "executable",
    command = "/path/to/dlv",
    args = {"dap", "-l", "127.0.0.1:38697"},
  },
  
  -- Configuration配置：定义调试场景
  configurations = {
    {
      type = "go",
      name = "Launch File",
      request = "launch",
      program = "${file}",
    },
    -- 更多配置...
  }
}
```

### 表驱动配置注册

在`init.lua`中使用表驱动方式统一注册所有语言配置：

```lua
local language_configs = {
  go = {
    module = "config.debug.go",
    debugger = "delve"
  },
  python = {
    module = "config.debug.python",
    debugger = "debugpy"
  },
  cpp = {
    module = "config.debug.cpp",
    debugger = "codelldb"
  }
}

-- 批量注册
for lang, config_info in pairs(language_configs) do
  if registry.is_installed(config_info.debugger) then
    local lang_config = require(config_info.module)
    dap.adapters[lang] = lang_config.adapter
    dap.configurations[lang] = lang_config.configurations
  end
end
```

## 配置协调机制

### 注册和匹配过程

1. **Adapter注册**：

   ```lua
   dap.adapters.go = { /* adapter配置 */ }
   ```

2. **Configuration注册**：

   ```lua
   dap.configurations.go = { /* configuration配置 */ }
   ```

3. **运行时匹配**：
   当用户选择一个调试配置时：
   - 查找配置中的`type`字段（如"go"）
   - 根据`type`找到对应的Adapter配置
   - 启动Adapter指定的调试器
   - 将Configuration参数传递给调试器

### 表驱动配置模式

nvim-dap采用表驱动配置模式，这是一种声明式的配置管理方式，具有以下特点：

#### 1. 配置即数据

所有的配置都通过Lua表来定义，而不是通过函数调用：

```lua
-- 语言配置映射表
local language_configs = {
  go = {
    module = "config.debug.go",
    debugger = "delve"
  },
  python = {
    module = "config.debug.python",
    debugger = "debugpy"
  }
}
```

#### 2. 批量处理能力

可以使用循环批量处理配置：

```lua
-- 批量注册所有语言配置
for lang, config_info in pairs(language_configs) do
  if registry.is_installed(config_info.debugger) then
    local lang_config = require(config_info.module)
    dap.adapters[lang] = lang_config.adapter
    dap.configurations[lang] = lang_config.configurations
  end
end
```

#### 3. 模块化组织

每种语言的配置集中在一个文件中：

```
go.lua        # Go: adapter + configurations
python.lua    # Python: adapter + configurations
cpp.lua       # C/C++/Rust: adapter + configurations
```

#### 4. 表驱动的优势

- **声明式**：配置是声明式的，易于理解和维护
- **模块化**：每种语言配置独立，便于管理
- **可扩展**：添加新语言支持只需添加新的配置文件
- **可测试**：表结构易于进行单元测试

## 工具函数使用

### utils.dap模块

提供调试会话中常用的工具函数：

1. **input_args()** - 获取用户输入的程序参数
2. **input_exec_path()** - 获取可执行文件路径
3. **input_file_path()** - 获取被调试文件路径
4. **get_env()** - 获取环境变量

### 使用模式

工具函数采用三层调用模式以适配nvim-dap的延迟调用场景：

```lua
-- 三层调用：require("utils.dap").function()()()
dap.configurations.go = {
  {
    type = "go",
    name = "Launch with args",
    request = "launch",
    program = "${file}",
    args = require("utils.dap").input_args()(),  -- 用户输入参数
  }
}
```

## 添加新语言支持流程

### 1. 创建语言配置文件

在`lua/config/debug/`目录下创建新的语言配置文件：

```lua
-- example.lua
return {
  adapter = {
    type = "executable",
    command = "debugger-command",
    args = {"arguments"},
  },
  configurations = {
    {
      type = "example",
      name = "Launch File",
      request = "launch",
      program = require("utils.dap").input_file_path()(),
    }
  }
}
```

### 2. 更新初始化配置

在`init.lua`的`language_configs`表中添加新语言：

```lua
local language_configs = {
  -- ... existing languages ...
  example = {
    module = "config.debug.example",
    debugger = "example-debugger"
  }
}
```

### 3. 确保调试器已安装

通过mason安装对应的调试器：

```lua
-- 在lua/utils/mason_list.lua中添加
example = {
  servers = { /* LSP servers */ },
  tools = { "example-debugger" },
}
```

## 键位绑定

### 全局键位

- `F5` - 继续执行
- `F9` - 切换断点
- `F10` - 单步跳过
- `F11` - 单步进入
- `F12` - 单步跳出

### 调试会话期间键位

- 调试会话开始时可能覆盖某些LSP键位
- 调试会话结束时恢复原始键位

## 调试UI管理

### 生命周期管理

```lua
-- 调试会话开始时打开UI
dap.listeners.after.event_initialized["dapui"] = function()
  dapui.open()
end

-- 调试会话结束时关闭UI
dap.listeners.before.event_terminated["dapui"] = function()
  dapui.close()
end
```

## 常见问题和解决方案

### 调试器未找到

检查：

1. 调试器是否已通过mason安装
2. 调试器路径是否正确
3. 环境变量是否设置正确

### 配置不生效

检查：

1. 配置是否在正确的时机加载
2. Adapter和Configuration的type是否匹配
3. 是否有语法错误

### 调试会话无法启动

检查：

1. 端口是否被占用
2. 程序路径是否正确
3. 权限是否足够
