-- Platform detection and abstraction module
-- Provides platform-specific configuration helpers
local wezterm = require("wezterm")

local M = {}

M.is_mac = wezterm.target_triple:find("darwin") ~= nil
M.is_linux = wezterm.target_triple:find("linux") ~= nil
M.is_windows = wezterm.target_triple:find("windows") ~= nil

-- Primary modifier key (大拇指友好)
-- Mac: SUPER (Cmd), Linux: ALT
M.mod = M.is_mac and "SUPER" or "ALT"

-- Leader key modifier
M.leader_mod = M.mod

-- Platform-specific helpers
function M.get_home_dir()
    return wezterm.home_dir
end

function M.path_separator()
    return M.is_windows and "\\" or "/"
end

-- Get config directory
function M.get_config_dir()
    local home = M.get_home_dir()
    local sep = M.path_separator()
    return home .. sep .. ".config" .. sep .. "wezterm"
end

local function normalize_shell_env(var)
    if not var or var == "" then
        return nil
    end
    return var
end

local function login_supported(shell_name)
    return shell_name == "zsh" or shell_name == "bash" or shell_name == "sh" or shell_name == "fish"
end

--- Return the default program (shell + args) to launch panes with
--- Falls back to sensible defaults per-platform and avoids passing
--- unsupported login flags (e.g. on PowerShell).
function M.get_default_prog()
    if M.is_windows then
        local comspec = normalize_shell_env(os.getenv("COMSPEC"))
        if comspec then
            return {comspec}
        end
        return {"pwsh.exe", "-NoLogo"}
    end

    local shell = normalize_shell_env(os.getenv("SHELL"))
    if not shell then
        if M.is_mac then
            shell = "/bin/zsh"
        else
            -- Linux 默认使用 bash, 兼容未安装 zsh 的主机
            shell = "/bin/bash"
        end
    end

    local shell_name = shell:match("([^/]+)$") or shell
    if login_supported(shell_name) then
        return {shell, "-l"}
    end

    return {shell}
end

-- Backwards-compatible helper (returns the binary path only)
function M.get_default_shell()
    local prog = M.get_default_prog()
    return prog and prog[1] or nil
end

return M
