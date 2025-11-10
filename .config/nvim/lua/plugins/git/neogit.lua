-- https://github.com/NeogitOrg/neogit
-- 交互式 Git 界面，替代 LazyGit
return {
    "NeogitOrg/neogit",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim", -- 与 diffview 深度集成
        "nvim-telescope/telescope.nvim", -- 可选: 用于选择 branch/commit
    },
    cmd = "Neogit",
    keys = { {
        "<leader>gs",
        "<cmd>Neogit<cr>",
        desc = "Git Status (Neogit)",
    } },
    opts = {
        -- 打开方式: tab 或 split
        kind = "tab",

        -- 与 diffview 集成(在 Neogit 中可以调用 diffview 查看详情)
        integrations = {
            diffview = true,
        },

        -- 自动刷新状态
        auto_refresh = true,

        -- Commit 编辑器配置
        commit_editor = {
            kind = "tab",
        },

        -- 图标配置
        signs = {
            section = { "", "" },
            item = { "", "" },
            hunk = { "", "" },
        },
    },
}
