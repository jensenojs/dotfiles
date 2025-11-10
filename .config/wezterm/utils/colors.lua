-- Color schemes module

local wezterm = require("wezterm")
local M = {}

-- Gruvbox Dark color scheme (complete)
local gruvbox_dark = {
    -- Basic colors
    foreground = "#ebdbb2",
    background = "#282828",

    -- Cursor
    cursor_bg = "#ebdbb2",
    cursor_fg = "#282828",
    cursor_border = "#ebdbb2",

    -- Selection
    selection_fg = "#ebdbb2",
    selection_bg = "#665c54",

    -- Scrollbar
    scrollbar_thumb = "#504945",

    -- Split
    split = "#504945",

    -- ANSI colors
    ansi = {
        "#282828", -- black
        "#cc241d", -- red
        "#98971a", -- green
        "#d79921", -- yellow
        "#458588", -- blue
        "#b16286", -- magenta
        "#689d6a", -- cyan
        "#a89984", -- white
    },

    -- Bright colors
    brights = {
        "#928374", -- bright black
        "#fb4934", -- bright red
        "#b8bb26", -- bright green
        "#fabd2f", -- bright yellow
        "#83a598", -- bright blue
        "#d3869b", -- bright magenta
        "#8ec07c", -- bright cyan
        "#ebdbb2", -- bright white
    },

    -- Indexed colors (for 256 color support)
    indexed = {
        [16] = "#fe8019", -- orange
        [17] = "#d65d0e", -- dark orange
        [18] = "#3c3836", -- bg1
        [19] = "#504945", -- bg2
        [20] = "#bdae93", -- fg4
        [21] = "#d5c4a1", -- fg3
    },

    -- Compose cursor
    compose_cursor = "#fe8019",

    -- Tab bar colors (will be overridden by appearance.lua)
    tab_bar = {
        background = "#282828",

        active_tab = {
            bg_color = "#504945",
            fg_color = "#ebdbb2",
        },

        inactive_tab = {
            bg_color = "#3c3836",
            fg_color = "#a89984",
        },

        inactive_tab_hover = {
            bg_color = "#504945",
            fg_color = "#d5c4a1",
        },

        new_tab = {
            bg_color = "#3c3836",
            fg_color = "#a89984",
        },

        new_tab_hover = {
            bg_color = "#504945",
            fg_color = "#d5c4a1",
        },
    },
}

-- Get all custom color schemes
function M.get_schemes()
    return {
        ["Gruvbox Dark"] = gruvbox_dark,
    }
end

return M
