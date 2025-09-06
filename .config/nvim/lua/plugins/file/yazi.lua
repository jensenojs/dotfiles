-- https://github.com/mikavilpas/yazi.nvim
return {
	"mikavilpas/yazi.nvim",
	version = "*",
	event = "VeryLazy",
	dependencies = {
		{ "nvim-lua/plenary.nvim", lazy = true },
		"MagicDuck/grug-far.nvim",
	},
	opts = {
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
		},
	},
	keys = {
		{
			"<leader>y",
			mode = { "n", "v" },
			"<cmd>Yazi<cr>",
			desc = "Yazi : Open yazi at the current file",
		},
		-- no need for open in the current working directory
		{
			"<leader>Y",
			mode = { "n", "v" },
			"<cmd>Yazi cwd<cr>",
			desc = "Yazi : Open yazi at the current working space",
		},
	},
}
