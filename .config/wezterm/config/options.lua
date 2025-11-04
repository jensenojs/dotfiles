-- Core configuration options
-- Combines: general, fonts, workspaces, domains, launcher

local wezterm = require('wezterm')

local M = {}

function M.apply(config, platform)
   -- ============================================================================
   -- General Settings
   -- ============================================================================

   config.check_for_updates = false
   config.automatically_reload_config = true

   -- Window behavior
   config.adjust_window_size_when_changing_font_size = true
   config.window_close_confirmation = 'AlwaysPrompt'

   -- 初始窗口大小(字符单位)
   -- 设置一个合理的宽高比, 避免正方形窗口
   config.initial_cols = 150 -- 宽度：150 列(字符)
   config.initial_rows = 30 -- 高度：30 行

   -- macOS specific
   -- if platform.is_mac then
   --    config.native_macos_fullscreen_mode = false
   --    config.macos_window_background_blur = 70
   -- end

   -- Shell
   config.default_prog = { platform.get_default_shell(), '-l' }

   -- Scrollback (已在 Performance 部分设置)
   -- config.scrollback_lines = 10000

   -- ============================================================================
   -- Debug (调试按键事件)
   -- ============================================================================
   -- 临时启用, 用于调试输入法问题
   config.debug_key_events = false

   -- ============================================================================
   -- Performance
   -- ============================================================================
   -- 帧率设置
   config.max_fps = 60 -- 最大帧率
   config.animation_fps = 60 -- 动画帧率

   -- GPU 适配器智能选择
   -- 使用智能选择器来挑选最佳的 GPU 和 Backend
   local gpu_adapter = require('utils.gpu-adapter')
   local best_adapter = gpu_adapter:pick_best()

   if best_adapter then
      config.front_end = 'WebGpu'
      config.webgpu_preferred_adapter = best_adapter
      wezterm.log_info(
         string.format(
            'Using GPU: %s (%s, %s)',
            best_adapter.name,
            best_adapter.backend,
            best_adapter.device_type
         )
      )
   else
      -- 如果没有找到合适的 GPU, 使用默认的 OpenGL
      config.front_end = 'OpenGL'
      wezterm.log_warn('No suitable GPU adapter found, falling back to OpenGL')
   end

   -- 可选：手动指定 GPU(用于特殊需求)
   -- 取消注释以下代码并根据需要修改
   -- config.webgpu_preferred_adapter = gpu_adapter:pick_manual('Metal', 'IntegratedGpu')

   -- 缓冲区优化
   config.scrollback_lines = 10000 -- 与上面的设置保持一致

   -- 输入处理优化
   config.allow_square_glyphs_to_overflow_width = 'Never'

   -- ============================================================================
   -- Font
   -- ============================================================================

   config.font_size = 13
   config.font = wezterm.font_with_fallback({
      { family = 'Monaco Nerd Font Mono', weight = 'Regular' },
      { family = 'JetBrains Mono', weight = 'Regular' },
      { family = 'Sarasa Term SC Nerd', weight = 'Regular' },
      { family = 'SF Pro', weight = 'Regular' },
   })
   config.line_height = 1.2

   -- 字体渲染设置(解决锯齿问题)
   config.freetype_load_target = 'Normal' -- 正常渲染模式
   config.freetype_render_target = 'Normal' -- 正常渲染目标
   -- 可选值: "Normal", "Light", "Mono", "HorizontalLcd"
   -- Normal: 标准抗锯齿(推荐)
   -- Light: 更轻的抗锯齿
   -- HorizontalLcd: LCD 亚像素渲染(可能在某些显示器上更清晰)

   -- 禁用连字(ligatures)设置
   -- HarfBuzz features 控制字体连字行为
   config.harfbuzz_features = {
      -- 完全禁用标准连字(liga=0)：避免所有连字, 包括字母和符号
      -- 禁用上下文连字(clig=0)：避免上下文连字
      -- 禁用上下文替换(calt=0)：避免自动替换字符样式
      'liga=0', -- 禁用所有标准连字(字母+符号)
      'clig=0', -- 禁用上下文连字
      'calt=0', -- 禁用上下文替换
   }

   -- ============================================================================
   -- Workspace
   -- ============================================================================

   config.default_workspace = 'main'

   -- ============================================================================
   -- Domains (SSH, WSL, Unix)
   -- ============================================================================

   -- SSH domains - add your servers here
   config.ssh_domains = {}

   -- Unix domains
   config.unix_domains = {}

   -- WSL domains (Windows only)
   if platform.is_windows then
      config.wsl_domains = {
         {
            name = 'WSL:Ubuntu',
            distribution = 'Ubuntu',
         },
      }
   end

   -- ============================================================================
   -- Launcher Menu
   -- ============================================================================

   config.launch_menu = {
      {
         label = '📝 Dotfiles',
         args = { 'zsh' },
         cwd = wezterm.home_dir .. '/.config',
      },
      {
         label = '🚀 Projects',
         args = { 'zsh' },
         cwd = wezterm.home_dir .. '/Projects',
      },
      {
         label = '🏠 Home',
         args = { 'zsh' },
         cwd = wezterm.home_dir,
      },
   }
end

return M
