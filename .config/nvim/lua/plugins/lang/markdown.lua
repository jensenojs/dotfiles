-- consider https://github.com/MeanderingProgrammer/render-markdown.nvim
return {
    "MeanderingProgrammer/render-markdown.nvim",
    -- 只在 markdown 文件时加载
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig|fun():render.md.UserConfig
    opts = function()
        local api = vim.api

        -- 行级/行内代码块背景全部设为透明, 只保留语法高亮
        api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
        api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "NONE" })


        return {
            enabled = true,
            latex = {
                enabled = false,
            },
            -- 标题颜色配置
            overrides = {
                ["@markup.heading.1.markdown"] = { fg = "#fb4934", bg = "", bold = true },
                ["@markup.heading.2.markdown"] = { fg = "#fabd2f", bg = "", bold = true },
                ["@markup.heading.3.markdown"] = { fg = "#b8bb26", bg = "", bold = true },
                ["@markup.heading.4.markdown"] = { fg = "#8ec07c", bg = "", bold = true },
                ["@markup.heading.5.markdown"] = { fg = "#83a598", bg = "", bold = true },
                ["@markup.heading.6.markdown"] = { fg = "#d3869b", bg = "", bold = true },
            },
        }
    end,
}
