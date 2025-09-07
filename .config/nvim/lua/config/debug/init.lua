-- 调试配置初始化文件
-- 使用表驱动方式注册所有语言的Adapter和Configuration
local M = {}

function M.setup()
	local dap = require("dap")
	local registry = require("mason-registry")

	-- 定义支持的语言及其配置文件
	local language_configs = {
		go = {
			module = "config.debug.go",
			debugger = "delve",
		},
		python = {
			module = "config.debug.python",
			debugger = "debugpy",
		},
		cpp = {
			module = "config.debug.cpp",
			debugger = "codelldb",
		},
	}

	-- 表驱动方式注册所有语言的配置
	for lang, config_info in pairs(language_configs) do
		-- 检查调试器是否已安装
		if registry.is_installed(config_info.debugger) then
			-- 加载语言配置
			local ok, lang_config = pcall(require, config_info.module)
			if ok and lang_config then
				-- 注册Adapter配置
				if lang_config.adapter then
					dap.adapters[lang] = lang_config.adapter
				end

				-- 注册Configuration配置
				if lang_config.configurations then
					dap.configurations[lang] = lang_config.configurations

					-- 为相关语言也注册相同的配置（如C++配置也用于C和Rust）
					if lang == "cpp" then
						dap.configurations.c = lang_config.configurations
						dap.configurations.rust = lang_config.configurations
					end
				end
			else
				vim.notify("Failed to load debug configuration for " .. lang, vim.log.levels.WARN, {
					title = "Debug Config",
				})
			end
		else
			vim.notify(
				config_info.debugger
					.. " debugger not installed for "
					.. lang
					.. ". Please run :MasonInstall "
					.. config_info.debugger,
				vim.log.levels.WARN,
				{
					title = "Debug Config",
				}
			)
		end
	end

	-- 设置UI生命周期管理
	M.setup_ui_lifecycle(dap) -- 传递dap实例
end

function M.setup_ui_lifecycle(dap) -- 接收dap参数
	local dapui_status, dapui = pcall(require, "dapui")
	if not dapui_status then
		return
	end

	-- 调试会话开始时打开UI
	dap.listeners.after.event_initialized["dapui"] = function()
		dapui.open()
	end

	-- 调试会话结束时关闭UI
	dap.listeners.before.event_terminated["dapui"] = function()
		dapui.close()
	end

	-- 调试会话退出时关闭UI
	dap.listeners.before.event_exited["dapui"] = function()
		dapui.close()
	end
end

return M
