return {
	"ellisonleao/gruvbox.nvim",
	priority = 1000,

	config = function()
		-- setup must be called before loading the colorscheme
		require("gruvbox").setup({
			transparent_mode = false, -- 启用透明模式
			-- transparent_mode = true -- 启用透明模式
		})
		vim.cmd([[colorscheme gruvbox]])
	end,
}
