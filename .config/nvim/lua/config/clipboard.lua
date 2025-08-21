-- config/clipboard.lua
-- 目的: 统一管理剪贴板接入(跨平台), 并在 tmux 环境中优先使用 tmux buffer
-- 背景:
--   - 剪贴板属于“系统状态”, 它的位置与生命周期影响到复制/粘贴体验
--   - 在 Neovim 中, g:clipboard 可声明外部 copy/paste 命令, 由 provider 托管
--   - 该模块将旧 init.lua 中分散的逻辑集中到 config 层, 以便在初始化早期生效

local M = {}

function M.setup()
  local global = require("config.global")

  -- macOS: 使用系统自带 pbcopy/pbpaste, 零依赖
  if global.is_mac then
    vim.g.clipboard = {
      name = "macOS-clipboard",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
  -- WSL: 使用 win32yank.exe 桥接到 Windows 剪贴板
  elseif global.is_wsl then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
      paste = { ["+"] = "win32yank.exe -o --lf",   ["*"] = "win32yank.exe -o --lf"   },
      cache_enabled = 0,
    }
  end

  -- tmux 集成: 若处于 tmux, 优先以 tmux buffer 为真源
  --   - 复制: `tmux load-buffer -w -` 从 stdin 读入写入 buffer
  --   - 粘贴: `tmux save-buffer -`   将 buffer 输出到 stdout
  if vim.env.TMUX then
    vim.g.clipboard = {
      name = "tmux-clipboard",
      copy = { ['+'] = { 'tmux', 'load-buffer', '-w', '-' } },
      paste = { ['+'] = { 'tmux', 'save-buffer', '-' } },
      cache_enabled = true,
    }
  end
end

return M
