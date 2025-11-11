-- https://github.com/folke/todo-comments.nvim
return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- 改为懒加载，只在需要时加载
    event = "VeryLazy", -- 或者使用 cmd = {"TodoTelescope", "TodoLocList", "TodoQuickFix"}
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
}
