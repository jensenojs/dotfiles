-- https://github.com/mikavilpas/yazi.nvim
-- 用yazi取代nvim-tree

local bind = require("utils.bind")
local map_cr = bind.map_cr

local keymaps = {
	-- ["n|<leader>-"] = map_cr("Oil"):with_noremap():with_silent():with_desc("打开Oil"),
}

bind.nvim_load_mapping(keymaps)

return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	keys = {
		-- 👇 in this section, choose your own keymappings!
		{
			"<Tab>",
			"<cmd>Yazi toggle<cr>",
			desc = "Open yazi at the current file",
		},
		{
			-- Open in the current working directory
			"<leader><Tab>",
			"<cmd>Yazi cwd<cr>",
			desc = "Open the file manager in nvim's working directory",
		},
	},
	---@type YaziConfig
	opts = {
		-- if you want to open yazi instead of netrw, see below for more info
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
		},
	},
}
