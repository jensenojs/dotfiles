-- https://github.com/akinsho/bufferline.nvim
-- 缓冲区/标签栏。使用 tabs 模式模拟原生 tabline
-- https://github.com/roobert/bufferline-cycle-windowless.nvim
-- 需要么? 还是算了
-- https://github.com/akinsho/bufferline.nvim/issues/1021
return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    main = "bufferline",
    opts = function()
        local icons = require("utils.icons").get("ui")

        -- 获取编辑器背景色
        local function get_hl_color(group, attr)
            local hl = vim.api.nvim_get_hl(0, { name = group })
            if hl and hl[attr] then
                return string.format("#%06x", hl[attr])
            end
            return nil
        end

        -- 颜色变暗函数
        local function darken(hex, amount)
            local r = tonumber(hex:sub(2, 3), 16)
            local g = tonumber(hex:sub(4, 5), 16)
            local b = tonumber(hex:sub(6, 7), 16)
            r = math.max(0, math.floor(r * (1 - amount)))
            g = math.max(0, math.floor(g * (1 - amount)))
            b = math.max(0, math.floor(b * (1 - amount)))
            return string.format("#%02x%02x%02x", r, g, b)
        end

        -- 基于主题的前景色做明暗区分，背景透明交给 transparent.nvim 处理
        local fg = get_hl_color("Normal", "fg") or "#cdd6f4"
        local fg_inactive = darken(fg, 0.4) -- 未选中标签文字（暗 40%）
        local accent = get_hl_color("String", "fg") or "#a6e3a1" -- 选中高亮色

        return {
            highlights = {
                -- 默认区域文字略暗
                background = { fg = fg_inactive },
                fill = {},
                -- 当前 buffer: 使用主题的强调色
                buffer_selected = { fg = accent },
                tab_selected = { fg = accent },
                -- 可见但未选中: 使用暗一些的前景
                buffer_visible = { fg = fg_inactive },
                tab = { fg = fg_inactive },
            },
            options = {
                indicator = {
                    icon = "",
                    style = "none",
                },
                separator_style = { "", "" },
                offsets = {
                    {
                        filetype = "aerial",
                        text = "Aerial",
                        highlight = "Normal",
                        separator = true,
                    },
                },
                -- custom_filter = function(bufnr, _)
                --     local ft = vim.bo[bufnr].filetype
                --     if ft == "Avante" or ft == "AvanteInput" or ft == "AvanteTodos" or ft == "AvanteSelectedFiles" then
                --         return false
                --     end
                --     return true
                -- end,
            },
        }
    end,
}
