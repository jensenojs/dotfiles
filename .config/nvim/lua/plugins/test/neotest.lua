-- https://github.com/nvim-neotest/neotest

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		{ "fredrikaverpil/neotest-golang", version = "*" },
		"alfaix/neotest-gtest",
		"nvim-neotest/neotest-python",
	},
	keys = {
		-- 运行测试
		{ "<leader>tn", function() require("neotest").run.run() end, desc = "运行最近的测试" },
		{ "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "运行当前文件" },
		{ "<leader>tA", function() require("neotest").run.run({ suite = true }) end, desc = "运行所有测试" },
		{ "<leader>tl", function() require("neotest").run.run_last() end, desc = "重新运行上次测试" },
		{ "<leader>ts", function() require("neotest").run.stop() end, desc = "停止测试" },
		
		-- 调试测试
		{ "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "调试最近的测试" },
		{ "<leader>tD", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "调试当前文件" },
		
		-- 输出和摘要
		{ "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "显示测试输出" },
		{ "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "切换输出面板" },
		{ "<leader>tS", function() require("neotest").summary.toggle() end, desc = "切换测试摘要" },
		
		-- 跳转
		{ "[t", function() require("neotest").jump.prev() end, desc = "跳转到上一个测试" },
		{ "]t", function() require("neotest").jump.next() end, desc = "跳转到下一个测试" },
		{ "[T", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "跳转到上一个失败测试" },
		{ "]T", function() require("neotest").jump.next({ status = "failed" }) end, desc = "跳转到下一个失败测试" },
		
		-- 监视
		{ "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "监视当前文件" },
	},
	opts = function()
		-- 从统一图标源获取测试图标
		local icons = require("utils.icons").get("test")
		
		require("neotest").setup({
			-- 日志级别：生产环境用 WARN，调试时用 DEBUG
			log_level = vim.log.levels.WARN,
			
			adapters = {
				require("neotest-golang")({
					go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
					dap_go_enabled = true,
					runner = "go",
				}),
				require("neotest-gtest"),
				require("neotest-python")({
					runner = "pytest",
					python = function()
						-- 自动检测虚拟环境
						local venv = vim.env.VIRTUAL_ENV
						if venv then
							return venv .. "/bin/python"
						end
						return vim.fn.executable("python3") == 1 and "python3" or "python"
					end,
				}),
			},
			
			-- 测试发现配置
			discovery = {
				enabled = true,
				concurrent = 1,
			},
			
			-- 状态显示
			status = {
				virtual_text = true,
				signs = true,
			},
			
			-- 输出配置
			output = {
				open_on_run = true,
				enter = false,  -- 运行后不自动进入输出窗口
			},
			
			-- 快速修复列表
			quickfix = {
				enabled = true,
				open = function()
					vim.cmd("copen")
				end,
			},
			
			-- 图标配置（从 utils/icons.lua 获取）
			icons = {
				passed = icons.passed,
				running = icons.running,
				failed = icons.failed,
				skipped = icons.skipped,
				unknown = icons.unknown,
				watching = icons.watching,
				running_animated = icons.running_animated,
			},
		})
	end,
}
