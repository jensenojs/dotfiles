-- https://github.com/Bekaboo/dropbar.nvim
-- IDE 风格的 winbar 面包屑导航
return {
    "Bekaboo/dropbar.nvim",
    event = "UIEnter",
    dependencies = { {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    } },
    main = "dropbar",
    opts = {},
    init = function()
        local api = vim.api

        local function tune_winbar()
            local ok, normal = pcall(api.nvim_get_hl, 0, { name = "Normal" })
            local fg
            if ok and normal and normal.fg then
                fg = string.format("#%06x", normal.fg)
            end

            api.nvim_set_hl(0, "WinBar", { fg = fg, bg = "NONE" })
            api.nvim_set_hl(0, "WinBarNC", { fg = fg, bg = "NONE" })
        end

        api.nvim_create_autocmd("User", {
            pattern = "TransparentClear",
            callback = function()
                tune_winbar()
            end,
        })

        api.nvim_create_autocmd("ColorScheme", {
            callback = function()
                tune_winbar()
            end,
        })
    end,
}
