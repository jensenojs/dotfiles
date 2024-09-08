-- https://github.com/ibhagwan/fzf-lua
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd

local keymaps = {
	-- ["n|<leader>b"] = map_cr("FzfLua buffers"):with_noremap():with_silent():with_desc("打开缓冲区列表"),
}

bind.nvim_load_mapping(keymaps)

return {
	-- "ibhagwan/fzf-lua",
	-- -- optional for icon support
	-- dependencies = { "nvim-tree/nvim-web-devicons" },
	-- config = function()
	-- 	-- calling `setup` is optional for customization
	-- 	require("fzf-lua").setup({})
	-- end,
}
