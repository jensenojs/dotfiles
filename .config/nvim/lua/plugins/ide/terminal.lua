-- https://github.com/akinsho/toggleterm.nvim
-- 类似vscode的终端

local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd

local keymaps = {
    -- https://stackoverflow.com/questions/76883693/when-i-use-nvim-c-keymapping-does-not-working-in-tmux
    -- <c-`> tmux识别不了, 这个快捷键没法和vscode兼容

    ["n|<space>ho"] = map_cr("lua _btop_toggle()")
        :with_noremap():with_silent():with_desc("查看htop"),

    ["n|<space>my"] = map_cr("lua _mysql_toggle()")
        :with_noremap():with_silent():with_desc("连接mysql")
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
            start_in_insert = true,   -- 自动进入插入模式
            direction = 'horizontal', -- 在当前buffer的下方打开新终端
            autochdir = true, -- when neovim changes it current directory the terminal will change it's own when next it's opened
        })

        local Terminal  = require('toggleterm.terminal').Terminal

        local btop = Terminal:new({
            cmd = "btop",
            hidden = true,
            direction = "float",
            float_opts = {
                border = "double",
            },
        })
        function _btop_toggle()
            btop:toggle()
        end

        local mysql = Terminal:new({
            cmd = "mysql -h 127.0.0.1 -P3306 -uroot -p111",
            hidden = true,
            direction = "float",
            float_opts = {
                border = "double",
            },
        })

        function _mysql_toggle()
            mysql:toggle()
        end

    end,
}
