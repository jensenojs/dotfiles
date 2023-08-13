-- https://github.com/stevearc/aerial.nvim
-- 文件大纲
-- 类似： https://github.com/liuchengxu/vista.vim 
-- 其实coc-nvim本身也有大纲，但是那个太丑了
return {
    'stevearc/aerial.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = {"nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"},

    config = function()
        require('aerial').setup({
            -- optionally use on_attach to set keymaps when aerial has attached to a buffer
            on_attach = function(bufnr)
                -- Jump forwards/backwards with '{' and '}'
                vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {
                    buffer = bufnr
                })
                vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {
                    buffer = bufnr
                })
            end

        })
        vim.keymap.set('n', '<leader>o', '<cmd>AerialToggle!<CR>')

    end

}
