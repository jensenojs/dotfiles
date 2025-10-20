-- Keyboard shortcuts configuration
-- Implements three-layer keybinding system:
--   Layer 0: Passthrough to shell/neovim (Ctrl+C, etc.)
--   Layer 1: System operations (MOD+key)
--   Layer 2: WezTerm-specific (Leader+key)

local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply(config, platform)
   local mod = platform.mod -- SUPER on Mac, ALT on Linux

   -- ============================================================================
   -- Leader Key
   -- ============================================================================

   -- disable default keybindings
   -- https://wezterm.org/config/default-keys.html
   config.disable_default_key_bindings = true

   -- 告诉 WezTerm 监听物理按键 "Comma"，这会绕过输入法的字符转换。
   -- https://wezterm.org/config/keys.html#physical-vs-mapped-key-assignments
   config.leader = {
      key = 'phys:Comma',
      mods = 'CTRL',
      timeout_milliseconds = 2000,
   }

   -- ============================================================================
   -- Keybindings
   -- ============================================================================

   config.keys = {
      -- ========================================================================
      -- Window Management
      -- ========================================================================

      { key = 'phys:n', mods = mod, action = act.SpawnWindow },
      { key = 'Enter', mods = mod, action = act.ToggleFullScreen },

      -- ========================================================================
      -- Copy/Paste
      -- ========================================================================

      { key = 'phys:c', mods = mod, action = act.CopyTo('Clipboard') },
      { key = 'phys:v', mods = mod, action = act.PasteFrom('Clipboard') },

      -- ========================================================================
      -- Search & Font
      -- ========================================================================

      { key = 'phys:f', mods = mod, action = act.Search({ CaseSensitiveString = '' }) },
      { key = '=', mods = mod, action = act.IncreaseFontSize },
      { key = '-', mods = mod, action = act.DecreaseFontSize },
      -- ResetFontSize 移除，避免与 ActivateTab(-1) 冲突
      -- 可以通过重载配置 (MOD+r) 恢复默认字体
      
      -- ========================================================================
      -- System Functions
      -- ========================================================================

      { key = 'phys:r', mods = mod, action = act.ReloadConfiguration },
      -- All command palette, debug overlay, and launcher moved to Leader key

      -- ========================================================================
      -- Scrolling
      -- ========================================================================

      { key = 'phys:PageUp', mods = mod, action = act.ScrollByPage(-1) },
      { key = 'phys:PageDown', mods = mod, action = act.ScrollByPage(1) },

      -- ========================================================================
      -- Tab Management
      -- ========================================================================

      { key = 'phys:t', mods = mod, action = act.SpawnTab('CurrentPaneDomain') },
      { key = 'phys:w', mods = mod, action = act.CloseCurrentTab({ confirm = true }) },
      { key = '[', mods = mod, action = act.ActivateTabRelative(-1) },
      { key = ']', mods = mod, action = act.ActivateTabRelative(1) },
      { key = 'LeftArrow', mods = mod .. '|SHIFT', action = act.ActivateTabRelative(-1) },
      { key = 'RightArrow', mods = mod .. '|SHIFT', action = act.ActivateTabRelative(1) },
      { key = 'LeftArrow', mods = mod .. '|SHIFT|CTRL', action = act.MoveTabRelative(-1) },
      { key = 'RightArrow', mods = mod .. '|SHIFT|CTRL', action = act.MoveTabRelative(1) },

      -- No more MOD+d shortcuts to prevent accidental triggering

      -- ========================================================================
      -- Pane Management (Leader key)
      -- ========================================================================

      -- Split
      { key = 'phys:h', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
      {
         key = 'phys:v',
         mods = 'LEADER',
         action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
      },

      -- Operations
      { key = 'phys:x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },
      { key = 'phys:z', mods = 'LEADER', action = act.TogglePaneZoomState },
      { key = 'phys:n', mods = 'LEADER', action = act.ActivatePaneDirection('Next') },
      { key = 'phys:s', mods = 'LEADER', action = act.PaneSelect({ mode = 'SwapWithActive' }) },

      -- Copy Mode & Quick Select
      { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
      { key = 'phys:f', mods = 'LEADER', action = act.QuickSelect },

      -- ========================================================================
      -- Workspace Management (Leader key)
      -- 使用 W (SHIFT+w) 系列快捷键统一管理
      -- ========================================================================

      -- Workspace 列表
      { key = 'phys:W', mods = 'LEADER|SHIFT', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
      
      -- 创建新 Workspace
      {
         key = 'phys:C',
         mods = 'LEADER|SHIFT',
         action = act.PromptInputLine({
            description = wezterm.format({
               { Attribute = { Intensity = 'Bold' } },
               { Foreground = { AnsiColor = 'Green' } },
               { Text = 'Create new workspace' },
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

      -- 重命名当前 Workspace
      {
         key = 'phys:R',
         mods = 'LEADER|SHIFT',
         action = act.PromptInputLine({
            description = wezterm.format({
               { Attribute = { Intensity = 'Bold' } },
               { Foreground = { AnsiColor = 'Fuchsia' } },
               { Text = 'Rename current workspace' },
            }),
            action = wezterm.action_callback(function(window, pane, line)
               if line then
                  window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
               end
            end),
         }),
      },

      -- 切换到下一个 Workspace
      { key = 'phys:N', mods = 'LEADER|SHIFT', action = act.SwitchWorkspaceRelative(1) },
      
      -- 切换到上一个 Workspace
      { key = 'phys:P', mods = 'LEADER|SHIFT', action = act.SwitchWorkspaceRelative(-1) },

      -- ========================================================================
      -- System Functions (Leader key)
      -- ========================================================================

      -- Activate command palette
      { key = 'phys:p', mods = 'LEADER', action = act.ActivateCommandPalette },
      -- Show debug overlay
      -- { key = 'l', mods = 'LEADER', action = act.ShowDebugOverlay },
      -- Show launcher
      { key = 'phys:Space', mods = 'LEADER', action = act.ShowLauncher },

      -- ========================================================================
      -- Background Images (Optional - Default: Disabled)
      -- ========================================================================

      -- NOTE: 背景功能默认关闭，需在 config/appearance.lua 中启用

      -- Cycle background forward (Leader + b)
      {
         key = 'phys:b',
         mods = 'LEADER',
         action = wezterm.action_callback(function(window, _)
            local appearance = require('config.appearance')
            local backdrops = appearance._backdrops_instance
            if backdrops and backdrops.enabled then
               backdrops:cycle_forward(window)
            end
         end),
      },

      -- Cycle background backward (Leader + Shift + b)
      {
         key = 'phys:B',
         mods = 'LEADER|SHIFT',
         action = wezterm.action_callback(function(window, _)
            local appearance = require('config.appearance')
            local backdrops = appearance._backdrops_instance
            if backdrops and backdrops.enabled then
               backdrops:cycle_back(window)
            end
         end),
      },

      -- Random background (Leader + Ctrl + b)
      {
         key = 'phys:b',
         mods = 'LEADER|CTRL',
         action = wezterm.action_callback(function(window, _)
            local appearance = require('config.appearance')
            local backdrops = appearance._backdrops_instance
            if backdrops and backdrops.enabled then
               backdrops:random(window)
            end
         end),
      },

      -- ========================================================================
      -- Numbered Tab Switching
      -- ========================================================================

      -- MOD+1 through MOD+9
      { key = '1', mods = mod, action = act.ActivateTab(0) },
      { key = '2', mods = mod, action = act.ActivateTab(1) },
      { key = '3', mods = mod, action = act.ActivateTab(2) },
      { key = '4', mods = mod, action = act.ActivateTab(3) },
      { key = '5', mods = mod, action = act.ActivateTab(4) },
      { key = '6', mods = mod, action = act.ActivateTab(5) },
      { key = '7', mods = mod, action = act.ActivateTab(6) },
      { key = '8', mods = mod, action = act.ActivateTab(7) },
      { key = '9', mods = mod, action = act.ActivateTab(8) },
      -- MOD+0 activates last tab
      { key = '0', mods = mod, action = act.ActivateTab(-1) },
   }

   -- ============================================================================
   -- Key Tables (Modal Operations)
   -- ============================================================================

   config.key_tables = {
      -- Copy Mode (Vim-style)
      copy_mode = {
         -- Movement
         { key = 'phys:h', mods = 'NONE', action = act.CopyMode('MoveLeft') },
         { key = 'phys:j', mods = 'NONE', action = act.CopyMode('MoveDown') },
         { key = 'phys:k', mods = 'NONE', action = act.CopyMode('MoveUp') },
         { key = 'phys:l', mods = 'NONE', action = act.CopyMode('MoveRight') },

         -- Arrow keys
         { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode('MoveLeft') },
         { key = 'DownArrow', mods = 'NONE', action = act.CopyMode('MoveDown') },
         { key = 'UpArrow', mods = 'NONE', action = act.CopyMode('MoveUp') },
         { key = 'RightArrow', mods = 'NONE', action = act.CopyMode('MoveRight') },

         -- Word movement
         { key = 'phys:w', mods = 'NONE', action = act.CopyMode('MoveForwardWord') },
         { key = 'phys:b', mods = 'NONE', action = act.CopyMode('MoveBackwardWord') },
         { key = 'phys:e', mods = 'NONE', action = act.CopyMode('MoveForwardWordEnd') },

         -- Line movement
         { key = '0', mods = 'NONE', action = act.CopyMode('MoveToStartOfLine') },
         { key = '$', mods = 'NONE', action = act.CopyMode('MoveToEndOfLineContent') },
         { key = '^', mods = 'NONE', action = act.CopyMode('MoveToStartOfLineContent') },

         -- Viewport movement
         { key = 'g', mods = 'NONE', action = act.CopyMode('MoveToScrollbackTop') },
         { key = 'G', mods = 'NONE', action = act.CopyMode('MoveToScrollbackBottom') },
         { key = 'H', mods = 'NONE', action = act.CopyMode('MoveToViewportTop') },
         { key = 'L', mods = 'NONE', action = act.CopyMode('MoveToViewportBottom') },
         { key = 'M', mods = 'NONE', action = act.CopyMode('MoveToViewportMiddle') },

         -- Page movement
         { key = 'PageUp', mods = 'NONE', action = act.CopyMode('PageUp') },
         { key = 'PageDown', mods = 'NONE', action = act.CopyMode('PageDown') },
         { key = 'phys:b', mods = 'CTRL', action = act.CopyMode('PageUp') },
         { key = 'phys:f', mods = 'CTRL', action = act.CopyMode('PageDown') },
         { key = 'phys:d', mods = 'CTRL', action = act.CopyMode({ MoveByPage = 0.5 }) },
         { key = 'phys:u', mods = 'CTRL', action = act.CopyMode({ MoveByPage = -0.5 }) },

         -- Selection
         { key = 'phys:v', mods = 'NONE', action = act.CopyMode({ SetSelectionMode = 'Cell' }) },
         { key = 'phys:V', mods = 'NONE', action = act.CopyMode({ SetSelectionMode = 'Line' }) },
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

      -- Search Mode
      -- search_mode = {
      --    { key = 'Enter', mods = 'NONE', action = act.CopyMode('NextMatch') },
      --    { key = 'phys:n', mods = 'CTRL', action = act.CopyMode('NextMatch') },
      --    { key = 'phys:p', mods = 'CTRL', action = act.CopyMode('PriorMatch') },
      --    { key = 'phys:r', mods = 'CTRL', action = act.CopyMode('CycleMatchType') },
      --    { key = 'phys:u', mods = 'CTRL', action = act.CopyMode('ClearPattern') },
      --    { key = 'Escape', mods = 'NONE', action = act.CopyMode('Close') },
      -- },
   }

end

return M
