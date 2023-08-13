-- https://github.com/nvim-lualine/lualine.nvim
-- 只是一个美化的插件
return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require("lualine").setup({
            opt = {
                theme = "gruxbox_light"
            },
            sections = {
                lualine_x = {"aerial"},
            }
        })
    end
}
