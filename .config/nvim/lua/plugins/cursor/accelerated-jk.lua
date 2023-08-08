-- https://github.com/rainbowhxch/accelerated-jk.nvim
-- 连续按下j / k 的时候会提高其移速

local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local keymaps = {
    ["n|j"] = map_cmd("<Plug>(accelerated_jk_gj)"):with_desc("光标: 下移,持续按会加速"),
    ["n|k"] = map_cmd("<Plug>(accelerated_jk_gk)"):with_desc("光标: 上移,持续按会加速")
}

bind.nvim_load_mapping(keymaps)

return {
    'rainbowhxch/accelerated-jk.nvim',
    config = true
}
