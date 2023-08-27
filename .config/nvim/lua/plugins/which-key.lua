-- https://github.com/folke/which-key.nvim
-- 我设置了这么多快捷键, 记不住怎么办? which-key 来帮忙!
local icons = {
    ui = require("utils.icons").get("ui"),
    misc = require("utils.icons").get("misc")
}

return {
    "folke/which-key.nvim",
    event = "VeryLazy",

    config = function()
        require("which-key").setup({
            -- which-key是有内置插件功能的
            plugins = {
                -- https://github.com/folke/which-key.nvim#-plugins
                presets = {
                    operators = false,
                    motions = false,
                    text_objects = false,
                    windows = false,
                    nav = false,
                    z = true,
                    g = true
                }
            },

            icons = {
                breadcrumb = icons.ui.Separator,
                separator = icons.misc.Vbar,
                group = icons.misc.Add
            },

            -- 放大一点
            window = {
                border = "none",
                position = "bottom",
                margin = {1, 0, 1, 0},
                padding = {1, 1, 1, 1},
                winblend = 0
            }
        })
    end
}
