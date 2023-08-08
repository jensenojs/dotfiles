local global = require("basic.global")

-- leader键设置为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 
local clipboard_config = function()
    if global.is_mac then
        vim.g.clipboard = {
            name = "macOS-clipboard",
            copy = {
                ["+"] = "pbcopy",
                ["*"] = "pbcopy"
            },
            paste = {
                ["+"] = "pbpaste",
                ["*"] = "pbpaste"
            },
            cache_enabled = 0
        }
    elseif global.is_wsl then
        vim.g.clipboard = {
            name = "win32yank-wsl",
            copy = {
                ["+"] = "win32yank.exe -i --crlf",
                ["*"] = "win32yank.exe -i --crlf"
            },
            paste = {
                ["+"] = "win32yank.exe -o --lf",
                ["*"] = "win32yank.exe -o --lf"
            },
            cache_enabled = 0
        }
    end
    -- https://luyuhuang.tech/2023/03/21/nvim.html#打通剪切板
    -- 当复制到 + 寄存器时, 会执行命令 tmux load-buffer -w - 将复制的内容以标准输入的形式传递给 tmux; 
    -- 当从 + 寄存器粘贴内容时, 会执行命令 tmux save-buffer - 从标准输出读取要粘贴的内容. 
    -- 命令末尾的 - 告诉 tmux 从标准输入/输出读写内容.
    if vim.env.TMUX then
        vim.g.clipboard = {
            name = 'tmux-clipboard',
            copy = {
                ['+'] = {'tmux', 'load-buffer', '-w', '-'}
            },
            paste = {
                ['+'] = {'tmux', 'save-buffer', '-'}
            },
            cache_enabled = true
        }
    end
end

local shell_config = function()
    if global.is_windows then
        if not (vim.fn.executable("pwsh") == 1 or vim.fn.executable("powershell") == 1) then
            vim.notify([[
Failed to setup terminal config

PowerShell is either not installed, missing from PATH, or not executable;
cmd.exe will be used instead for `:!` (shell bang) and toggleterm.nvim.

You're recommended to install PowerShell for better experience.]], vim.log.levels.WARN, {
                title = "[core] Runtime Warning"
            })
            return
        end

        local basecmd = "-NoLogo -MTA -ExecutionPolicy RemoteSigned"
        local ctrlcmd = "-Command [console]::InputEncoding = [console]::OutputEncoding = [System.Text.Encoding]::UTF8"
        vim.api.nvim_set_option_value("shell", vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell", {})
        vim.api.nvim_set_option_value("shellcmdflag", string.format("%s %s;", basecmd, ctrlcmd), {})
        vim.api.nvim_set_option_value("shellredir", "-RedirectStandardOutput %s -NoNewWindow -Wait", {})
        vim.api.nvim_set_option_value("shellpipe", "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode", {})
        vim.api.nvim_set_option_value("shellquote", nil, {})
        vim.api.nvim_set_option_value("shellxquote", nil, {})
    end
end

local load = function()
    if vim.g.vscode then
        -- VSCode extension
    else
        clipboard_config()
        shell_config()

        -- ordinary Neovim
        require("basic.keymaps")
        require("basic.options")
        require("basic.lazy")
        require("basic.autocmds")
    end
end

load()
