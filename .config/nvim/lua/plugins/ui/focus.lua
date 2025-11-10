-- https://github.com/nvim-focus/focus.nvim
-- 自动聚焦与自动调整分屏尺寸
return {
    "nvim-focus/focus.nvim",
    event = "VeryLazy",
    init = function()
        -- 忽略的 filetype/bo 类型: 包含侧边栏与虚拟窗口, 防止 focus 干扰布局
        local ignore_filetypes = {"NvimTree", "DiffviewFiles", "DiffviewFileHistory", "aerial", "TelescopePrompt",
                                  "TelescopeResults", "TelescopePreview"}
        local ignore_buftypes = {"nofile", "prompt", "popup", "quickfix", "terminal"}
        local augroup = vim.api.nvim_create_augroup("FocusDisable", {
            clear = true
        })
        -- 根据 BufType 禁用自动调整
        vim.api.nvim_create_autocmd("WinEnter", {
            group = augroup,
            callback = function()
                if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
                    vim.w.focus_disable = true
                else
                    vim.w.focus_disable = false
                end
            end,
            desc = "根据 BufType 禁用 focus 自动调整"
        })
        -- 根据 FileType 禁用自动调整
        vim.api.nvim_create_autocmd("FileType", {
            group = augroup,
            callback = function()
                if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
                    vim.w.focus_disable = true
                else
                    vim.w.focus_disable = false
                end
            end,
            desc = "根据 FileType 禁用 focus 自动调整"
        })
    end,
    main = "focus",
    opts = {
        excluded_filetypes = {"NvimTree", "DiffviewFiles", "DiffviewFileHistory", "aerial", "TelescopePrompt",
                              "TelescopeResults", "TelescopePreview"},
        excluded_buftypes = {"nofile", "prompt", "popup", "quickfix", "terminal"}
    }
}
