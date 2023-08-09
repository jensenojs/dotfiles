-- https://github.com/RRethy/nvim-treesitter-textsubjects

-- 根据光标位置自动决定要选中什么textobject
-- 使用方式：快捷键使用（以v选中模式举例）
-- v.：根据光标位置，智能选择
-- v,：选中上一次选中的范围
-- v;：选中容器外围
-- vi;：选中容器内
-- <leader>+a : 

local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

local keymaps = {

    -- ["nxo|s"] = map_callback(function()
    --     require("flash").jump()
    -- end):with_desc("easymotion的跳转"),
    -- ["nxo|S"] = map_callback(function()
    --     require("flash").treesitter()
    -- end):with_desc("基于treesitter的块选中")
}

bind.nvim_load_mapping(keymaps)


return {
    "RRethy/nvim-treesitter-textsubjects",
    -- lazy = true,
    -- event = {"User FileOpened"},

    dependencies = {"nvim-treesitter/nvim-treesitter"},
    config = function()
        require("nvim-treesitter.configs").setup({
            textsubjects = {
                enable = true,
                prev_selection = ",",
                keymaps = {
                    ["."] = "textsubjects-smart",
                    [";"] = "textsubjects-container-outer",
                    ["i;"] = "textsubjects-container-inner"
                },
                include_surrounding_whilespace = false
            }
        })
    end
}
