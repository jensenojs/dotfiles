-- ============================================================================
-- WezTerm 快捷键配置
-- ============================================================================
-- 设计理念（简化版）:
--   Layer 0: Shell/Neovim Passthrough
--   Layer 1: 全部使用 Leader 模式 (Ctrl+,)
--   Layer 2: Modal Operations (Copy Mode, Search Mode, Workspace Mode)
-- ============================================================================

local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply(config, platform)
   local mod = platform.mod -- SUPER on Mac, ALT on Linux

   -- =========================================================================
   -- 禁用默认快捷键
   -- =========================================================================
   config.disable_default_key_bindings = true

   -- =========================================================================
   -- 主快捷键配置
   -- =========================================================================
   config.keys = {
      -- ======================================================================
      -- Leader Key Activation
      -- ======================================================================
      {
         key = 'phys:Comma',
         mods = 'CTRL',
         action = act.ActivateKeyTable({
            name = 'leader',
            timeout_milliseconds = 2000,
            one_shot = false,
         }),
      },

      -- ======================================================================
      -- 基础操作（保留最常用的 MOD 快捷键）
      -- ======================================================================
      -- Copy/Paste
      { key = 'phys:c', mods = mod, action = act.CopyTo('Clipboard') },
      { key = 'phys:v', mods = mod, action = act.PasteFrom('Clipboard') },

      -- Tab 切换
      { key = '[', mods = mod, action = act.ActivateTabRelative(-1) },
      { key = ']', mods = mod, action = act.ActivateTabRelative(1) },
      { key = '1', mods = mod, action = act.ActivateTab(0) },
      { key = '2', mods = mod, action = act.ActivateTab(1) },
      { key = '3', mods = mod, action = act.ActivateTab(2) },
      { key = '4', mods = mod, action = act.ActivateTab(3) },
      { key = '5', mods = mod, action = act.ActivateTab(4) },
      { key = '6', mods = mod, action = act.ActivateTab(5) },
      { key = '7', mods = mod, action = act.ActivateTab(6) },
      { key = '8', mods = mod, action = act.ActivateTab(7) },
      { key = '9', mods = mod, action = act.ActivateTab(8) },
      { key = '0', mods = mod, action = act.ActivateTab(-1) },

      -- 字体
      { key = '=', mods = mod, action = act.IncreaseFontSize },
      { key = '-', mods = mod, action = act.DecreaseFontSize },

      -- 重载配置
      { key = 'phys:r', mods = mod, action = act.ReloadConfiguration },
   }

   -- =========================================================================
   -- Key Tables (Modal Operations)
   -- =========================================================================
   config.key_tables = {
      -- ======================================================================
      -- Leader Mode
      -- ======================================================================
      leader = {
         -- Window
         { key = 'phys:n', action = act.SpawnWindow },
         { key = 'Enter', action = act.ToggleFullScreen },

         -- Tab
         { key = 'phys:t', action = act.SpawnTab('CurrentPaneDomain') },
         { key = 'phys:w', action = act.CloseCurrentTab({ confirm = true }) },

         -- Pane 分割
         { key = 'phys:h', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
         { key = 'phys:v', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },

         -- Pane 操作
         { key = 'phys:x', action = act.CloseCurrentPane({ confirm = true }) },
         { key = 'phys:z', action = act.TogglePaneZoomState },
         { key = 'phys:o', action = act.ActivatePaneDirection('Next') },
         { key = 'phys:s', action = act.PaneSelect({ mode = 'SwapWithActive' }) },

         -- Copy Mode & Quick Select
         { key = '[', action = act.ActivateCopyMode },
         { key = 'phys:f', action = act.QuickSelect },

         -- Search
         { key = '/', action = act.Search({ CaseSensitiveString = '' }) },

         -- Workspace 子模式：按 W 激活
         {
            key = 'phys:W',
            mods = 'SHIFT',
            action = act.ActivateKeyTable({
               name = 'workspace',
               timeout_milliseconds = 1000,
            }),
         },

         -- 系统功能
         { key = 'phys:p', action = act.ActivateCommandPalette },
         { key = 'phys:Space', action = act.ShowLauncher },

         -- 背景切换
         {
            key = 'phys:b',
            action = wezterm.action_callback(function(window, _)
               local appearance = require('config.appearance')
               local backdrops = appearance._backdrops_instance
               if backdrops and backdrops.enabled then
                  backdrops:cycle_forward(window)
               end
            end),
         },

         -- 退出 Leader 模式
         { key = 'Escape', action = 'PopKeyTable' },
         { key = 'phys:c', mods = 'CTRL', action = 'PopKeyTable' },
      },

      -- ======================================================================
      -- Workspace Mode
      -- ======================================================================
      workspace = {
         { key = 'phys:l', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },

         {
            key = 'phys:c',
            action = act.PromptInputLine({
               description = wezterm.format({
                  { Attribute = { Intensity = 'Bold' } },
                  { Foreground = { AnsiColor = 'Green' } },
                  { Text = 'Enter/Create Workspace:' },
               }),
               action = wezterm.action_callback(function(window, pane, line)
                  if line then
                     window:perform_action(
                        act.SwitchToWorkspace({
                           name = line,
                           spawn = { cwd = wezterm.home_dir },
                        }),
                        pane
                     )
                  end
               end),
            }),
         },

         {
            key = 'phys:r',
            action = act.PromptInputLine({
               description = wezterm.format({
                  { Attribute = { Intensity = 'Bold' } },
                  { Foreground = { AnsiColor = 'Fuchsia' } },
                  { Text = 'Rename workspace:' },
               }),
               action = wezterm.action_callback(function(window, pane, line)
                  if line then
                     window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
                  end
               end),
            }),
         },

         { key = 'phys:n', action = act.SwitchWorkspaceRelative(1) },
         { key = 'phys:p', action = act.SwitchWorkspaceRelative(-1) },

         { key = 'Escape', action = 'PopKeyTable' },
      },

      -- ======================================================================
      -- Copy Mode
      -- ======================================================================
      copy_mode = {
         -- Movement
         { key = 'phys:h', mods = 'NONE', action = act.CopyMode('MoveLeft') },
         { key = 'phys:j', mods = 'NONE', action = act.CopyMode('MoveDown') },
         { key = 'phys:k', mods = 'NONE', action = act.CopyMode('MoveUp') },
         { key = 'phys:l', mods = 'NONE', action = act.CopyMode('MoveRight') },

         -- Word movement
         { key = 'phys:w', mods = 'NONE', action = act.CopyMode('MoveForwardWord') },
         { key = 'phys:b', mods = 'NONE', action = act.CopyMode('MoveBackwardWord') },
         { key = 'phys:e', mods = 'NONE', action = act.CopyMode('MoveForwardWordEnd') },

         -- Line movement
         { key = '0', mods = 'NONE', action = act.CopyMode('MoveToStartOfLine') },
         { key = '$', mods = 'NONE', action = act.CopyMode('MoveToEndOfLineContent') },
         { key = '^', mods = 'NONE', action = act.CopyMode('MoveToStartOfLineContent') },

         -- Viewport movement
         { key = 'phys:g', mods = 'NONE', action = act.CopyMode('MoveToScrollbackTop') },
         { key = 'phys:G', mods = 'SHIFT', action = act.CopyMode('MoveToScrollbackBottom') },
         { key = 'phys:H', mods = 'SHIFT', action = act.CopyMode('MoveToViewportTop') },
         { key = 'phys:M', mods = 'SHIFT', action = act.CopyMode('MoveToViewportMiddle') },
         { key = 'phys:L', mods = 'SHIFT', action = act.CopyMode('MoveToViewportBottom') },

         -- Page movement
         { key = 'phys:b', mods = 'CTRL', action = act.CopyMode('PageUp') },
         { key = 'phys:f', mods = 'CTRL', action = act.CopyMode('PageDown') },
         { key = 'phys:d', mods = 'CTRL', action = act.CopyMode({ MoveByPage = 0.5 }) },
         { key = 'phys:u', mods = 'CTRL', action = act.CopyMode({ MoveByPage = -0.5 }) },

         -- Selection
         { key = 'phys:v', mods = 'NONE', action = act.CopyMode({ SetSelectionMode = 'Cell' }) },
         { key = 'phys:V', mods = 'SHIFT', action = act.CopyMode({ SetSelectionMode = 'Line' }) },
         { key = 'phys:v', mods = 'CTRL', action = act.CopyMode({ SetSelectionMode = 'Block' }) },

         -- Copy
         {
            key = 'phys:y',
            mods = 'NONE',
            action = act.Multiple({
               { CopyTo = 'ClipboardAndPrimarySelection' },
               { CopyMode = 'Close' },
            }),
         },
         {
            key = 'Enter',
            mods = 'NONE',
            action = act.Multiple({
               { CopyTo = 'ClipboardAndPrimarySelection' },
               { CopyMode = 'Close' },
            }),
         },

         -- Search
         { key = '/', mods = 'NONE', action = act.Search('CurrentSelectionOrEmptyString') },
         { key = 'phys:n', mods = 'NONE', action = act.CopyMode('NextMatch') },
         { key = 'phys:N', mods = 'SHIFT', action = act.CopyMode('PriorMatch') },

         -- Exit
         { key = 'phys:q', mods = 'NONE', action = act.CopyMode('Close') },
         { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
         { key = 'phys:c', mods = 'CTRL', action = act.CopyMode('Close') },
      },

      -- ======================================================================
      -- Search Mode
      -- ======================================================================
      search_mode = {
         { key = 'Enter', mods = 'NONE', action = act.CopyMode('NextMatch') },
         { key = 'phys:n', mods = 'CTRL', action = act.CopyMode('NextMatch') },
         { key = 'phys:p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },
         { key = 'phys:r', mods = 'CTRL', action = act.CopyMode('CycleMatchType') },
         { key = 'phys:u', mods = 'CTRL', action = act.CopyMode('ClearPattern') },
         { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
      },
   }
end

return M
