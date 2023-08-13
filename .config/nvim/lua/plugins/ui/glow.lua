-- https://github.com/ellisonleao/glow.nvim
-- 一个轻量的markdown预览器
local bind = require("utils.bind")
local map_cr = bind.map_cr

local keymaps = {
    -- 还有内置的类似clever-f的功能
    ["n|md"] = map_cr("Glow"):with_noremap():with_silent():with_desc("查看markdown预览")
}

bind.nvim_load_mapping(keymaps)

return {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",

    -- vim.keymap.set('c', 'md', "Glow", {}, {
    --     desc = ''
    -- })

}
