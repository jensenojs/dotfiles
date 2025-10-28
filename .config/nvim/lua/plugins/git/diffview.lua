-- https://github.com/sindrets/diffview.nvim
-- 专业的 Diff 可视化工具，支持查看 commit 历史和每个 commit 的具体修改
-- https://github.com/sindrets/diffview.nvim/blob/main/doc/diffview.txt
-- https://github.com/sindrets/diffview.nvim?tab=readme-ov-file#configuration

return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
	keys = {
		{
			"<leader>gf",
			"<cmd>DiffviewFileHistory %<cr>",
			desc = "当前文件的 Commit 历史",
		},
		{
			"<leader>gF",
			"<cmd>DiffviewFileHistory<cr>",
			desc = "整个仓库的 Commit 历史",
		}, -- 查看选中行的演变历史
		{
			"<leader>gl",
			"<cmd>'<,'>DiffviewFileHistory<cr>",
			mode = "v",
			desc = "选中行的历史",
		}, -- 对比当前改动
		{
			"<leader>gd",
			"<cmd>DiffviewOpen<cr>",
			desc = "查看未提交的改动",
		}, -- 查看特定 commit 的详情
		{
			"<leader>gc",
			function()
				local commit = vim.fn.input("Commit hash: ")
				if commit ~= "" then
					vim.cmd("DiffviewOpen " .. commit .. "^!")
				end
			end,
			desc = "查看某个 Commit 的详情",
		},
	},
	
	opts = {
		enhanced_diff_hl = true, -- 更好的 diff 高亮

		view = {
			-- 默认布局: 左右对比
			default = {
				layout = "diff2_horizontal",
			},
			-- 合并冲突: 三方对比
			merge_tool = {
				layout = "diff3_horizontal",
				disable_diagnostics = true,
			},
			-- 文件历史布局: 左边 commit 列表，右边 diff
			file_history = {
				layout = "diff2_horizontal",
			},
		},

		-- https://github.com/tsakirist/dotfiles/blob/master/nvim/lua/tt/_plugins/git/diffview.lua
		file_panel = {
			listing_style = "tree", -- 文件列表使用树形结构
			tree_options = {
				flatten_dirs = true,
				folder_statuses = "only_folded",
			},
			win_config = {
				position = "left",
				width = 35,
			},
		},

		file_history_panel = {
			log_options = {
				git = {
					single_file = {
						-- 每个文件显示最近 256 个 commit
						max_count = 256,
					},
					multi_file = {
						-- 整个仓库显示最近 128 个 commit
						max_count = 128,
					},
				},
			},
			win_config = {
				position = "left", -- Commit 列表在左边
				width = 35,
			},
		},

		keymaps = {
			view = {
				-- ========== 在 diff 视图(右侧面板)中的快捷键 ==========
				["q"] = "<cmd>DiffviewClose<cr>",
			},
			file_panel = {
				-- ========== 在文件列表(左侧面板)中的快捷键 ==========
				["q"] = "<cmd>DiffviewClose<cr>",
			},
			file_history_panel = {
				-- ========== 在 commit 历史列表(左侧面板)中的快捷键 ==========
				["q"] = "<cmd>DiffviewClose<cr>",
			},
		},
	},
}
