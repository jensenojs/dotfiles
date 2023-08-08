-- https://github.com/akinsho/bufferline.nvim
--

local hide = {
    qf = true
}

return {
    "akinsho/bufferline.nvim",
    -- 文件的光标
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        require("bufferline").setup({
            options = {
                mode = 'tabs',
                max_name_length = 30,

                -- 让tab标签往右移动一点, 把位置留出来给NvimTree
                offsets = {{
                    filetype = 'NvimTree',
                    text = 'File Explorer',
                    highlight = 'Directory',
                    padding = 1
                }},

                custom_filter = function(bufnr)
                    return not hide[vim.bo[bufnr].filetype]
                end,

                numbers = function(opts)
                    -- return string.format("%s", opts.ordinal)
                    return string.format("%s•%s", opts.raise(opts.id), opts.lower(opts.ordinal))
                end,

                -- get an indicator in the bufferline for a given tab if it has any errors
                diagnostics = "coc"
            },

            vim.keymap.set("n", "<s-h>", ":BufferLineCyclePrev<CR>"),
            vim.keymap.set("n", "<s-l>", ":BufferLineCycleNext<CR>")

        })
    end
}
