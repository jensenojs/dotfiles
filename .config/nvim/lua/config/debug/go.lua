-- Go语言调试配置
-- 包含Adapter配置和Configuration配置
return {
	-- Adapter配置：定义如何启动Delve调试器
	adapter = {
		type = "executable",
		command = vim.fn.exepath("dlv"),
		args = { "dap", "-l", "127.0.0.1:38697" },
	},

	-- Configuration配置：定义Go语言的调试场景
	configurations = {
		{
			type = "go",
			name = "Launch File",
			request = "launch",
			program = "${file}",
			mode = "debug",
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Launch File with Args",
			request = "launch",
			program = "${file}",
			args = function()
				return require("utils.dap").input_args()()()
			end,
			mode = "debug",
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Launch Package",
			request = "launch",
			program = "./${relativeFileDirname}",
			mode = "debug",
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Launch Test",
			request = "launch",
			program = "${file}",
			mode = "test",
			stopOnEntry = false,
		},
		{
			type = "go",
			name = "Attach to Process",
			request = "attach",
			processId = require("dap.utils").pick_process,
			mode = "local",
			stopOnEntry = false,
		},
	},
}
