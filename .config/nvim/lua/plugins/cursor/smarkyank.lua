-- https://github.com/ibhagwan/smartyank.nvim
-- 在"dd"等不希望将内容复制到系统剪贴板的时候不复制到系统剪贴板。支持在SSH等情况复制到系统剪贴板
return {
    'ibhagwan/smartyank.nvim',
    lazy = true,
    event = {"BufRead", "BufNewFile"},
    config = function()
        require("smartyank").setup({
            -- https://github.com/ayamir/nvimdots/blob/55db842cf9f8640a9cbab0bc599c91b5d2f560d5/lua/modules/configs/tool/smartyank.lua
            highlight = {
                enabled = false, -- highlight yanked text
                higroup = "IncSearch", -- highlight group of yanked text
                timeout = 2000 -- timeout for clearing the highlight
            },
            clipboard = {
                enabled = true
            },
            tmux = {
                enabled = true,
                -- remove `-w` to disable copy to host client's clipboard
                cmd = {"tmux", "set-buffer", "-w"}
            },
            osc52 = {
                enabled = true,
                escseq = "tmux", -- use tmux escape sequence, only enable if you're using remote tmux and have issues (see #4)
                ssh_only = true, -- false to OSC52 yank also in local sessions
                silent = false, -- true to disable the "n chars copied" echo
                echo_hl = "Directory" -- highlight group of the OSC52 echo message
            }
        })
    end
}
