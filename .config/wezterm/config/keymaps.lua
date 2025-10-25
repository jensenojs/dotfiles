-- ============================================================================
-- WezTerm Keybindings Configuration
-- ============================================================================
-- Architecture:
--   - MOD Layer: 最小化的系统操作，避免与 Nvim 冲突
--   - LEADER Layer (Ctrl+,): WezTerm 专属命名空间
--     - Workspace Sub-mode: 嵌套模态
-- ============================================================================

local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply(config, platform)
   local mod = platform.mod -- SUPER on Mac, ALT on Linux

   -- =========================================================================
   -- Disable default keybindings
   -- =========================================================================
   config.disable_default_key_bindings = true

   -- =========================================================================
   -- Leader Key (Ctrl+,)
   -- =========================================================================
   config.leader = {
      key = 'phys:Comma',
      mods = 'CTRL',
      timeout_milliseconds = 2000,
   }

   -- =========================================================================
   -- Main Keybindings
   -- =========================================================================
   config.keys = {
      -- ======================================================================
      -- MOD Layer: 最小化的系统操作
      -- ======================================================================
      
      -- System
      -- { key = 'phys:p', mods = 'LEADER', action = act.ActivateCommandPalette },
      { key = 'phys:Space', mods = 'LEADER', action = act.ShowLauncher },
      { key = 'phys:f', mods = 'LEADER', action = act.QuickSelect },

      -- Copy/Paste
      { key = 'phys:c', mods = mod, action = act.CopyTo('Clipboard') },
      { key = 'phys:v', mods = mod, action = act.PasteFrom('Clipboard') },

      -- Font
      { key = '=', mods = mod, action = act.IncreaseFontSize },
      { key = '-', mods = mod, action = act.DecreaseFontSize },

      -- Reload
      { key = 'phys:r', mods = mod, action = act.ReloadConfiguration },

      -- Tab navigation
      { key = '[', mods = mod, action = act.ActivateTabRelative(-1) },
      { key = ']', mods = mod, action = act.ActivateTabRelative(1) },
      { key = '[', mods = mod .. '|SHIFT', action = act.MoveTabRelative(-1) },
      { key = ']', mods = mod .. '|SHIFT', action = act.MoveTabRelative(1) },

      -- 对齐 macos 使用习惯
      { key = 'phys:t', mods = mod, action = act.SpawnTab('CurrentPaneDomain') },
      { key = 'phys:w', mods = mod, action = act.CloseCurrentPane({ confirm = true }) },

      -- Quick tab switching
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

      -- ======================================================================
      -- LEADER Layer (Ctrl+,): WezTerm 命名空间
      -- ======================================================================

      -- Window & Tab
      { key = 'phys:c', mods = 'LEADER', action = act.SpawnTab('CurrentPaneDomain') },
      { key = 'phys:c', mods = 'LEADER|SHIFT', action = act.SpawnWindow },
      { key = 'phys:n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
      { key = 'phys:p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
      { key = 'phys:x', mods = 'LEADER', action = act.CloseCurrentPane({ confirm = true }) },
      { key = 'Enter', mods = 'LEADER', action = act.ToggleFullScreen },

      -- Pane split
      { key = 'phys:h', mods = 'LEADER', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
      { key = 'phys:v', mods = 'LEADER', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },

      -- Pane operations
      { key = 'phys:z', mods = 'LEADER', action = act.TogglePaneZoomState },
      { key = 'phys:o', mods = 'LEADER', action = act.ActivatePaneDirection('Next') },
      { key = 'phys:s', mods = 'LEADER', action = act.PaneSelect({ mode = 'SwapWithActive' }) },

      -- Copy Mode & Quick Select
      { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

      -- ======================================================================
      -- Workspace Sub-mode Activation (LEADER + w)
      -- ======================================================================
      {
         key = 'phys:w',
         mods = 'LEADER',
         action = act.ActivateKeyTable({
            name = 'workspace',
            timeout_milliseconds = 2000, -- 延长超时
            one_shot = false,
         }),
      },
   }

   -- =========================================================================
   -- Key Tables (Modal Operations)
   -- =========================================================================
   config.key_tables = {
      -- ======================================================================
      -- Workspace Mode
      -- ======================================================================
      workspace = {
         -- List workspaces
         { key = 'phys:l', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },

         -- Create/switch workspace
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

         -- Rename workspace
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

         -- Navigate workspaces
         { key = 'phys:n', action = act.SwitchWorkspaceRelative(1) },
         { key = 'phys:p', action = act.SwitchWorkspaceRelative(-1) },

         -- Exit workspace mode
         { key = 'Escape', action = 'PopKeyTable' },
      },

      -- ======================================================================
      -- Copy Mode (Vim-style)
      -- ======================================================================
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
         { key = 'phys:g', mods = 'NONE', action = act.CopyMode('MoveToScrollbackTop') },
         { key = 'phys:G', mods = 'SHIFT', action = act.CopyMode('MoveToScrollbackBottom') },
         { key = 'phys:H', mods = 'SHIFT', action = act.CopyMode('MoveToViewportTop') },
         { key = 'phys:M', mods = 'SHIFT', action = act.CopyMode('MoveToViewportMiddle') },
         { key = 'phys:L', mods = 'SHIFT', action = act.CopyMode('MoveToViewportBottom') },

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
   }
end

return M