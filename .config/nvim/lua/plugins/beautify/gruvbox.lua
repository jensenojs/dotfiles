return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    enabled = true,
    init = function()
        vim.cmd([[colorscheme gruvbox]])
    end,

    config = function()
        -- setup must be called before loading the colorscheme
        -- Default options:
        require("gruvbox").setup({
            undercurl = true, -- 下划线颜色是否启用
            underline = true, -- 下划线是否启用
            bold = true, -- 是否使用粗体
            strikethrough = true, -- 是否启用删除线
            invert_selection = false, -- 是否反转选择颜色
            invert_signs = false, -- 是否反转符号颜色
            invert_tabline = false, -- 是否反转标签行颜色
            invert_intend_guides = false, -- 是否反转缩进指南颜色
            inverse = true, -- 反转搜索、差异、状态栏和错误的背景
            contrast = "soft", -- 可以是 "hard", "soft" 或空字符串
            palette_overrides = {}, -- 调色板覆盖
            overrides = {}, -- 覆盖
            dim_inactive = false, -- 是否将非活动窗口变暗
            transparent_mode = false -- 是否启用透明模式
        })
    end
}
