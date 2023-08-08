-- https://github.com/folke/persistence.nvim
-- 自动保存你的session到文件中，在下次打开相同目录/项目时，可以手动加载session恢复之前的工作状态。
return {
    "folke/persistence.nvim",
    -- event = "BufReadPre", -- this will only start session saving when an actual file was opened

    config = function()

        require("persistence").setup()

        vim.keymap.set("n", "<leader>cc", [[<cmd>lua require("persistence").load()<cr>]], {
            desc = '从当前文件夹中恢复session连接'
        })

        vim.keymap.set("n", "<leader>cl", [[<cmd>lua require("persistence").load({ last = true })<cr>]], {
            desc = '恢复上一次session连接'
        })

        vim.keymap.set("n", "<leader>cd", [[<cmd>lua require("persistence").stop()<cr>]], {
            desc = '这次的会话不要在退出时保存'
        })

    end

}
