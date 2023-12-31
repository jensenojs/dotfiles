-- https://github.com/numToStr/FTerm.nvim
-- 一个简单的终端

-- local bind = require("utils.bind")
-- local map_callback = bind.map_callback
-- local map_cr = bind.map_cr
--
-- local keymaps = {
--     ["n|<c-space>"] = map_callback(function()
--         require('FTerm').toggle()
--     end):with_noremap():with_silent():with_desc("打开终端"),
--     ["t|<c-space>"] = map_cr("<C-\\><C-n><CMD>lua require(\"FTerm\").toggle()"):with_noremap():with_silent():with_desc(
--         "关闭终端")
-- }
--
-- bind.nvim_load_mapping(keymaps)
-- Example keybindings
vim.keymap.set('n', '<c-leader>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<c-leader>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

-- option key for map
vim.keymap.set('n', '<A-space>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<A-space>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

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
    end
}
