-- https://github.com/akinsho/bufferline.nvim
--
local bind = require("utils.bind")
local map_cr = bind.map_cr

-- vim.keymap.set("n", "bp", ":BufferLineCyclePrev<CR>")
-- vim.keymap.set("n", "bn", ":BufferLineCycleNext<CR>")

-- local keymaps = {
-- ["n|<F9>"] = map_cr():with_noremap():with_silent():with_desc("调试: 添加/删除断点")
-- }

-- bind.nvim_load_mapping(keymaps)

local icons = {
	ui = require("utils.icons").get("ui"),
}

return {
	"akinsho/bufferline.nvim",
	-- 文件的光标
	config = function()
		require("bufferline").setup({
			options = {
				-- switch bufferline to tabline
				mode = "tabs",
				number = nil,
				modified_icon = icons.ui.Modified,
				buffer_close_icon = icons.ui.Close,
				left_trunc_marker = icons.ui.Left,
				right_trunc_marker = icons.ui.Right,
				max_name_length = 20,
				max_prefix_length = 13,
				tab_size = 20,
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				enforce_regular_tabs = false,
				persist_buffer_sort = true,
				always_show_bufferline = true,
				separator_style = "slope",

				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},

				-- get an indicator in the bufferline for a given tab if it has any errors
				diagnostics = "coc",

				-- 不要占用NvimTree和aerial的界面
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						highlight = "Directory",
						padding = 1,
					},
					{
						filetype = "aerial",
						text = "Outline",
						text_align = "center",
						padding = 0,
					},
				},
			},
		})
	end,
}
