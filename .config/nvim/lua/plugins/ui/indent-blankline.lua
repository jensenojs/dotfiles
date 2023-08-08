vim.opt.list = true

-- 默认的颜色有点糟糕，换一下
vim.opt.termguicolors = true
vim.cmd [[highlight IndentBlanklineIndent guifg=#565552 gui=nocombine]]

return {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("indent_blankline").setup {
            use_treesitter = true,
            char_highlight_list = {"IndentBlanklineIndent"},
        }
    end
}
