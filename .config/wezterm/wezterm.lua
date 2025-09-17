-- ██╗    ██╗███████╗███████╗████████╗███████╗██████╗ ███╗   ███╗
-- ██║    ██║██╔════╝╚══███╔╝╚══██╔══╝██╔════╝██╔══██╗████╗ ████║
-- ██║ █╗ ██║█████╗    ███╔╝    ██║   █████╗  ██████╔╝██╔████╔██║
-- ██║███╗██║██╔══╝   ███╔╝     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║
-- ╚███╔███╔╝███████╗███████╗   ██║   ███████╗██║  ██║██║ ╚═╝ ██║
--  ╚══╝╚══╝ ╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝
--
-- A GPU-accelerated cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/
--
-- Configuration Version: 1.0
-- Design: Modular, Cross-platform, Leader-key System

local wezterm = require('wezterm')

-- ============================================================================
-- Initialize Configuration
-- ============================================================================

local config = wezterm.config_builder and wezterm.config_builder() or {}

-- Enable strict mode to catch configuration errors early
if wezterm.config_builder then
   config:set_strict_mode(true)
end

-- Load platform detection (must be first)
local platform = require('config.platform')

-- Load configuration modules
require('config.options').apply(config, platform)
require('config.appearance').apply(config, platform)
require('config.keymaps').apply(config, platform)

-- Load event handlers with optional configuration
require('config.events').setup({
   -- Status bar settings
   show_seconds = false,
   date_format = '%H:%M',

   -- Tab title settings
   show_tab_index = true,
   show_process = true,
   show_unseen_indicator = true,

   -- Feature toggles
   enable_command_palette = true,
})

-- ============================================================================
-- Return Configuration
-- ============================================================================

return config
