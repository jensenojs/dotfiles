-- Event handlers module
-- Handles tab title formatting, status line updates, and GUI startup
-- Supports setup() configuration for customization
local wezterm = require("wezterm")
local act = wezterm.action
local platform = require("config.platform")

-- ============================================================================
-- Configuration Constants
-- ============================================================================

local METRICS_DEBUG = false
local UPDATE_INTERVAL = 10 -- 采集间隔(秒)
local MAX_CONSECUTIVE_ERRORS = 3 -- 最大连续错误次数
local ERROR_BACKOFF_TIME = 30 -- 错误退避时间(秒)
local DEFAULT_TITLE_WIDTH = 16 -- tab 标题宽度

local M = {}

-- ============================================================================
-- Helper Functions
-- ============================================================================

local function log_debug(...)
    if METRICS_DEBUG then
        wezterm.log_info("[metrics]", ...)
    end
end

-- ============================================================================
-- Module Configuration
-- ============================================================================

local default_config = {
    show_seconds = false,
    date_format = "%H:%M",
    show_tab_index = true,
    show_process = true,
    show_unseen_indicator = true,
    enable_command_palette = true,
    title_width = DEFAULT_TITLE_WIDTH
}

local module_config = {}

-- ============================================================================
-- Utility Functions
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
    sx = true
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

    return {{
        Text = " " .. composed .. " "
    }}
end)

-- ============================================================================
-- Status Line Updates（异步指标采集）
-- ============================================================================

-- 缓存上一次采样得到的字符串，update-status 只读取缓存，完全避免阻塞 GUI。
local metrics_cache = {
    cpu = " CPU:--",
    mem = " MEM:--",
    disk = " DISK:--",
    net = " NET:--/--"
}

-- ============================================================================
-- Metrics Collection State
-- ============================================================================

-- 采样控制状态
local metrics_inflight = false -- 是否有采样任务正在执行
local last_metrics_time = 0 -- 上次启动采样的时间戳
local consecutive_errors = 0 -- 连续失败次数

-- 网络速率计算状态
local last_sample_time = nil -- 上次成功采样的时间
local prev_net_rx = nil -- 上次累计下行字节数
local prev_net_tx = nil -- 上次累计上行字节数

local function now_seconds()
    return wezterm.time_now and wezterm.time_now() or os.time()
end

local function format_rate(bytes_per_sec)
    if not bytes_per_sec or bytes_per_sec < 0 then
        return "--"
    end

    local KB = 1024
    local MB = KB * 1024

    if bytes_per_sec >= MB then
        return string.format("%.1fMB/s", bytes_per_sec / MB)
    elseif bytes_per_sec >= KB then
        return string.format("%.0fKB/s", bytes_per_sec / KB)
    else
        return string.format("%dB/s", math.floor(bytes_per_sec + 0.5))
    end
end

-- ============================================================================
-- Platform-Specific Metrics Scripts
-- ============================================================================

-- 使用独立脚本文件的优势:
-- 1. 减少 fork 开销(一次性加载,不需要每次解析)
-- 2. 更容易维护和测试
-- 3. 可以独立运行调试
-- 4. Linux 使用 /proc/stat 读取 CPU,避免 top 命令开销

local function get_script_path()
    local config_dir = wezterm.config_dir or (wezterm.home_dir .. "/.config/wezterm")
    return config_dir .. "/scripts"
end

local METRIC_SCRIPTS = {
    mac = get_script_path() .. "/metrics-macos.sh",
    linux = get_script_path() .. "/metrics-linux.sh"
}

