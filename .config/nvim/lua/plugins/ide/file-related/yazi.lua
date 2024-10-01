-- https://github.com/mikavilpas/yazi.nvim
-- 用yazi取代nvim-tree

local bind = require("utils.bind")
local map_cmd = bind.map_cmd

local keymaps = {
	["n|<leader>y"] = map_cmd(":Yazi <cr>"):with_noremap():with_silent():with_desc("在当前buffer路径下打开Yazi"),
	["n|<leader>Y"] = map_cmd(":Yazi cwd<cr>"):with_noremap():with_silent():with_desc("在当前nvim的工作文件夹下打开Yazi"),
}

bind.nvim_load_mapping(keymaps)

return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	opts = {
		-- if you want to open yazi instead of netrw, see below for more info
		open_for_directories = false,
		keymaps = {
			show_help = "<f1>",
		},
	},
}
