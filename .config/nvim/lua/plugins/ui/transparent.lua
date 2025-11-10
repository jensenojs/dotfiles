-- https://github.com/xiyaowong/transparent.nvim
return {
    "xiyaowong/transparent.nvim",
    lazy = false,
    opts = function()
        return {
            enable = true,
            extra = {
                -- 窗口透明度
                window = 0.9,
                -- 颜色透明度
                color = 0.9,
            },
        }
    end,
}
