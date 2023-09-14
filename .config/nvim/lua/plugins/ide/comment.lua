-- https://github.com/terrortylor/nvim-comment
-- 注释
local bind = require("utils.bind")

local map_cr = bind.map_cr
local keymaps = {
    ["nv|<c-\\>"] = map_cr(":CommentToggle"):with_noremap():with_silent():with_desc("Toggle 注释")
}

bind.nvim_load_mapping(keymaps)

return {
    "terrortylor/nvim-comment",
    config = function()
        -- Disable mappings
        require('nvim_comment').setup({
            create_mappings = false
        })
    end
}
