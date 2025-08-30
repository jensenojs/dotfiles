-- https://github.com/mfussenegger/nvim-dap
--
-- 调试器的协议
-- https://github.com/mfussenegger/nvim-dap/issues/20
-- https://github.com/nvim-lua/kickstart.nvim/blob/master/lua/kickstart/plugins/debug.lua
-- 配置项应该从这个开始抄起
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cmd = bind.map_cmd

local keymaps = {
	["n|<F5>"] = map_callback(function()
			-- require('telescope').extensions.dap.configurations{}
			require("dap").continue()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("调试: 选择配置文件进入"),

	["n|<F8>"] = map_callback(function()
            require("dap").set_breakpoint(vim.fn.input 'Breakpoint condition: ')
		end)
		:with_noremap()
		:with_silent()
		:with_desc("调试: 添加/删除断点"),

	["n|<F9>"] = map_callback(function()
			require("dap").toggle_breakpoint()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("调试: 添加/删除断点"),

	["n|<F10>"] = map_callback(function()
			require("dap").step_over()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("调试: 单步调试"),

	["n|<F11>"] = map_callback(function()
			require("dap").step_into()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("调试: 跳入"),

	["n|<F12>"] = map_callback(function()
			require("dap").step_out()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("调试: 跳出"),

	-- ["n|<leader>lp"] = map_callback(function()
	--     require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
	-- end):with_noremap():with_silent():with_desc("调试: 跳出"),

	-- ["n|<leader>dr"] = map_callback(function()
	--     require('dap').repl.open()
	-- end):with_noremap():with_silent():with_desc("调试: 跳出"),

	-- ["n|<leader>dl"] = map_callback(function()
	--     require('dap').run_last()
	-- end):with_noremap():with_silent():with_desc("调试: 跳出"),

	-- ["nv|<leader>lp"] = map_callback(function()
	--     require('dap.ui.widgets').hover()
	-- end):with_noremap():with_silent():with_desc("调试: 跳出"),

	-- ["nv|<leader>dp"] = map_callback(function()
	--     require('dap.ui.widgets').preview()
	-- end):with_noremap():with_silent():with_desc("调试: 跳出"),

	-- ["nv|<leader>df"] = map_callback(function()
	--     local widgets = require('dap.ui.widgets')
	--     widgets.centered_float(widgets.frames)
	-- end):with_noremap():with_silent():with_desc("调试: 跳出"),

	-- ["nv|<leader>ds"] = map_callback(function()
	--     local widgets = require('dap.ui.widgets')
	--     widgets.centered_float(widgets.scopes)
	-- end):with_noremap():with_silent():with_desc("调试: 跳出")
}

bind.nvim_load_mapping(keymaps)

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
return {
	"mfussenegger/nvim-dap",
	dependencies = {
        -- Creates a beautiful debugger UI
		"rcarriga/nvim-dap-ui",

		"theHamsta/nvim-dap-virtual-text",

        -- Add syntax highlighting to the nvim-dap REPL buffer using treesitter.
		"LiadOz/nvim-dap-repl-highlights",

        -- Installs the debug adapters for you
		"williamboman/mason.nvim",
		"jay-babu/mason-nvim-dap.nvim",

		-- 
		'leoluz/nvim-dap-go',
	},

	config = function()
		local icons = {
			dap = require("utils.icons").get("dap"),
		}

		-- 设置iconƒ
		vim.fn.sign_define("DapBreakpoint", {
			text = icons.dap.Breakpoint,
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "",
		})
		vim.fn.sign_define("DapBreakpointCondition", {
			text = icons.dap.BreakpointCondition,
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "",
		})
		vim.fn.sign_define("DapStopped", {
			text = icons.dap.Stopped,
			texthl = "DapStopped",
			linehl = "",
			numhl = "",
		})
		vim.fn.sign_define("DapBreakpointRejected", {
			text = icons.dap.BreakpointRejected,
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "",
		})
		vim.fn.sign_define("DapLogPoint", {
			text = icons.dap.LogPoint,
			texthl = "DapLogPoint",
			linehl = "",
			numhl = "",
		})

		---A handler to setup all clients defined under `plugins/dap/clients/*.lua`
		---@param config table
		local function mason_dap_handler(config)
			local dap_name = config.name
			ok, custom_handler = pcall(require, "plugins.ide.dap.clients." .. dap_name)
			-- vim.notify(string.format("dap_name is %s ", dap_name), vim.log.levels.INFO, { title = "nvim-dap" })
			if not ok then
				-- Default to use factory config for clients(s) that doesn't include a spec
				mason_dap.default_setup(config)
				return
			elseif type(custom_handler) == "function" then
				-- Case where the protocol requires its own setup
				-- Make sure to set
				-- * dap.adpaters.<dap_name> = { your config }
				-- * dap.configurations.<lang> = { your config }
				-- See `codelldb.lua` for a concrete example.
				custom_handler(config)
			else
				vim.notify(
					string.format(
						"Failed to setup [%s].\n\nClient definition under `plugins/dap/clients` must return\na fun(opts) (got '%s' instead)",
						config.name,
						type(custom_handler)
					),
					vim.log.levels.ERROR,
					{
						title = "nvim-dap",
					}
				)
			end
		end

		local status, mason_dap = pcall(require, "mason-nvim-dap")
		if not status then
			vim.notify("not found mason-nvim-dap")
			return
		end

		-- require("utils").load_plugin("mason-nvim-dap", {
		mason_dap.setup({
			-- ensure_installed = require("utils.mason-list").get("dap", true),
			ensure_installed = { "codelldb", "python", "delve" },
			automatic_installation = true,
			handlers = { mason_dap_handler },
		})
	end,
}
