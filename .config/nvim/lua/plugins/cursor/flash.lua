-- https://github.com/folke/flash.nvim
-- 结合了easymotion和clvever-f的功能, 还有Treesitte集成, 对默认搜索也有所优化
return {
    "folke/flash.nvim",
    -- event = "VeryLazy",
    opts = {},
    -- stylua: ignore
    keys = {{
        "s",
        mode = {"n", "x", "o"},
        function()
            require("flash").jump()
        end,
        desc = "s : 类似easymotion的跳转"
    }, {
        "S",
        mode = {"n", "o", "x"},
        function()
            require("flash").treesitter()
        end,
        desc = "S : 基于treesitter的块选中"
    }, {
        "r",
        mode = "o",
        function()
            require("flash").remote()
        end,
        desc = "(y)r : 在当前光标下复制黏贴一个屏幕别处的词"
    }, {
        "R",
        mode = {"o", "x"},
        function()
            require("flash").treesitter_search()
        end,
        desc = "(y)~ : 在当前光标下复制黏贴一个屏幕别处的块"
    } -- 还有内置的类似clever-f的功能
    }
}
