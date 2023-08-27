-- https://github.com/lukas-reineke/indent-blankline.nvim
-- 默认的颜色有点糟糕，换一下
vim.opt.termguicolors = true
vim.cmd [[highlight IndentBlanklineIndent guifg=#565552 gui=nocombine]]

return {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
        require("indent_blankline").setup {
            use_treesitter = true,
            char_highlight_list = {"IndentBlanklineIndent"},

            filetype_exclude = {"", -- for all buffers without a file type
            "dashboard", "dotooagenda", "flutterToolsOutline", "fugitive", "git", "gitcommit", "help", "json", "log",
                                "markdown", "NvimTree", "peekaboo", "startify", "TelescopePrompt", "todoist", "txt",
                                "undotree", "vimwiki", "vista"},

            buftype_exclude = {"terminal", "nofile"},
            show_trailing_blankline_indent = false,
            -- show_current_context = true,
            context_patterns = {"^if", "^table", "block", "class", "for", "function", "if_statement", "import",
                                "list_literal", "method", "selector", "type", "var", "while"},
            space_char_blankline = " "
        }
    end
}
