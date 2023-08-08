-- https://github.com/zbirenbaum/neodim
-- 将没有使用到的变量进行暗淡处理
return {
    "zbirenbaum/neodim",
    lazy = true,
    event = "LspAttach",
    config = function()
        require("neodim").setup({
            alpha = 0.75,
            blend_color = "#000000",
            update_in_insert = {
                enable = true,
                delay = 100
            },
            hide = {
                virtual_text = true,
                signs = false,
                underline = false
            }
        })
    end
}
