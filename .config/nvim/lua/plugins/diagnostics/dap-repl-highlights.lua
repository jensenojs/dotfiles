-- https://github.com/LiadOz/nvim-dap-repl-highlights
-- DAP REPL语法高亮插件配置
-- 注意: 需要 treesitter dap_repl parser，确保在 treesitter.lua 的 ensure_installed 中包含 "dap_repl"
return {
	"LiadOz/nvim-dap-repl-highlights",
	dependencies = { 
		"nvim-treesitter/nvim-treesitter",
		"mfussenegger/nvim-dap",
	},
	ft = "dap_repl",  -- 只在 DAP REPL buffer 类型时加载
	opts = function()
		-- 确保 treesitter parser 已安装（main 分支使用新 API）
		local ok, parsers = pcall(require, "nvim-treesitter.parsers")
		if ok then
			local has_parser = parsers.has_parser and parsers.has_parser("dap_repl")
			if not has_parser then
				-- 尝试使用 get_parser_configs 检查
				local ok_configs, configs = pcall(require, "nvim-treesitter.parsers")
				if ok_configs and configs.get_parser_configs then
					local parser_configs = configs.get_parser_configs()
					if not parser_configs.dap_repl then
						vim.notify("dap_repl parser 未找到，请运行 :TSInstall dap_repl", vim.log.levels.WARN)
						return
					end
				end
			end
		end
		
		-- 设置插件
		require("nvim-dap-repl-highlights").setup()
	end,
}
