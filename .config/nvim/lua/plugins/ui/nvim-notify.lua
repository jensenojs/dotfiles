
-- 可以用它来DEBUG一些内置函数
-- vim.notify('Warning message', vim.log.levels.WARN, { title = 'Warning' })

-- https://github.com/rcarriga/nvim-notify
-- 将各种提示显示为弹窗
return {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		local icons = {
			diagnostics = require("utils.icons").get("diagnostics"),
			ui = require("utils.icons").get("ui"),
		}

		notify.setup({
			---@usage Animation style one of { "fade", "slide", "fade_in_slide_out", "static" }
			stages = "fade",
			---@usage Function called when a new window is opened, use for changing win settings/config
			on_open = function(win)
				vim.api.nvim_set_option_value("winblend", 0, {
					scope = "local",
					win = win,
				})
				vim.api.nvim_win_set_config(win, {
					zindex = 90,
				})
			end,
			on_close = nil,
			timeout = 5000,
			fps = 1,
			render = "default",
			background_colour = "Normal",
			max_width = math.floor(vim.api.nvim_win_get_width(0) / 2),
			max_height = math.floor(vim.api.nvim_win_get_height(0) / 4),
			minimum_width = 70,
			-- ERROR > WARN > INFO > DEBUG > TRACE
			level = "INFO",
			icons = {
				ERROR = icons.diagnostics.Error,
				WARN = icons.diagnostics.Warning,
				INFO = icons.diagnostics.Information,
				DEBUG = icons.ui.Bug,
				TRACE = icons.ui.Pencil,
			},
		})

		vim.notify = notify
	end,
}