-- 旧的内联脚本(保留作为降级方案)
local METRIC_SCRIPTS_INLINE = {
    mac = [[
cpu=$(LC_ALL=C top -l 1 -n 0 2>/dev/null | awk -F'[,%]' '/CPU usage/ {u=$2; s=$4; gsub(/[^0-9.]/,"",u); gsub(/[^0-9.]/,"",s); printf "%d\n", (u + s + 0.5); exit}')
if [ -z "$cpu" ]; then
	cpu=$(ps -A -o %cpu 2>/dev/null | awk 'NR>1 {sum+=$1} END {printf "%d\n", sum}')
fi
mem=$(memory_pressure 2>/dev/null | awk '/System-wide memory free percentage:/ {gsub(/%/,"",$5); printf "%d\n", 100 - $5; exit}')
if [ -z "$mem" ]; then
	mem=$(vm_stat 2>/dev/null | awk '
		/Pages active/ {gsub(/[^0-9]/,"",$3); active=$3}
		/Pages wired/ {gsub(/[^0-9]/,"",$3); wired=$3}
		/Pages speculative/ {gsub(/[^0-9]/,"",$3); speculative=$3}
		/Pages free/ {gsub(/[^0-9]/,"",$3); free=$3}
		END {
			used = active + wired
			total = active + wired + speculative + free
			if (total > 0) printf "%d\n", (used / total) * 100
		}')
fi
if [ -z "$mem" ]; then mem=0; fi
disk=$(df -P . 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
if [ -z "$disk" ]; then
	disk=0
fi
read rx tx <<EOF
$(netstat -ib 2>/dev/null | awk 'NR>1 && $1 !~ /^lo/ && $1 !~ /^utun/ {rx+=$7; tx+=$10} END {if(rx=="") rx=0; if(tx=="") tx=0; printf "%.0f %.0f\n", rx, tx}')
EOF
printf "CPU=%s MEM=%s DISK=%s RX=%s TX=%s\n" "${cpu:-0}" "${mem:-0}" "${disk:-0}" "${rx:-0}" "${tx:-0}"
]],
    linux = [[
cpu=$(LANG=C top -bn1 2>/dev/null | awk -F',' '/Cpu\(s\)/ {for (i = 1; i <= NF; i++) {if ($i ~ /id/) {gsub(/[^0-9.]/,"",$i); printf "%d\n", (100 - $i + 0.5); exit}}}')
if [ -z "$cpu" ]; then
	cpu=0
fi
mem=$(awk '
	/^MemTotal:/ {total=$2}
	/^MemAvailable:/ {avail=$2}
	END {
		if (total>0 && avail>0) {
			printf "%d\n", ((total-avail)/total)*100
		}
	}' /proc/meminfo 2>/dev/null)
if [ -z "$mem" ]; then
	mem=0
fi
disk=$(df -P . 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
if [ -z "$disk" ]; then
	disk=0
fi
read rx tx <<EOF
$(awk 'NR>2 {sub(/:/,"",$1); if ($1!="lo") {rx+=$2; tx+=$10}} END {if(rx=="") rx=0; if(tx=="") tx=0; printf "%.0f %.0f\n", rx, tx}' /proc/net/dev 2>/dev/null)
EOF
	printf "CPU=%s MEM=%s DISK=%s RX=%s TX=%s\n" "${cpu:-0}" "${mem:-0}" "${disk:-0}" "${rx:-0}" "${tx:-0}"
]]
}

-- 根据当前平台选择相应的脚本
local function get_metrics_script()
    local script_path
    if platform.is_mac then
        script_path = METRIC_SCRIPTS.mac
    elseif platform.is_linux then
        script_path = METRIC_SCRIPTS.linux
    else
        return nil
    end

    -- 检查脚本文件是否存在
    local f = io.open(script_path, "r")
    if f then
        f:close()
        return script_path
    else
        -- 降级到内联脚本
        wezterm.log_warn("Metrics script not found: " .. script_path .. ", using inline script")
        if platform.is_mac then
            return METRIC_SCRIPTS_INLINE.mac
        elseif platform.is_linux then
            return METRIC_SCRIPTS_INLINE.linux
        end
    end
    return nil
end

-- 解析 "CPU=xx MEM=yy ..." 格式的输出
local function parse_metrics(output)
    if not output or output == "" then
        return nil
    end
    local data = {}
    for key, value in output:gmatch("(%u+)=([%d%.]+)") do
        data[key] = tonumber(value)
    end
    if next(data) == nil then
        return nil
    end
    return data
end

-- 更新指标缓存(包含网络速率计算)
local function update_metrics_cache(data, sample_time)
    if data.CPU then
        metrics_cache.cpu = string.format(" CPU:%d%%", data.CPU)
    end
    if data.MEM then
        metrics_cache.mem = string.format(" MEM:%d%%", data.MEM)
    end
    if data.DISK then
        metrics_cache.disk = string.format(" DISK:%d%%", data.DISK)
    end

    if data.RX and data.TX then
        if prev_net_rx and prev_net_tx and last_sample_time and sample_time > last_sample_time then
            local dt = sample_time - last_sample_time
            if dt > 0 then
                local down = (data.RX - prev_net_rx) / dt
                local up = (data.TX - prev_net_tx) / dt
                if down and down >= 0 and up and up >= 0 then
                    metrics_cache.net = string.format(" NET:%s↓ %s↑", format_rate(down), format_rate(up))
                end
            end
        end
        prev_net_rx = data.RX
        prev_net_tx = data.TX
        last_sample_time = sample_time
    end
end

-- 共用的结果处理函数，方便同时支持异步/同步两种调用。
local function handle_metrics_result(success, stdout, stderr, sample_time)
    metrics_inflight = false
    -- log_debug("collect done", success, stdout, stderr)

    if not success then
        consecutive_errors = math.min(MAX_CONSECUTIVE_ERRORS, consecutive_errors + 1)
        if stderr and stderr ~= "" then
            wezterm.log_warn("metrics script failed: " .. stderr)
        end
        return
    end

    local cleaned = stdout and stdout:gsub("%s+$", "") or nil
    local data = parse_metrics(cleaned)
    if not data then
        consecutive_errors = math.min(MAX_CONSECUTIVE_ERRORS, consecutive_errors + 1)
        if cleaned and cleaned ~= "" then
            wezterm.log_warn("metrics parse failed: " .. cleaned)
        end
        return
    end

    consecutive_errors = 0
    update_metrics_cache(data, sample_time)
end

-- 启动一次新的指标采集。使用定时器异步化执行，避免阻塞GUI。
local function start_metrics_refresh()
    if metrics_inflight then
        return
    end
    local script = get_metrics_script()
    if not script then
        return
    end

    metrics_inflight = true
    last_metrics_time = now_seconds()
    -- log_debug("start metrics collection (async)")

    -- 使用定时器异步执行，避免阻塞主线程
    wezterm.time.call_after(0, function()
        -- 判断是脚本文件还是内联脚本
        local cmd
        if script:sub(1, 1) == "/" or script:sub(1, 1) == "~" then
            -- 脚本文件路径
            cmd = {script}
        else
            -- 内联脚本
            cmd = {"/bin/sh", "-c", script}
        end
        local success, stdout, stderr = wezterm.run_child_process(cmd)
        handle_metrics_result(success, stdout, stderr, now_seconds())
    end)
end

-- 控制采样频率：满足时间条件且无任务执行中时才触发一次采集。
local function maybe_refresh_metrics()
    local script = get_metrics_script()
    if not script then
        return
    end
    local interval = UPDATE_INTERVAL
    if consecutive_errors >= MAX_CONSECUTIVE_ERRORS then
        interval = ERROR_BACKOFF_TIME
    end
    if metrics_inflight then
        return
    end
    if (now_seconds() - last_metrics_time) < interval then
        return
    end
    -- log_debug("trigger metrics refresh")
    start_metrics_refresh()
end

-- 事件钩子：更新左/右状态栏。右侧只读取缓存，不再阻塞。
wezterm.on("update-status", function(window, pane)
    maybe_refresh_metrics()

    -- ========================================================================
    -- Left Status: Leader/Mode/Workspace Indicators
    -- ========================================================================

    -- Leader key indicator
    local leader = window:leader_is_active() and "🌊 LEADER " or ""

    -- Key table mode indicator
    local key_table = window:active_key_table()
    local mode_icons = {
        workspace = "📦 WORKSPACE ",
        copy_mode = "📋 COPY ",
        search_mode = "🔍 SEARCH "
    }
    local mode = key_table and mode_icons[key_table] or ""

    -- Workspace indicator
    local workspace = window:active_workspace()
    local workspace_text = (workspace ~= "default") and ("  📁 " .. workspace) or ""

    -- Set left status
    window:set_left_status(wezterm.format({{
        Foreground = {
            Color = "#d79921"
        }
    }, -- Gruvbox yellow
    {
        Text = leader
    }, {
        Foreground = {
            Color = "#83a598"
        }
    }, -- Gruvbox blue
    {
        Text = mode
    }, {
        Foreground = {
            Color = "#98971a"
        }
    }, -- Gruvbox green
    {
        Text = workspace_text
    }}))

    -- 使用缓存的信息更新状态栏
    window:set_right_status(wezterm.format({{
        Foreground = {
            Color = "#b8bb26"
        }
    }, -- Gruvbox bright green
    {
        Text = metrics_cache.cpu
    }, {
        Foreground = {
            Color = "#83a598"
        }
    }, -- Gruvbox bright blue
    {
        Text = metrics_cache.mem
    }, {
        Foreground = {
            Color = "#fe8019"
        }
    }, -- Gruvbox bright orange
    {
        Text = metrics_cache.disk
    }, {
        Foreground = {
            Color = "#d3869b"
        }
    }, -- Gruvbox bright purple
    {
        Text = metrics_cache.net
    }}))
end)

-- ============================================================================
-- Command Palette Augmentation
-- ============================================================================

wezterm.on("augment-command-palette", function(window, pane)
    return {{
        brief = "📁 Pick Workspace",
        icon = "md_briefcase",
        action = act.ShowLauncherArgs({
            flags = "FUZZY|WORKSPACES"
        })
    }, {
        brief = "🔄 Reload Configuration",
        icon = "md_refresh",
        action = act.ReloadConfiguration
    }, {
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
        end)
    }, {
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
        end)
    }, {
        brief = "⬆️  Maximize Window",
        icon = "md_window_maximize",
        action = wezterm.action_callback(function(win, _)
            win:maximize()
        end)
    }, {
        brief = "📋 Copy Mode",
        icon = "md_content_copy",
        action = act.ActivateCopyMode
    }}
end)

-- ============================================================================
-- GUI Startup
-- ============================================================================

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})

    -- 启动时最大化窗口(可选)
    -- 如果不需要, 注释掉下面这行
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
