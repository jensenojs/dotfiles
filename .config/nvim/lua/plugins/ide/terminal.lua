-- https://github.com/akinsho/toggleterm.nvim
-- 类似vscode的终端
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd

local keymaps = {
    -- https://stackoverflow.com/questions/76883693/when-i-use-nvim-c-keymapping-does-not-working-in-tmux
    -- <c-`> tmux识别不了, 这个快捷键没法和vscode兼容

    ["n|<space>bo"] = map_cr("lua _btop_toggle()"):with_noremap():with_silent():with_desc("查看btop"),

    ["n|<space>mo"] = map_cr("lua _matrixone_toggle()"):with_noremap():with_silent():with_desc("连接matrixone"),

    ["n|<space>my"] = map_cr("lua _mysql_toggle()"):with_noremap():with_silent():with_desc("连接mysql")

}

bind.nvim_load_mapping(keymaps)

-- 希望在终端模式中能够移动光标
-- vim.api.nvim_set_keymap("t", "<leader>l", "<Cmd> wincmd l<CR>", {noremap = true, silent = true})
-- vim.api.nvim_set_keymap("t", "<leader>h", "<Cmd> wincmd h<CR>", {noremap = true, silent = true})
-- vim.api.nvim_set_keymap("t", "<leader>j", "<Cmd> wincmd j<CR>", {noremap = true, silent = true})
-- vim.api.nvim_set_keymap("t", "<leader>k", "<Cmd> wincmd k<CR>", {noremap = true, silent = true})

return {
    'akinsho/toggleterm.nvim',
    version = "*",
    event = 'VeryLazy',
    config = function()
        require("toggleterm").setup({
            open_mapping = [[<c-\>]],
            start_in_insert = true, -- 自动进入插入模式
            direction = 'float', -- 额外弹出一个界面, 不然和aerial有冲突
            autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
            on_open = function(term)
                vim.cmd("startinsert!")
                vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {
                    noremap = true,
                    silent = true
                })
            end
        })

        local Terminal = require('toggleterm.terminal').Terminal

        local btop = Terminal:new({
            cmd = "btop",
            hidden = true,
            direction = "float",
            float_opts = {
                border = "double"
            }
        })
        function _btop_toggle()
            btop:toggle()
        end

        local mysql = Terminal:new({
            cmd = "mysql -uroot -p123",
            hidden = true,
            direction = "float",
            float_opts = {
                border = "double"
            }
        })
        function _mysql_toggle()
            mysql:toggle()
        end

        local matrixone = Terminal:new({
            cmd = "mysql -h 127.0.0.1 -P6001 -uroot -p111 --local-infile",
            hidden = true,
            direction = "float",
            float_opts = {
                border = "double"
            }
        })
        function _matrixone_toggle()
            matrixone:toggle()
        end

    end
}
