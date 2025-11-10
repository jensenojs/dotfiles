-- https://github.com/Weissle/persistent-breakpoints.nvim
-- 断点持久化插件：只在可调试的编程语言文件类型时加载，避免打开文档时加载整个 DAP 栈
return {
    "Weissle/persistent-breakpoints.nvim",
    -- 只在可调试的语言文件类型时加载（节省 ~23ms 启动时间）
    ft = { "go", "python", "rust", "c", "cpp", "java", "lua", "javascript", "typescript" },
    dependencies = { "mfussenegger/nvim-dap" },
    main = "persistent-breakpoints",
    opts = {
        load_breakpoints_event = { "BufReadPost" },
        -- 如使用会话类插件且断点未恢复, 可尝试启用
        always_reload = true,
    },
}
