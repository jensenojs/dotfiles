-- https://github.com/folke/which-key.nvim
-- 我设置了这么多快捷键, 记不住怎么办? which-key 来帮忙!
return {
    "folke/which-key.nvim",
    -- event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 1000
    end,

    config = function()
        -- 当你按下<space> 然后什么都不做时， 它就会自动显示与<space>有关的快捷键了
        local wk = require("which-key")
        wk.register(mappings, opts)
    end
}
