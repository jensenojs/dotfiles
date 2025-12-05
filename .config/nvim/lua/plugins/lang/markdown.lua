-- consider https://github.com/MeanderingProgrammer/render-markdown.nvim
return {
    "MeanderingProgrammer/render-markdown.nvim",
    -- 只在 markdown 文件时加载
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },

    -- 在插件加载前注册检测命令, 实际执行时再按需 require 内部模块
    init = function()
        vim.api.nvim_create_user_command("RenderMarkdownLatexCheck", function()
            local ok_state, state = pcall(require, "render-markdown.state")
            local ok_env, env = pcall(require, "render-markdown.lib.env")
            if not ok_state or not ok_env then
                vim.notify(
                    "render-markdown.nvim: modules not ready (state/env)",
                    vim.log.levels.WARN,
                    { title = "render-markdown.nvim latex" }
                )
                return
            end

            local cfg = state.get(0)
            local latex = cfg.latex
            if not latex then
                vim.notify(
                    "render-markdown.nvim: latex config not available yet",
                    vim.log.levels.WARN,
                    { title = "render-markdown.nvim latex" }
                )
                return
            end

            local converters = latex.converter or {}
            local cmds = env.commands(converters)

            if not latex.enabled then
                vim.notify("render-markdown.nvim: latex is disabled in config", vim.log.levels.INFO, {
                    title = "render-markdown.nvim latex",
                })
                return
            end

            if #cmds == 0 then
                local names = {}
                for _, name in ipairs(converters) do
                    table.insert(names, name)
                end
                local msg = table.concat({
                    "render-markdown.nvim: no latex converter found",
                    "checked: " .. table.concat(names, ", "),
                    "example: python3 -m pip install --user pylatexenc  (provides latex2text)",
                }, "\n")
                vim.notify(msg, vim.log.levels.WARN, { title = "render-markdown.nvim latex" })
            else
                local msg = "render-markdown.nvim: latex converters found: " .. vim.inspect(cmds)
                vim.notify(msg, vim.log.levels.INFO, { title = "render-markdown.nvim latex" })
            end
        end, { desc = "Check render-markdown.nvim latex converters" })
    end,

    ---@module 'render-markdown'
    ---@type render.md.UserConfig|fun():render.md.UserConfig
    opts = function()
        local api = vim.api

        -- 行级/行内代码块背景全部设为透明, 只保留语法高亮
        api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
        api.nvim_set_hl(0, "RenderMarkdownCodeInline", { bg = "NONE" })

        -- 标题颜色直接用 Treesitter 高亮组控制, 而不是通过插件 overrides
        api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#fb4934", bg = "", bold = true })
        api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#fabd2f", bg = "", bold = true })
        api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#b8bb26", bg = "", bold = true })
        api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#8ec07c", bg = "", bold = true })
        api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#83a598", bg = "", bold = true })
        api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#d3869b", bg = "", bold = true })

        return {
            enabled = true,
            latex = {
                enabled = true,
            },
        }
    end,
}
