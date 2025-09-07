-- C 语言调试配置（基于 CodeLLDB）
-- adapter 与 configurations 的 `type` 使用 "codelldb"，与 nvim-dap 的匹配规则一致
return {
	-- Adapter 配置：启动 CodeLLDB 调试服务器，使用动态端口
	adapter = {
		type = "server",
		port = "${port}",
		executable = {
			command = vim.fn.exepath("codelldb"),
			args = { "--port", "${port}" },
		},
	},

	-- C 的调试场景
	configurations = {
		{
			type = "codelldb",
			name = "Launch Executable",
			request = "launch",
			program = require("utils.dap").fn.input_exec_path(),
			args = require("utils.dap").fn.input_args(),
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			runInTerminal = false,
		},
		{
			type = "codelldb",
			name = "Attach to Process",
			request = "attach",
			program = require("utils.dap").fn.input_exec_path(),
			cwd = "${workspaceFolder}",
			processId = require("dap.utils").pick_process,
		},
	},
}
