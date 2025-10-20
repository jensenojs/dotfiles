-- Mouse bindings configuration
-- Handles trackpad gestures and mouse events

local wezterm = require('wezterm')
local act = wezterm.action

local M = {}

function M.apply(config, platform)
   -- ============================================================================
   -- Mouse Bindings
   -- ============================================================================

   config.mouse_bindings = {
      -- 触控板双击黏贴
      {
         event = { Down = { streak = 2, button = 'Left' } },
         mods = 'NONE',
         action = act.PasteFrom('Clipboard'),
      },
      -- 禁用双击的默认文本选择行为，避免冲突
      {
         event = { Up = { streak = 2, button = 'Left' } },
         mods = 'NONE',
         action = act.Nop,
      },
      -- 仅在按下 CTRL 时才允许点击超链接, 避免误触
      {
         event = { Up = { streak = 1, button = 'Left' } },
         mods = 'CTRL',
         action = act.OpenLinkAtMouseCursor,
      },
      {
         event = { Down = { streak = 1, button = 'Left' } },
         mods = 'CTRL',
         action = act.Nop,
      },
   }
end

return M
