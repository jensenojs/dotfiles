-- Event handlers module
-- Handles tab title formatting, status line updates, and GUI startup
-- Supports setup() configuration for customization

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- Default configuration
local default_config = {
	show_seconds = false,
	date_format = "%H:%M",
	show_tab_index = true,
	show_process = true,
	show_unseen_indicator = true,
	enable_command_palette = true,
}

local config = {}

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function basename(s)
	if not s then
		return ""
	end
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

-- ============================================================================
-- Tab Title Formatting
-- ============================================================================

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local title = tab.tab_index + 1 .. ": "

	-- Get current working directory
	local cwd = tab.active_pane.current_working_dir
	if cwd then
		cwd = cwd.file_path or tostring(cwd)
		-- Replace HOME with ~
		local home = wezterm.home_dir
		cwd = cwd:gsub("^" .. home, "~")
		-- Only show the last directory
		title = title .. basename(cwd)
	else
		title = title .. "zsh"
	end

	-- Process name (if not a shell)
	local process = basename(tab.active_pane.foreground_process_name or "")
	if process ~= "zsh" and process ~= "bash" and process ~= "" then
		title = title .. " [" .. process .. "]"
	end

	-- Unseen output indicator
	if tab.active_pane.has_unseen_output then
		title = title .. " *"
	end

	return {
		{ Text = " " .. title .. " " },
	}
end)

-- ============================================================================
-- Status Line Updates
-- ============================================================================

-- 节流机制：缓存系统信息，避免频繁调用
local last_update_time = 0
local cached_cpu_info = ""
local cached_mem_info = ""
local UPDATE_INTERVAL = 5 -- 更新间隔（秒）

wezterm.on("update-status", function(window, pane)
	-- Leader key indicator
	local leader = ""
	if window:leader_is_active() then
		leader = "🌊 LEADER "
	end

	-- Current workspace
	local workspace = window:active_workspace()
	local workspace_text = ""
	if workspace ~= "default" then
		workspace_text = "  📁 " .. workspace
	end

	-- Set left status
	window:set_left_status(wezterm.format({
		{ Foreground = { Color = "#d79921" } }, -- Gruvbox yellow
		{ Text = leader },
		{ Foreground = { Color = "#98971a" } }, -- Gruvbox green
		{ Text = workspace_text },
	}))

	-- Set right status (CPU + Memory with throttling)
	-- NOTE: Starship 主题已包含时间显示，所以这里不显示时间
	
	-- 获取当前时间戳
	local current_time = os.time()
	
	-- 只有超过更新间隔才重新获取系统信息
	if current_time - last_update_time >= UPDATE_INTERVAL then
		last_update_time = current_time
		
		-- 获取 CPU 使用率
		local success, cpu_output = pcall(function()
			local handle = io.popen("top -l 1 | grep 'CPU usage' | awk '{print $3}' | sed 's/%//'")
			if handle then
				local result = handle:read("*a")
				handle:close()
				return result:gsub("%s+", "")
			end
			return ""
		end)
		if success and cpu_output and cpu_output ~= "" then
			cached_cpu_info = " CPU:" .. cpu_output .. "%"
		end
		
		-- 获取内存使用率
		local success_mem, mem_output = pcall(function()
			local handle = io.popen("vm_stat | awk '/Pages active/ {active=$3} /Pages wired/ {wired=$4} /Pages free/ {free=$3} END {print int((active+wired)/(active+wired+free)*100)}'")
			if handle then
				local result = handle:read("*a")
				handle:close()
				return result:gsub("%s+", "")
			end
			return ""
		end)
		if success_mem and mem_output and mem_output ~= "" then
			cached_mem_info = " MEM:" .. mem_output .. "%"
		end
	end
	
	-- 使用缓存的信息更新状态栏
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#b8bb26" } }, -- Gruvbox bright green
		{ Text = cached_cpu_info },
		{ Foreground = { Color = "#83a598" } }, -- Gruvbox bright blue
		{ Text = cached_mem_info },
	}))
end)

-- ============================================================================
-- Command Palette Augmentation
-- ============================================================================

wezterm.on("augment-command-palette", function(window, pane)
	return {
		{
			brief = "📁 Pick Workspace",
			icon = "md_briefcase",
			action = act.ShowLauncherArgs({
				flags = "FUZZY|WORKSPACES",
			}),
		},
		{
			brief = "🔄 Reload Configuration",
			icon = "md_refresh",
			action = act.ReloadConfiguration,
		},
		{
			brief = "👁️  Toggle Tab Bar",
			icon = "md_tab",
			action = wezterm.action_callback(function(win, _)
				local overrides = win:get_config_overrides() or {}
				if overrides.enable_tab_bar == false then
					overrides.enable_tab_bar = true
				else
					overrides.enable_tab_bar = false
				end
				win:set_config_overrides(overrides)
			end),
		},
		{
			brief = "🖼️  Toggle Opacity",
			icon = "md_opacity",
			action = wezterm.action_callback(function(win, _)
				local overrides = win:get_config_overrides() or {}
				if overrides.window_background_opacity == 1.0 then
					overrides.window_background_opacity = 0.95
				else
					overrides.window_background_opacity = 1.0
				end
				win:set_config_overrides(overrides)
			end),
		},
		{
			brief = "⬆️  Maximize Window",
			icon = "md_window_maximize",
			action = wezterm.action_callback(function(win, _)
				win:maximize()
			end),
		},
		{
			brief = "📋 Copy Mode",
			icon = "md_content_copy",
			action = act.ActivateCopyMode,
		},
	}
end)

-- ============================================================================
-- GUI Startup
-- ============================================================================

wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	
	-- 启动时最大化窗口（可选）
	-- 如果不需要，注释掉下面这行
	-- window:gui_window():maximize()
	
	-- 或者设置固定位置和大小（可选）
	-- window:gui_window():set_position(100, 100)
end)

-- ============================================================================
-- Setup Function
-- ============================================================================

--- Setup event handlers with custom configuration
--- @param opts table|nil Optional configuration overrides
--- @return table Module reference for chaining
function M.setup(opts)
	opts = opts or {}
	
	-- Merge with defaults
	for k, v in pairs(default_config) do
		config[k] = opts[k] ~= nil and opts[k] or v
	end
	
	return M
end

-- Initialize with default config on require
M.setup()

return M
