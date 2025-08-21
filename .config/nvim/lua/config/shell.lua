-- config/shell.lua
-- 目的: 在 Windows 环境下设置更合理的 shell 选项, 统一编码为 UTF-8
-- 背景:
--   - Neovim 调用外部命令时依赖 'shell' 相关选项, 默认 cmd.exe 体验较差
--   - PowerShell 在 Windows 上更现代, 但需要正确设置输入/输出编码
--   - 本模块移植自 old/init.lua, 在核心层集中初始化, 尽早生效

local M = {}

function M.setup()
  local global = require("config.global")
  if not global.is_windows then return end

  local has_pwsh = (vim.fn.executable("pwsh") == 1)
  local has_ps   = (vim.fn.executable("powershell") == 1)
  if not (has_pwsh or has_ps) then
    -- 提示: 未找到 PowerShell, 回退使用 cmd.exe, 功能可用但体验欠佳
    vim.schedule(function()
      vim.notify([[未检测到 PowerShell, 将回退使用 cmd.exe

建议安装 PowerShell 以获得更好的终端/编码体验。]], vim.log.levels.WARN, { title = "[config] 运行时警告" })
    end)
    return
  end

  local basecmd = "-NoLogo -MTA -ExecutionPolicy RemoteSigned"
  local ctrlcmd = "-Command [console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8"
  vim.api.nvim_set_option_value("shell", has_pwsh and "pwsh" or "powershell", {})
  vim.api.nvim_set_option_value("shellcmdflag", string.format("%s %s;", basecmd, ctrlcmd), {})
  vim.api.nvim_set_option_value("shellredir", "-RedirectStandardOutput %s -NoNewWindow -Wait", {})
  vim.api.nvim_set_option_value("shellpipe", "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode", {})
  vim.api.nvim_set_option_value("shellquote", nil, {})
  vim.api.nvim_set_option_value("shellxquote", nil, {})
end

return M
