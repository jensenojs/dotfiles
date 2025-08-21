-- https://github.com/RRethy/nvim-treesitter-textsubjects
-- 根据光标位置启发式的决定要选中什么textobject, 像treesitter-textobjects会有一些认知负担
--
-- 使用方式：快捷键使用(以v选中模式举例)
-- v.：根据光标位置, 智能选择
-- v,：选中上一次选中的范围
-- v;：选中容器外围
-- vi;：选中容器内
-- <leader>+a :
--
-- 等合适的时候才能给这个快捷键加上docs
-- https://github.com/RRethy/nvim-treesitter-textsubjects/pull/36
return {
	"RRethy/nvim-treesitter-textsubjects",
	event = { "User FileOpened" },
	
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		require("nvim-treesitter.configs").setup({
			textsubjects = {
				enable = true,
				prev_selection = ",",
				keymaps = {
					["."] = "textsubjects-smart",
					[";"] = "textsubjects-container-outer",
					["i;"] = "textsubjects-container-inner",
				},
				include_surrounding_whilespace = false,
			},
		})
	end,
}
