-- https://github.com/xiyaowong/transparent.nvim
return {
    "xiyaowong/transparent.nvim",
    lazy = false,
    opts = {
        enable = true,
        extra = {
            -- 窗口透明度
            window = 0.9,
            -- 颜色透明度
            color = 0.9,
        },
        -- extra_groups = {
        --     -- 浮动窗口相关
        --     "NormalFloat", "FloatBorder", "FloatTitle", "Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb",
        -- },
        on_clear = function()
            local api = vim.api

            local function get_fg(group)
                local ok, hl = pcall(api.nvim_get_hl, 0, { name = group, link = false })
                if ok and hl and hl.fg then
                    return hl.fg
                end
            end

            local function link(name, target)
                if vim.fn.hlexists(target) == 1 then
                    api.nvim_set_hl(0, name, { link = target })
                end
            end

            local function set(name, spec)
                api.nvim_set_hl(0, name, spec)
            end

            local normal_fg = get_fg("Normal")
            local accent = get_fg("String") or normal_fg
            local info = get_fg("DiagnosticInfo") or accent
            local hint = get_fg("DiagnosticHint") or info
            local ok_fg = get_fg("DiagnosticOk") or accent
            local warn_fg = get_fg("DiagnosticWarn") or accent
            local error_fg = get_fg("DiagnosticError") or normal_fg

            link("AvanteSidebarNormal", "Normal")
            link("AvanteSidebarWinSeparator", "WinSeparator")
            link("AvanteSidebarWinHorizontalSeparator", "WinSeparator")
            link("AvanteCommentFg", "Comment")

            if normal_fg then
                set("AvanteTitle", { fg = accent or normal_fg, bg = "NONE", bold = true })
                set("AvanteSubtitle", { fg = info or accent or normal_fg, bg = "NONE", bold = true })
                set("AvanteThirdTitle", { fg = warn_fg or info or normal_fg, bg = "NONE" })
                set("AvanteConfirmTitle", { fg = error_fg or normal_fg, bg = "NONE", bold = true })

                set("AvanteButtonDefault", { fg = normal_fg, bg = "NONE" })
                set("AvanteButtonDefaultHover", { fg = accent or normal_fg, bg = "NONE" })
                set("AvanteButtonPrimary", { fg = accent or normal_fg, bg = "NONE" })
                set("AvanteButtonPrimaryHover", { fg = accent or normal_fg, bg = "NONE", bold = true })
                set("AvanteButtonDanger", { fg = error_fg or normal_fg, bg = "NONE" })
                set("AvanteButtonDangerHover", { fg = error_fg or normal_fg, bg = "NONE", bold = true })

                set("AvanteStateSpinnerGenerating", { fg = info or accent or normal_fg, bg = "NONE" })
                set("AvanteStateSpinnerToolCalling", { fg = hint or info or normal_fg, bg = "NONE" })
                set("AvanteStateSpinnerFailed", { fg = error_fg or normal_fg, bg = "NONE" })
                set("AvanteStateSpinnerSucceeded", { fg = ok_fg or accent or normal_fg, bg = "NONE" })
                set("AvanteStateSpinnerSearching", { fg = hint or info or normal_fg, bg = "NONE" })
                set("AvanteStateSpinnerThinking", { fg = hint or info or normal_fg, bg = "NONE" })
                set("AvanteStateSpinnerCompacting", { fg = hint or info or normal_fg, bg = "NONE" })

                set("AvanteTaskRunning", { fg = hint or info or normal_fg, bg = "NONE" })
                set("AvanteTaskCompleted", { fg = ok_fg or accent or normal_fg, bg = "NONE" })
                set("AvanteTaskFailed", { fg = error_fg or normal_fg, bg = "NONE" })
                set("AvanteThinking", { fg = hint or info or normal_fg, bg = "NONE" })
            end
        end,
    },
    config = function(_, opts)
        require("transparent").setup(opts)
        require("transparent").clear_prefix("BufferLine")
        require("transparent").clear_prefix("lualine")
        require("transparent").clear_prefix("dropbar")
    end,
}
