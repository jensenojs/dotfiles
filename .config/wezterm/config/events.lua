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
	title_width = 16,
}

local module_config = {}

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function basename(s)
	if not s then
		return ""
	end
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function trim(s)
	if not s then
		return ""
	end
	return s:match("^%s*(.-)%s*$")
end

local function pane_title(pane)
	if not pane then
		return ""
	end
	local ok, title = pcall(function()
		return pane:get_title()
	end)
	if ok and type(title) == "string" then
		return title
	end
	if type(pane.title) == "string" then
		return pane.title
	end
	local vars = nil
	if type(pane.get_user_vars) == "function" then
		local ok, value = pcall(pane.get_user_vars, pane)
		if ok and type(value) == "table" then
			vars = value
		end
	end
	if not vars and type(pane.user_vars) == "table" then
		vars = pane.user_vars
	end
	if vars and type(vars.WEZTERM_PROG) == "string" then
		return vars.WEZTERM_PROG
	end
	return ""
end

local ignored_processes = {
	[""] = true,
	zsh = true,
	bash = true,
	fish = true,
	sh = true,
	nu = true,
	pwsh = true,
	ash = true,
	busybox = true,
	login = true,
	sx = true,
}

local function first_token(text)
	local trimmed = trim(text)
	if trimmed == "" then
		return ""
	end
	local token = trimmed:match("^(%S+)") or ""
	token = token:gsub("\\", "/")
	token = token:match("([^/]+)$") or token
	token = token:gsub("^%-+", "")
	token = token:gsub("[%s%p]+$", "")
	return string.lower(token)
end

local function is_ignored_command(name)
	local token = first_token(name)
	return token == "" or ignored_processes[token] == true
end

local function pad_to_width(text, width)
	if not text or text == "" then
		return string.rep(" ", width)
	end
	local truncated
	if wezterm.truncate_left then
		truncated = wezterm.truncate_left(text, width)
	elseif #text > width then
		truncated = "…" .. text:sub(-(width - 1))
	else
		truncated = text
	end
	local current_width = wezterm.column_width and wezterm.column_width(truncated) or #truncated
	if current_width < width then
		truncated = truncated .. string.rep(" ", width - current_width)
	end
	return truncated
end

local function active_command(pane)
	if not module_config.show_process then
		return nil
	end
	local title = trim(pane_title(pane))
	if title ~= "" and not is_ignored_command(title) then
		return title
	end
	local process_raw = trim(pane.foreground_process_name or "")
	if process_raw ~= "" and not is_ignored_command(process_raw) then
		return basename(process_raw)
	end
	return nil
end

local function format_directory(pane)
	local cwd_uri = pane.current_working_dir
	if not cwd_uri then
		return "~"
	end
	local cwd = cwd_uri.file_path or tostring(cwd_uri)
	local home = wezterm.home_dir
	if home and home ~= "" then
		cwd = cwd:gsub("^" .. home, "~")
	end
	local directory = basename(cwd)
	if directory == "" then
		directory = cwd ~= "" and cwd or "~"
	end
	return directory
end

-- ============================================================================
-- Tab Title Formatting
-- ============================================================================

wezterm.on("format-tab-title", function(tab, tabs, panes, window_config, hover, max_width)
	local pane = tab.active_pane
	local label = active_command(pane)
	if not label or label == "" then
		label = format_directory(pane)
	end
	local padded = pad_to_width(label, module_config.title_width)

	local composed = ""
	if module_config.show_tab_index then
		composed = composed .. tostring(tab.tab_index + 1) .. ": "
	end
	composed = composed .. padded
	if module_config.show_unseen_indicator and pane.has_unseen_output then
		composed = composed .. " *"
	end

	return {
		{ Text = " " .. composed .. " " },
	}
end)

-- ============================================================================
-- Status Line Updates
-- ============================================================================

-- 节流机制：缓存系统信息，避免频繁调用
local last_update_time = 0
local cached_cpu_info = ""
local cached_mem_info = ""
local UPDATE_INTERVAL = 5 -- 更新间隔(秒)

wezterm.on("update-status", function(window, pane)
	-- Leader key indicator
	local leader = ""
	if window:leader_is_active() then
		leader = "🌊 LEADER "
	end

	-- Key table indicator (for nested modes like workspace)
	local key_table = window:active_key_table()
	local mode = ""
	if key_table then
		if key_table == "workspace" then
			mode = "📦 WORKSPACE "
		elseif key_table == "copy_mode" then
			mode = "📋 COPY "
		elseif key_table == "search_mode" then
			mode = "🔍 SEARCH "
		end
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
		{ Foreground = { Color = "#83a598" } }, -- Gruvbox blue
		{ Text = mode },
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
	
	-- 启动时最大化窗口(可选)
	-- 如果不需要，注释掉下面这行
	-- window:gui_window():maximize()
	
	-- 或者设置固定位置和大小(可选)
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
		module_config[k] = opts[k] ~= nil and opts[k] or v
	end

	return M
end

-- Initialize with default config on require
M.setup()

return M
