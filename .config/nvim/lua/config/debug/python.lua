-- Python语言调试配置
-- 包含Adapter配置和Configuration配置
return {
	-- Adapter配置：定义如何启动debugpy调试器
	adapter = {
		type = "executable",
		command = "python3",
		args = { "-m", "debugpy.adapter" },
	},

	-- Configuration配置：定义Python语言的调试场景
	configurations = {
		{
			type = "python",
			name = "Launch File",
			request = "launch",
			program = function()
				return require("utils.dap").input_file_path()()()
			end,
			pythonPath = function()
				-- Handle virtual environments
				local venv = os.getenv("VIRTUAL_ENV")
				if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
					return venv .. "/bin/python"
				else
					return "python3"
				end
			end,
		},
		{
			type = "python",
			name = "Launch File with Args",
			request = "launch",
			program = function()
				return require("utils.dap").input_file_path()()()
			end,
			args = function()
				return require("utils.dap").input_args()()()
			end,
			pythonPath = function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
					return venv .. "/bin/python"
				else
					return "python3"
				end
			end,
		},
		{
			type = "python",
			name = "Launch Module",
			request = "launch",
			module = function()
				return vim.fn.input("Module to debug: ")
			end,
			pythonPath = function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
					return venv .. "/bin/python"
				else
					return "python3"
				end
			end,
		},
	},
}
