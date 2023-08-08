-- https://github.com/folke/trouble.nvim
-- 快速查看工作区、文件中的LSP警告列表
return {
    "folke/trouble.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        use_diagnostic_signs = true
    },
    config = function()
        require("trouble").setup()
    end
}
