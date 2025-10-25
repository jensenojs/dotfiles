-- Appearance configuration module
-- Visual settings: colors, window decorations, tab bar, backgrounds

local wezterm = require('wezterm')

local M = {}

function M.apply(config, platform)
   -- ============================================================================
   -- Background Images (Optional)
   -- ============================================================================

   -- 背景图片管理
   -- 要启用：
   --   1. 将 enabled 设置为 true
   --   2. 在 ~/.config/wezterm/backdrops/ 放置图片(已自动创建)
   --   3. 重载配置(Cmd+R 或 Alt+R)
   local backdrops = require('utils.backdrops'):new({
      enabled = true,
      images_dir = wezterm.config_dir .. '/backdrops/',
      opacity = 0.90, -- 背景透明度 (0.0-1.0)
      blur = 0, -- 模糊程度 (0-100)，0=不模糊
   })

   -- 如果启用了背景，应用到配置
   local bg_opts = backdrops:get_background_opts()
   if bg_opts then
      config.background = bg_opts
   end

   -- 保存实例到模块，供快捷键使用
   M._backdrops_instance = backdrops
   -- ============================================================================
   -- Color Scheme
   -- ============================================================================

   config.color_scheme = 'Gruvbox Dark (Gogh)'

   -- Import custom color schemes
   local colors = require('utils.colors')
   config.color_schemes = colors.get_schemes()

   -- ============================================================================
   -- Window Appearance
   -- ============================================================================

   -- Window decorations (platform-specific)
   if platform.is_mac then
      config.window_decorations = 'TITLE|RESIZE'
   else
      config.window_decorations = 'RESIZE'
   end

   -- Window opacity
   config.window_background_opacity = 0.95
   config.text_background_opacity = 1.0 -- Keep text readable

   -- Window padding
   -- macOS: 增加顶部 padding 避免与窗口按钮重叠
   -- if platform.is_mac then
   config.window_padding = {
      left = 8,
      right = 8,
      top = 35, -- 增加顶部空间，避免与红绿灯按钮重叠
      bottom = 1, -- 减少底部间隔，紧贴 lualine
   }
   -- else
   -- 	config.window_padding = {
   -- 		left = 8,
   -- 		right = 8,
   -- 		top = 8,
   -- 		bottom = 8,
   -- 	}
   -- end

   -- ============================================================================
   -- Tab Bar
   -- ============================================================================

   -- Show tab bar always
   config.hide_tab_bar_if_only_one_tab = false

   -- Tab bar at bottom
   config.tab_bar_at_bottom = true

   -- Use retro tab bar (not fancy)
   config.use_fancy_tab_bar = false

   -- Tab max width
   config.tab_max_width = 32

   -- Colors for tab bar and UI elements (Gruvbox)
   config.colors = {
      -- Foreground/Background
      foreground = '#ebdbb2',
      background = '#282828',

      -- Cursor
      cursor_bg = '#ebdbb2',
      cursor_fg = '#282828',
      cursor_border = '#ebdbb2',

      -- Selection
      selection_fg = '#ebdbb2',
      selection_bg = '#504945',

      -- Scrollbar
      scrollbar_thumb = '#504945',

      -- Split lines
      split = '#504945',

      -- Compose cursor (for IME)
      compose_cursor = '#fe8019',

      -- Copy mode colors (使用 Gruvbox 颜色)
      copy_mode_active_highlight_bg = { Color = '#fabd2f' },
      copy_mode_active_highlight_fg = { Color = '#282828' },
      copy_mode_inactive_highlight_bg = { Color = '#665c54' },
      copy_mode_inactive_highlight_fg = { Color = '#ebdbb2' },
      quick_select_label_bg = { Color = '#fb4934' },
      quick_select_label_fg = { Color = '#282828' },
      quick_select_match_bg = { Color = '#fabd2f' },
      quick_select_match_fg = { Color = '#282828' },

      tab_bar = {
         background = '#282828',

         active_tab = {
            bg_color = '#504945',
            fg_color = '#ebdbb2',
            intensity = 'Bold',
         },

         inactive_tab = {
            bg_color = '#3c3836',
            fg_color = '#a89984',
         },

         inactive_tab_hover = {
            bg_color = '#504945',
            fg_color = '#d5c4a1',
         },

         new_tab = {
            bg_color = '#3c3836',
            fg_color = '#a89984',
         },

         new_tab_hover = {
            bg_color = '#504945',
            fg_color = '#d5c4a1',
         },
      },
   }
end

return M
