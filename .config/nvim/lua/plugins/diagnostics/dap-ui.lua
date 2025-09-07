-- https://github.com/rcarriga/nvim-dap-ui
-- 调试界面的配置
local M = {}

-- 调试期间的键位映射管理
local debug_keymaps_loaded = false

-- 加载调试期间的键位映射
function M.load_debug_keymaps()
	if debug_keymaps_loaded then
		return
	end

	local bind = require("utils.bind")
	local map_cmd = bind.map_cmd

	local debug_keymaps = {
		["nv|K"] = map_cmd("<Cmd>lua require('dapui').eval()<CR>")
			:with_noremap()
			:with_nowait()
			:with_desc("Debug: Evaluate expression under cursor"),
	}

	bind.nvim_load_mapping(debug_keymaps)
	debug_keymaps_loaded = true
end

-- 清理调试期间的键位映射
function M.clear_debug_keymaps()
	if not debug_keymaps_loaded then
		return
	end

	-- 清理调试键位映射
	pcall(vim.keymap.del, "n", "K")
	pcall(vim.keymap.del, "v", "K")

	debug_keymaps_loaded = false
end

return {
	"rcarriga/nvim-dap-ui",
	event = "VeryLazy",
	dependencies = { "nvim-neotest/nvim-nio" },

	-- config = function()
	opts = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local icons = {}

		-- 尝试加载图标
		local ok, icon_module = pcall(require, "utils.icons")
		if ok then
			icons = {
				ui = icon_module.get("ui"),
				dap = icon_module.get("dap"),
			}
		end

		-- 配置DAP UI
		dapui.setup({
			force_buffers = true,
			icons = {
				expanded = icons.ui and icons.ui.ArrowOpen or "v",
				collapsed = icons.ui and icons.ui.ArrowClosed or ">",
				current_frame = icons.ui and icons.ui.Indicator or "->",
			},
			mappings = {
				-- Use a table to apply multiple mappings
				edit = "e",
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				repl = "r",
				toggle = "t",
			},
			controls = {
				enabled = true,
				-- Display controls in this session
				element = "repl",
				icons = {
					pause = icons.dap and icons.dap.Pause or "⏸",
					play = icons.dap and icons.dap.Play or "▶",
					step_into = icons.dap and icons.dap.StepInto or "⏎",
					step_over = icons.dap and icons.dap.StepOver or "⏭",
					step_out = icons.dap and icons.dap.StepOut or "⏮",
					step_back = icons.dap and icons.dap.StepBack or "b",
					run_last = icons.dap and icons.dap.RunLast or "▶▶",
					terminate = icons.dap and icons.dap.Terminate or "⏹",
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			render = {
				indent = 1,
				max_value_lines = 85,
			},
		})

		-- 调试会话生命周期管理
		dap.listeners.after.event_initialized["dapui_config"] = function()
			M.load_debug_keymaps()
			-- 调试开始时禁用focus插件
			local ok_focus, focus = pcall(require, "focus")
			if ok_focus then
				focus.setup({
					enable = false,
				})
			end
			dapui.open({
				reset = true,
			})
		end

		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
			-- 恢复focus插件
			local ok_focus, focus = pcall(require, "focus")
			if ok_focus then
				focus.setup({
					enable = true,
				})
			end
			M.clear_debug_keymaps()
		end

		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
			local ok_focus, focus = pcall(require, "focus")
			if ok_focus then
				focus.setup({
					enable = true,
				})
			end
			M.clear_debug_keymaps()
		end

		-- 配置断点图标
		vim.fn.sign_define("DapBreakpoint", {
			text = icons.dap and icons.dap.Breakpoint or "B",
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapBreakpointCondition", {
			text = icons.dap and icons.dap.BreakpointCondition or "C",
			texthl = "DapBreakpoint",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapStopped", {
			text = icons.dap and icons.dap.Stopped or "->",
			texthl = "DapStopped",
			linehl = "",
			numhl = "",
		})
	end,
}
