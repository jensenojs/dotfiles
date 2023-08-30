-- https://github.com/stevearc/aerial.nvim
-- 文件大纲
local bind = require("utils.bind")
local map_callback = bind.map_callback

local keymaps = {
    ["n|<leader>o"] = map_callback(function()
        require('aerial').toggle({
            focus = false
        })
    end):with_noremap():with_silent():with_desc("大纲: 打开/关闭")
}

bind.nvim_load_mapping(keymaps)

return {
    'stevearc/aerial.nvim',
    dependencies = {"nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"},

    config = function()
        require('aerial').setup({
            -- optionally use on_attach to set keymaps when aerial has attached to a buffer

            keymaps = {
                ["H"] = "actions.close"
            },

            on_attach = function(bufnr)
                -- Jump forwards/backwards with '{' and '}'
                vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {
                    buffer = bufnr
                })
                vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {
                    buffer = bufnr
                })
                -- vim.keymap.set('n', '<s-h>', '<cmd>AerialNext<CR>', {
                --     buffer = bufnr
                -- })
            end

        })

        -- 自动打开
        vim.api.nvim_create_autocmd("Vimenter", {
            callback = function()
                require('aerial').open({
                    focus = false
                })
            end
        })
    end

}
