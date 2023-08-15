-- https://github.com/akinsho/toggleterm.nvim
-- 浮动
return {
    "numToStr/FTerm.nvim",
    event = 'VeryLazy',
    config = function()
        require'FTerm'.setup({
            border = 'double',
            dimensions = {
                height = 0.9,
                width = 0.9
            }
        })
        vim.keymap.set('n', '<c-space>', '<CMD>lua require("FTerm").toggle()<CR>')
        vim.keymap.set('t', '<c-space>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    end
}
