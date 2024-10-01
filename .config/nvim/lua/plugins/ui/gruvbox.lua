-- https://github.com/ellisonleao/gruvbox.nvim
return {
    "ellisonleao/gruvbox.nvim",
    -- event = "VimEnter", -- 皮肤要先加载, 不过用even还是有点Bug, 不知道为什么
    -- priority = 1000,
    lazy = false,

    config = function()
        -- setup must be called before loading the colorscheme
        require("gruvbox").setup({
            transparent_mode = false -- 启用透明模式
            -- transparent_mode = true -- 启用透明模式
        })
        vim.cmd([[colorscheme gruvbox]])
    end
}
