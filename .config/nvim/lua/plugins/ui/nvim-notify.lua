-- https://github.com/rcarriga/nvim-notify
-- 将各种提示显示为弹窗
return {
    'rcarriga/nvim-notify',
    -- lazy = true,
    -- event = "VeryLazy",
    config = function()
        local notify = require("notify")
        notify.setup({
            -- "fade", "slide", "fade_in_slide_out", "static"
            stages = "static",
            on_open = nil,
            on_close = nil,
            timeout = 5000,
            fps = 1,
            render = "default",
            background_colour = "Normal",
            max_width = math.floor(vim.api.nvim_win_get_width(0) / 2),
            max_height = math.floor(vim.api.nvim_win_get_height(0) / 4),
            minimum_width = 70,
            -- ERROR > WARN > INFO > DEBUG > TRACE
            level = "WARN"
        })

        vim.notify = notify
    end
}
