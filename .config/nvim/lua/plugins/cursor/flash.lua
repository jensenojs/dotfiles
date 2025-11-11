-- https://github.com/folke/flash.nvim
-- 光标移动插件, 结合了easymotion和clvever-f的功能, 还有Treesitte集成, 对默认搜索也有所优化
return {
    "folke/flash.nvim",

    -- 1. 触发器 & 动作 (语义与您的 bind.lua 完全一致)
    --    格式: { "按键", function() ... end, "模式", "描述" }
    --    lazy.nvim 会在按下按键时, 自动加载插件, 然后执行该函数
    keys = {
        -- 复现: ["nxo|s"] = map_callback(function() require("flash").jump() end)
        {
            "s",
            mode = { "n", "x", "o" },
            function()
                require("flash").jump()
            end,
            desc = "Flash: 跳转 (s)",
        },

        -- 复现: ["nxo|S"] = map_callback(function() require("flash").treesitter() end)
        {
            "S",
            mode = { "n", "x", "o" },
            function()
                require("flash").treesitter()
            end,
            desc = "Flash: Treesitter (S)",
        },

        -- 插件默认的 f/F 也需要触发器, 它们会使用插件的默认动作
        { "f", mode = { "n", "x", "o" }, desc = "Flash: f-跳转" },
        { "F", mode = { "n", "x", "o" }, desc = "Flash: F-跳转" },
    },

    -- 2. 插件配置 (您的原始配置)
    opts = {
        keys = { { "t", false } }, -- 有s和f作为快捷键就可以了, 不需要再有一个t
    },
}
