-- https://github.com/nvim-treesitter/nvim-treesitter-context
-- 基于nvim-treesitter的上文文固定插件
-- 它可以将当前函数的函数头固定在neovim界面的前几行，让你知道当前在编辑的是什么类、函数或方法
return {
	"romgrk/nvim-treesitter-context",
	config = function()
		require("treesitter-context").setup({
			enable = true,
			throttle = true,
			max_lines = 0,
			patterns = {
				default = { "class", "function", "method" },
			},
		})
	end,
}
