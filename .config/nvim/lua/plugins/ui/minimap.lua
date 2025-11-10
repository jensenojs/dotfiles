--- https://github.com/Isrothy/neominimap.nvim
---@module "neominimap.config.meta"
return {
    "Isrothy/neominimap.nvim",
    lazy = false, -- NOTE: NO NEED to Lazy load
    -- Optional. You can alse set your own keybindings
    init = function()
        -- The following options are recommended when layout == "float"
        vim.opt.wrap = false
        vim.opt.sidescrolloff = 36 -- Set a large value

        --- Put your configuration here
        ---@type Neominimap.UserConfig
        vim.g.neominimap = {
            auto_enable = true,
            click = {
                enabled = true,
            },
            --- Used when `layout` is set to `float`
            float = {
                minimap_width = 10,
            },
        }
    end,
}
