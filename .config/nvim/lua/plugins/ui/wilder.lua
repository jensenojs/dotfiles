-- https://github.com/gelguy/wilder.nvim
-- wilder.nvim adds new features and capabilities to wildmenu.
-- Automatically provides suggestions as you type
--  : cmdline support - autocomplete commands, expressions, filenames, etc.
--  / search support - get search suggestions from the current buffer
-- High level of customisation
--  build your own custom pipeline to suit your needs
--  customisable look and appearance
return {
	"gelguy/wilder.nvim",
	build = ":UpdateRemotePlugins",
	config = function()
		local wilder = require("wilder")

		wilder.setup({
			modes = { ":", "/", "?" },
		})

		-- draw the popupmenu in the middle of the screen
		-- 在按下: 时在屏幕中间显示命令
		wilder.set_option(
			"renderer",
			wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
				-- 'single', 'double', 'rounded' or 'solid'
				-- can also be a list of 8 characters, see :h wilder#popupmenu_palette_theme() for more details
				-- border = 'rounded',
				-- max_height = '75%', -- max height of the palette
				-- min_height = 0, -- set to the same as 'max_height' for a fixed height window
				prompt_position = "top", -- 'top' or 'bottom' to set the location of the prompt
				reverse = 0, -- set to 1 to reverse the order of the list, use in combination with 'prompt_position'
			}))
		)

		-- use fuzzy matching instead of substring matching:
		-- 也许搜索起来会更好一些.?
		wilder.set_option("pipeline", {
			wilder.branch(
				wilder.cmdline_pipeline({
					-- sets the language to use, 'vim' and 'python' are supported
					language = "python",
					-- 0 turns off fuzzy matching
					-- 1 turns on fuzzy matching
					-- 2 partial fuzzy matching (match does not have to begin with the same first letter)
					fuzzy = 1,
				}),
				wilder.python_search_pipeline({
					-- can be set to wilder#python_fuzzy_delimiter_pattern() for stricter fuzzy matching
					pattern = wilder.python_fuzzy_pattern(),
					-- omit to get results in the order they appear in the buffer
					sorter = wilder.python_difflib_sorter(),
					-- can be set to 're2' for performance, requires pyre2 to be installed
					-- see :h wilder#python_search() for more details
					engine = "re",
				})
			),
		})
	end,
}
