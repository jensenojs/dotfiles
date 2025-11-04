# WezTerm 性能诊断与优化报告

## 诊断日期

2025-11-04

## 发现的问题

### 1. 性能问题

#### 问题描述

在打开多个 pane 或 workspace 后, wezterm 出现明显的卡顿和延迟。

#### 根本原因

根据 [GitHub Issue #4788](https://github.com/wezterm/wezterm/issues/4788), 当同时满足以下条件时会出现性能瓶颈:

- 定义了 `format-tab-title` 事件处理函数
- 配置了大量的 `keys` 和 `key_tables`
- 有多个 panes/tabs/workspaces 同时运行

#### 具体原因分析

#### 原因一: `format-tab-title` 的频繁调用

每次 tab 需要重新渲染时(输出、切换焦点等), wezterm 都会调用 `format-tab-title`。原实现中:

- 调用了多个辅助函数 (`active_command`, `pane_title`, `format_directory`, `pad_to_width`)
- 每个函数都有额外的字符串处理、错误处理、pcall 等开销
- 在多 pane 环境下, 这些调用会累积造成明显延迟

#### 原因二: `update-status` 中的 shell 命令执行

原配置每 5 秒执行两次 shell 命令:

```lua
io.popen("top -l 1 | grep 'CPU usage' | awk '{print $3}' | sed 's/%//'")
io.popen("vm_stat | awk '/Pages active/ {active=$3} ...'")
```

这些命令:

- 启动了新的进程 (top, vm_stat)
- 涉及管道操作 (grep, awk, sed)
- 阻塞主线程直到命令完成
- 在多 tab/pane 环境下会放大性能影响

### 2. Workspace 模式不自动退出

#### 症状表现

在 workspace 模式下执行某些操作后, 模式不会自动退出, 需要手动按 Escape 才能退出。

#### 技术原因

#### 问题一: `PopKeyTable` 的时序问题

原配置在 `PromptInputLine` 操作中使用了 `act.Multiple`:

```lua
action = act.Multiple({
    act.PopKeyTable,
    act.PromptInputLine({...}),
})
```

这导致:

- `PopKeyTable` 立即执行, 退出 workspace 模式
- `PromptInputLine` 打开输入框
- 输入完成后, workspace 模式已经被退出

#### 问题二: 缺乏自动退出机制

对于简单操作 (如列表选择、切换 workspace), 原配置没有在操作后自动退出 workspace 模式:

```lua
{ key = 'phys:l', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) }
{ key = 'phys:n', action = act.SwitchWorkspaceRelative(1) }
```

执行后用户仍然停留在 workspace 模式, 容易误触发其他快捷键。

## 实施的优化

### 1. 优化 `format-tab-title`

#### 修改文件

`config/events.lua`

#### 优化策略

- 简化函数调用链, 减少中间辅助函数
- 直接使用 `pane.foreground_process_name` 而不是复杂的 `active_command` 逻辑
- 用简单的字符串截断替代 `pad_to_width` 的复杂逻辑
- 减少字符串拼接操作

#### 代码对比

```lua
-- 优化前
local label = active_command(pane)  -- 多次函数调用
if not label or label == "" then
    label = format_directory(pane)
end
local padded = pad_to_width(label, module_config.title_width)  -- 复杂的 padding 逻辑

-- 优化后
local label
if module_config.show_process then
    local process = pane.foreground_process_name  -- 直接访问
    if process and process ~= "" then
        label = basename(process)  -- 单次调用
    else
        label = format_directory(pane)
    end
else
    label = format_directory(pane)
end

if #label > module_config.title_width then
    label = label:sub(1, module_config.title_width - 1) .. "…"  -- 简单截断
end
```

### 2. 移除 `update-status` 中的 shell 命令

**修改文件:** `config/events.lua`

**优化策略:**

- 完全移除 CPU/内存监控的 shell 命令调用
- 清空 `set_right_status`, 避免不必要的渲染
- 建议用户使用专门的监控工具 (btop, htop) 或在 shell prompt 中显示

**代码对比:**

```lua
-- 优化前
local success, cpu_output = pcall(function()
    local handle = io.popen("top -l 1 | grep 'CPU usage' ...")
    ...
end)

-- 优化后
window:set_right_status("")  -- 空字符串
```

### 3. 修复 workspace 模式的 key_table

**修改文件:** `config/keymaps.lua`

**优化策略:**

- 移除 `PromptInputLine` 前的 `PopKeyTable`, 让输入框自然关闭
- 为简单操作 (列表、切换) 添加 `PopKeyTable`, 实现自动退出
- 增加 `phys:q` 作为额外的退出快捷键
- 调整超时时间为 3000ms

**代码对比:**

```lua
-- 优化前: 创建/切换 workspace
{
  key = 'phys:c',
  action = act.Multiple({
      act.PopKeyTable,  -- ❌ 过早退出
      act.PromptInputLine({...}),
  }),
}

-- 优化后: 创建/切换 workspace
{
  key = 'phys:c',
  action = act.PromptInputLine({...}),  -- ✅ 自然流程
}

-- 优化前: 切换 workspace
{
  key = 'phys:n',
  action = act.SwitchWorkspaceRelative(1)  -- ❌ 不退出模式
}

-- 优化后: 切换 workspace
{
  key = 'phys:n',
  action = act.Multiple({
      act.SwitchWorkspaceRelative(1),
      act.PopKeyTable,  -- ✅ 自动退出
  }),
}
```

### 4. 添加性能优化选项

**修改文件:** `config/options.lua`

**新增配置:**

```lua
-- 前端首选项 (使用 WebGpu 以获得更好的性能)
config.front_end = 'WebGpu'

-- 输入处理优化
config.allow_square_glyphs_to_overflow_width = "Never"

-- 减少 tab 栏更新频率相关的开销
config.use_fancy_tab_bar = false  -- 使用简单的 tab 栏以提升性能
config.hide_tab_bar_if_only_one_tab = false
```

## 测试建议

### 性能测试

1. **基准测试**

   ```bash
   # 使用 vtebench 测试输出性能
   git clone https://github.com/alacritty/vtebench
   cd vtebench
   cargo run --release
   ```

2. **多 pane 测试**
   - 创建 4-6 个 pane
   - 在其中一些 pane 中运行高输出程序 (如 `yes`, `find /`)
   - 在另一些 pane 中测试输入延迟

3. **多 workspace 测试**
   - 创建 3-4 个 workspace
   - 每个 workspace 中打开多个 tab 和 pane
   - 测试切换 workspace 的流畅度

### Workspace 模式测试

1. **测试列表操作**

   ```text
   Ctrl+, w -> l  (应自动退出 workspace 模式)
   ```

2. **测试切换操作**

   ```text
   Ctrl+, w -> n  (应自动退出 workspace 模式)
   Ctrl+, w -> p  (应自动退出 workspace 模式)
   ```

3. **测试输入操作**

   ```text
   Ctrl+, w -> c -> 输入名称  (输入框关闭后应退出 workspace 模式)
   Ctrl+, w -> r -> 输入名称  (输入框关闭后应退出 workspace 模式)
   ```

4. **测试手动退出**

   ```text
   Ctrl+, w -> Escape  (应退出 workspace 模式)
   Ctrl+, w -> q       (应退出 workspace 模式)
   ```

## 预期效果

### 性能提升

- **Tab 渲染延迟:** 减少 50-70%
- **状态栏更新开销:** 完全消除 (无 shell 命令)
- **多 pane 环境:** 显著减少卡顿

### 用户体验改善

- **Workspace 模式:** 操作后自动退出, 减少误触发
- **输入流程:** 更自然的交互体验
- **整体响应性:** 更流畅的终端操作

## 进一步优化建议

### 可选优化

1. **减少 tab 数量**
   - 考虑使用 workspace 代替大量 tab
   - 关闭不活跃的 tab

2. **调整 scrollback**
   - 如果不需要大量历史记录, 可以减少 `scrollback_lines`

   ```lua
   config.scrollback_lines = 5000  -- 从 10000 减少
   ```

3. **禁用某些视觉特效**

   ```lua
   config.enable_tab_bar = false  -- 完全隐藏 tab 栏 (如果不需要)
   ```

4. **使用外部系统监控**
   - 使用 `btop`, `htop` 或 `glances` 进行系统监控
   - 在 shell prompt (如 Starship) 中显示关键信息

### 监控工具推荐

- **btop:** 现代化的资源监控器

  ```bash
  brew install btop
  ```

- **Starship prompt:** 在命令行中显示系统信息

  ```bash
  brew install starship
  # 在 ~/.config/starship.toml 中配置
  ```

## 参考资源

- [WezTerm Performance Issue #4788](https://github.com/wezterm/wezterm/issues/4788)
- [WezTerm Key Tables Documentation](https://wezterm.org/config/key-tables.html)
- [WezTerm Performance Options](https://wezterm.org/config/lua/config/)

## 版本信息

- **WezTerm 版本:** 20251014-193657-64f2907c
- **操作系统:** macOS
- **优化日期:** 2025-11-04
