-- https://github.com/mfussenegger/nvim-dap
-- DAP核心插件配置
return {
	"mfussenegger/nvim-dap",
	event = "VeryLazy",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
		"nvim-neotest/nvim-nio",
		"LiadOz/nvim-dap-repl-highlights",
		"leoluz/nvim-dap-go",
	},
	keys = function(_, keys)
		local dap = require("dap")
		local dapui = require("dapui")
		return {
			{ "<F5>", dap.continue, desc = "Debug: Start/Continue" },
			{ "<F7>", dapui.toggle, desc = "Debug: See last session result." },
			{ "<F9>", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint" },
			{ "<F10>", dap.step_over, desc = "Debug: Step Over" },
			{ "<F11>", dap.step_into, desc = "Debug: Step Into" },
			{ "<F12>", dap.step_out, desc = "Debug: Step Out" },
			-- { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
			-- { '<leader>B>', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Debug: Set Breakpoint', },
			{ "<leader>dc", dap.continue, desc = "Debug: Continue" },
			{ "<leader>dr", dap.repl.open, desc = "Debug: Open REPL" },
			{ "<leader>dt", dap.terminate, desc = "Debug: Terminate" },
		}
	end,

	config = function()
		local dap = require("dap")

		-- 配置调试适配器和语言配置
		require("config.debug").setup()

		-- 配置Go语言调试支持
		local ok_go, dap_go = pcall(require, "dap-go")
		if ok_go then
			dap_go.setup({
				delve = {
					detached = vim.fn.has("win32") == 0,
				},
			})
		end
	end,
}
