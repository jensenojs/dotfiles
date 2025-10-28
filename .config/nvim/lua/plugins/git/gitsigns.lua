-- https://github.com/lewis6991/gitsigns.nvim
-- 在标志列显示 Git 变更标记, 并提供丰富操作
return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "gitsigns",
	opts = {
		signs = {
			add = {
				text = "│",
			},
			change = {
				text = "│",
			},
			delete = {
				text = "_",
			},
			topdelete = {
				text = "‾",
			},
			changedelete = {
				text = "~",
			},
			untracked = {
				text = "┆",
			},
		},

		-- 启用行内 Blame (替代 git-blame.nvim)
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "eol", -- 显示在行尾
			delay = 500, -- 延迟 500ms 显示
			ignore_whitespace = false,
		},
		current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")
			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Hunk 导航
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({
						"]c",
						bang = true,
					})
				else
					gitsigns.nav_hunk("next")
				end
			end, {
				desc = "下一个改动",
			})

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({
						"[c",
						bang = true,
					})
				else
					gitsigns.nav_hunk("prev")
				end
			end, {
				desc = "上一个改动",
			})

			-- Hunk 操作 (使用 <leader>gh 前缀)
			map("n", "<leader>ghs", gitsigns.stage_hunk, {
				desc = "暂存 Hunk",
			})
			map("n", "<leader>ghr", gitsigns.reset_hunk, {
				desc = "重置 Hunk",
			})
			map("n", "<leader>ghp", gitsigns.preview_hunk, {
				desc = "预览 Hunk",
			})
			map("n", "<leader>ghu", gitsigns.undo_stage_hunk, {
				desc = "撤销暂存 Hunk",
			})

			map("v", "<leader>ghs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, {
				desc = "暂存 Hunk (visual)",
			})
			map("v", "<leader>ghr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, {
				desc = "重置 Hunk (visual)",
			})

			-- Buffer 级操作
			map("n", "<leader>ghS", gitsigns.stage_buffer, {
				desc = "暂存整个文件",
			})
			map("n", "<leader>ghR", gitsigns.reset_buffer, {
				desc = "重置整个文件",
			})

			-- Blame
			map("n", "<leader>gb", gitsigns.toggle_current_line_blame, {
				desc = "切换行内 Blame",
			})
			map("n", "<leader>gB", gitsigns.blame, {
				desc = "文件 Blame 视图",
			})

			-- Diff
			map("n", "<leader>gD", function()
				gitsigns.diffthis("HEAD")
			end, {
				desc = "Diff vs HEAD",
			})
		end,
	},
}
