-- https://github.com/abecodes/tabout.nvim
-- 在Insert模式下，按<Tab>可以跳出括号
return {
    "abecodes/tabout.nvim",
    lazy = true,
    event = {"InsertEnter"},
    config = function()
        require("tabout").setup({
            -- 这个插件的功能被集成在了coc-nvim中，所以禁用掉了默认的配置
            tabkey = "",
            backwards_tabkey = "",

            exclude = {"qf", "NvimTree", "toggleterm", "TelescopePrompt", "alpha", "netrw"}
        })
    end
}
