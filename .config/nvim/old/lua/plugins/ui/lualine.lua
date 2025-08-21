-- https://github.com/nvim-lualine/lualine.nvim
-- 只是一个美化的插件
return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require("lualine").setup({
            opt = {
                theme = "gruvbox_light"
            },
            -- sections = {
            --     lualine_x = {"aerial"}
            -- }
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'branch', 'diff', {
                    'diagnostics',
                    sources = {"nvim_diagnostic"},
                    symbols = {
                        error = ' ',
                        warn = ' ',
                        info = ' ',
                        hint = ' '
                    }
                }},
                lualine_c = {'filename'},
                lualine_x = {'copilot', 'encoding', 'fileformat', 'filetype'}, -- I added copilot here
                lualine_y = {'progress'},
                lualine_z = {'location'}
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {'filename'},
                lualine_x = {'location'},
                lualine_y = {},
                lualine_z = {}
            },
            tabline = {},
            extensions = {}
        })
    end,
    dependencies = {{'AndreM222/copilot-lualine'}}
}
