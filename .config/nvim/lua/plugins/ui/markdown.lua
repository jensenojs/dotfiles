-- https://github.com/OXY2DEV/markview.nvim
-- 一个轻量的markdown预览器
local bind = require("utils.bind")
local map_cr = bind.map_cr

-- local keymaps = {
--     ["c|<c-m>"] = map_cr("Glow"):with_noremap():with_silent():with_desc("查看markdown预览")
-- }

-- bind.nvim_load_mapping(keymaps)

return {
	"OXY2DEV/markview.nvim",
	lazy = false, -- Recommended
	-- ft = "markdown" -- If you decide to lazy-load anyway

	dependencies = {
		-- You will not need this if you installed the
		-- parsers manually
		-- Or if the parsers are in your $RUNTIMEPATH
		"nvim-treesitter/nvim-treesitter",

		"nvim-tree/nvim-web-devicons",
	},
}
