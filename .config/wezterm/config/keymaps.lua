-- Keyboard shortcuts configuration
-- Implements three-layer keybinding system:
--   Layer 0: Passthrough to shell/neovim (Ctrl+C, etc.)
--   Layer 1: System operations (MOD+key)
--   Layer 2: WezTerm-specific (Leader+key)

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config, platform)
	local mod = platform.mod -- SUPER on Mac, ALT on Linux

	-- ============================================================================
	-- Leader Key
	-- ============================================================================

	config.leader = {
		key = "Space",
		mods = mod,
		timeout_milliseconds = 2000,
	}

	-- Don't disable default keybindings - we selectively override
	config.disable_default_key_bindings = false

	-- ============================================================================
	-- Keybindings
	-- ============================================================================

	config.keys = {
		-- ========================================================================
		-- Window Management
		-- ========================================================================

		{ key = "n", mods = mod, action = act.SpawnWindow },
		{ key = "Enter", mods = mod, action = act.ToggleFullScreen },

		-- ========================================================================
		-- Copy/Paste
		-- ========================================================================

		{ key = "c", mods = mod, action = act.CopyTo("Clipboard") },
		{ key = "v", mods = mod, action = act.PasteFrom("Clipboard") },

		-- ========================================================================
		-- Search & Font
		-- ========================================================================

		{ key = "f", mods = mod, action = act.Search({ CaseSensitiveString = "" }) },
		{ key = "=", mods = mod, action = act.IncreaseFontSize },
		{ key = "-", mods = mod, action = act.DecreaseFontSize },
		{ key = "0", mods = mod, action = act.ResetFontSize },

		-- ========================================================================
		-- System Functions
		-- ========================================================================

		{ key = "r", mods = mod, action = act.ReloadConfiguration },
		{ key = "k", mods = mod, action = act.ClearScrollback("ScrollbackAndViewport") },
		{ key = "P", mods = mod .. "|SHIFT", action = act.ActivateCommandPalette },
		{ key = "L", mods = mod .. "|SHIFT", action = act.ShowDebugOverlay },
		{ key = "Space", mods = mod .. "|SHIFT", action = act.ShowLauncher },

		-- ========================================================================
		-- Scrolling
		-- ========================================================================

		{ key = "PageUp", mods = mod, action = act.ScrollByPage(-1) },
		{ key = "PageDown", mods = mod, action = act.ScrollByPage(1) },

		-- ========================================================================
		-- Tab Management
		-- ========================================================================

		{ key = "t", mods = mod, action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "w", mods = mod, action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "[", mods = mod, action = act.ActivateTabRelative(-1) },
		{ key = "]", mods = mod, action = act.ActivateTabRelative(1) },
		{ key = "LeftArrow", mods = mod .. "|SHIFT", action = act.ActivateTabRelative(-1) },
		{ key = "RightArrow", mods = mod .. "|SHIFT", action = act.ActivateTabRelative(1) },
		{ key = "LeftArrow", mods = mod .. "|SHIFT|CTRL", action = act.MoveTabRelative(-1) },
		{ key = "RightArrow", mods = mod .. "|SHIFT|CTRL", action = act.MoveTabRelative(1) },

		-- ========================================================================
		-- Pane Splitting (MOD shortcuts for quick access)
		-- ========================================================================

		{ key = "d", mods = mod, action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "D", mods = mod .. "|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "W", mods = mod .. "|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

		-- ========================================================================
		-- Pane Management (Leader key)
		-- ========================================================================

		-- Split
		{ key = "|", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
		{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

		-- Navigate (Vim-style)
		{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

		-- Navigate (Arrow keys)
		{ key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
		{ key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
		{ key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
		{ key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

		-- Resize
		{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

		-- Operations
		{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
		{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
		{ key = "o", mods = "LEADER", action = act.RotatePanes("Clockwise") },
		{ key = "O", mods = "LEADER|SHIFT", action = act.RotatePanes("CounterClockwise") },
		{ key = "Space", mods = "LEADER", action = act.PaneSelect },
		{ key = "s", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActive" }) },

		-- Copy Mode & Quick Select
		{ key = "[", mods = "LEADER", action = act.ActivateCopyMode },
		{ key = "f", mods = "LEADER", action = act.QuickSelect },

		-- ========================================================================
		-- Workspace Management (Leader key)
		-- ========================================================================

		{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{ key = "n", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
		{ key = "p", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },

		-- Rename workspace
		{
			key = ",",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
					end
				end),
			}),
		},

		-- Create workspace
		{
			key = "c",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Green" } },
					{ Text = "Create new workspace" },
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

		-- ========================================================================
		-- Background Images (Optional - Default: Disabled)
		-- ========================================================================
		
		-- NOTE: 背景功能默认关闭，需在 config/appearance.lua 中启用
		
		-- Cycle background forward (Leader + b)
		{
			key = "b",
			mods = "LEADER",
			action = wezterm.action_callback(function(window, _)
				local appearance = require("config.appearance")
				local backdrops = appearance._backdrops_instance
				if backdrops and backdrops.enabled then
					backdrops:cycle_forward(window)
				end
			end),
		},

		-- Cycle background backward (Leader + Shift + b)
		{
			key = "B",
			mods = "LEADER|SHIFT",
			action = wezterm.action_callback(function(window, _)
				local appearance = require("config.appearance")
				local backdrops = appearance._backdrops_instance
				if backdrops and backdrops.enabled then
					backdrops:cycle_back(window)
				end
			end),
		},

		-- Random background (Leader + Ctrl + b)
		{
			key = "b",
			mods = "LEADER|CTRL",
			action = wezterm.action_callback(function(window, _)
				local appearance = require("config.appearance")
				local backdrops = appearance._backdrops_instance
				if backdrops and backdrops.enabled then
					backdrops:random(window)
				end
			end),
		},
	}

	-- Add numbered tab switching (MOD+1 through MOD+9)
	for i = 1, 9 do
		table.insert(config.keys, {
			key = tostring(i),
			mods = mod,
			action = act.ActivateTab(i - 1),
		})
	end

	-- MOD+0 activates last tab
	table.insert(config.keys, {
		key = "0",
		mods = mod,
		action = act.ActivateTab(-1),
	})

	-- ============================================================================
	-- Key Tables (Modal Operations)
	-- ============================================================================

	config.key_tables = {
		-- Copy Mode (Vim-style)
		copy_mode = {
			-- Movement
			{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },

			-- Arrow keys
			{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
			{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
			{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
			{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },

			-- Word movement
			{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
			{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
			{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },

			-- Line movement
			{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
			{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
			{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },

			-- Viewport movement
			{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
			{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
			{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
			{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
			{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },

			-- Page movement
			{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
			{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
			{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
			{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
			{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
			{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },

			-- Selection
			{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
			{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
			{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },

			-- Copy
			{
				key = "y",
				mods = "NONE",
				action = act.Multiple({
					{ CopyTo = "ClipboardAndPrimarySelection" },
					{ CopyMode = "Close" },
				}),
			},
			{
				key = "Enter",
				mods = "NONE",
				action = act.Multiple({
					{ CopyTo = "ClipboardAndPrimarySelection" },
					{ CopyMode = "Close" },
				}),
			},

			-- Search
			{ key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
			{ key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
			{ key = "N", mods = "SHIFT", action = act.CopyMode("PriorMatch") },

			-- Exit
			{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
			{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
			{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },
		},

		-- Search Mode
		search_mode = {
			{ key = "Enter", mods = "NONE", action = act.CopyMode("NextMatch") },
			{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
			{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
			{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
			{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
			{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		},
	}
end

return M
