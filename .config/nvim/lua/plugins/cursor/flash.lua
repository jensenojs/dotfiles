-- https://github.com/folke/flash.nvim
-- 光标移动插件, 结合了easymotion和clvever-f的功能, 还有Treesitte集成, 对默认搜索也有所优化
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local keymaps = {
    -- 还有内置的类似clever-f的功能

    ["nxo|s"] = map_callback(function()
        require("flash").jump()
    end):with_desc("easymotion的跳转"),
    ["nxo|S"] = map_callback(function()
        require("flash").treesitter()
    end):with_desc("基于treesitter的块选中")
}

bind.nvim_load_mapping(keymaps)

return {
    "folke/flash.nvim",
    event = "VeryLazy",
    config = true
}
