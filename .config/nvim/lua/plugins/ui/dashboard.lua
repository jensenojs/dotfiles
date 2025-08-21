-- https://github.com/nvimdev/dashboard-nvim
-- https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md
return {
	"nvimdev/dashboard-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VimEnter",
	config = function()
		require("dashboard").setup({
			-- config
		})
	end,
}
