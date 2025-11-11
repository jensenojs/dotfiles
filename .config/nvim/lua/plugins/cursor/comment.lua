-- https://github.com/terrortylor/nvim-comment
-- 注释
return {
    "terrortylor/nvim-comment",
    -- 延迟加载：需要时才加载
    event = "VeryLazy",
    keys = {
        -- 直接定义键位，让 lazy.nvim 处理加载
        { "<C-_>", ":CommentToggle<CR>", mode = { "n", "v" }, desc = "注释/取消注释" },
        { "<C-/>", ":CommentToggle<CR>", mode = { "n", "v" }, desc = "注释/取消注释" },
    },
    opts = function()
        return {
            -- Disable default mappings (we define our own)
            create_mappings = false,
            -- Other default options
            marker_padding = true,
            comment_empty = true,
            comment_empty_trim_whitespace = true,
            -- Hook for ts-context-commentstring integration (可选)
            -- 这用于在 Vue/TypeScript React 等文件中正确处理注释
            -- 如果你不需要可以移除这个 hook
            -- hook = function()
            --     if vim.bo.filetype == "vue" or vim.bo.filetype == "typescriptreact" or vim.bo.filetype == "javascriptreact" then
            --         pcall(function()
            --             require("ts_context_commentstring.internal").update_commentstring()
            --         end)
            --     end
            -- end,
        }
    end,
    config = function(_, opts)
        require("nvim_comment").setup(opts)
    end,
}
