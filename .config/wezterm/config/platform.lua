-- Platform detection and abstraction module
-- Provides platform-specific configuration helpers

local wezterm = require("wezterm")

local M = {}

-- Detect operating system
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

-- Platform-specific default shell
function M.get_default_shell()
	if M.is_mac or M.is_linux then
		return "/bin/zsh"
	elseif M.is_windows then
		return "pwsh.exe"
	end
end

return M
