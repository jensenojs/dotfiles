-- consider https://github.com/MeanderingProgrammer/render-markdown.nvim
-- https://github.com/OXY2DEV/markview.nvim
-- 一个轻量的markdown预览器
-- For `plugins/markview.lua` users.
-- return {
-- 	"OXY2DEV/markview.nvim",
-- 	event = "BufRead *.md", -- 只在打开markdown文件时加载
-- 	-- lazy = false,
-- 	dependencies = { "nvim-treesitter/nvim-treesitter" },
-- 	opts = function()
-- 		local presets = require("markview.presets")
-- 		return {
-- 			checkboxes = presets.checkboxes.nerd,
-- 			markdown = {
-- 				horizontal_rules = presets.thin,
-- 				tables = presets.double,
-- 				headings = presets.glow_center,
-- 			},
-- 		}
-- 	end,
-- 	keys = {
-- 		{
-- 			"<leader><leader>m",
-- 			"<Cmd>Markview toggle<CR>",
-- 			desc = "toggle markdown preview",
-- 			mode = "n",
-- 			noremap = true,
-- 			silent = true,
-- 		},
-- 	},
-- }

return {
    "MeanderingProgrammer/render-markdown.nvim",
    -- 只在 markdown 文件时加载（节省 ~13ms 启动时间）
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        enabled = true,
        -- 标题颜色配置
        overrides = {
            ["@markup.heading.1.markdown"] = { fg = "#fb4934", bg = "", bold = true },
            ["@markup.heading.2.markdown"] = { fg = "#fabd2f", bg = "", bold = true },
            ["@markup.heading.3.markdown"] = { fg = "#b8bb26", bg = "", bold = true },
            ["@markup.heading.4.markdown"] = { fg = "#8ec07c", bg = "", bold = true },
            ["@markup.heading.5.markdown"] = { fg = "#83a598", bg = "", bold = true },
            ["@markup.heading.6.markdown"] = { fg = "#d3869b", bg = "", bold = true },
        },
    },
}
