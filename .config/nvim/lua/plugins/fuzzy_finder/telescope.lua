-- https://github.com/nvim-telescope/telescope.nvim
-- define common options
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cr = bind.map_cr
local takeover = require("plugins.fuzzy_finder.lsp_takeover")
local api = vim.api

local keymaps = {
	-- more telescope-relative shortcut, plz refer to lsp-config.lua
	["n|/"] = map_callback(function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			require("telescope.builtin").current_buffer_fuzzy_find()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("模糊搜索当前文件"),
	
	["n|<leader>/"] = map_callback(function()
			require("telescope.builtin").live_grep()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("全局模糊搜索"),

	["n|<leader>b"] = map_callback(function()
			require("telescope.builtin").buffers()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("打开缓冲区列表"),

	["n|<leader>g"] = map_callback(function()
			require("telescope.builtin").git_status()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("列出当前项目下修改了哪些文件"),

	["n|<c-p>"] = map_callback(function()
			require("telescope.builtin").find_files()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("查找文件"),

	["n|<leader>r"] = map_callback(function()
			require("telescope.builtin").registers()
		end)
		:with_noremap()
		:with_silent()
		:with_desc("打开寄存器列表"),

}

bind.nvim_load_mapping(keymaps)

-- 对预览的设置
-- Ignore files bigger than a threshold
-- and don't preview binaries
local preview_setting = function(filepath, bufnr, opts)
	filepath = vim.fn.expand(filepath)
	local previewers = require("telescope.previewers")
	local Job = require("plenary.job")

	-- 如果是二进制, 不预览
	Job:new({
		command = "file",
		args = { "--mime-type", "-b", filepath },
		on_exit = function(j)
			local mime_type = vim.split(j:result()[1], "/")[1]
			if mime_type ~= "text" then
				-- maybe we want to write something to the buffer here
				vim.schedule(function()
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
				end)
			end
		end,
	}):sync()

	-- 如果文件太大, 也不预览
	vim.loop.fs_stat(filepath, function(_, stat)
		if not stat then
			return
		end
		if stat.size > 1000000 then
			return
		else
			previewers.buffer_previewer_maker(filepath, bufnr, opts)
		end
	end)
end

return {
	"nvim-telescope/telescope.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
		"nvim-telescope/telescope-ui-select.nvim", -- "nvim-telescope/telescope-dap.nvim",
		"tom-anders/telescope-vim-bookmarks.nvim",
		"nvim-tree/nvim-web-devicons", -- "nvim-telescope/telescope-aerial.nvim"
	},

	config = function()
		local actions = require("telescope.actions")

		require("telescope").setup({
			defaults = {
				-- 可爱捏
				prompt_prefix = "🔍 ",

				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"--glob=!.git/",
				},

				-- 让预览的设置生效
				buffer_previewer_maker = preview_setting,

				initial_mode = "insert",

				-- 这些文件不需要被搜索
				file_ignore_patterns = { ".git/", ".cache", "build/", "%.class", "%.pdf", "%.mkv", "%.mp4", "%.zip" },

				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
					vertical = {
						mirror = false,
					},
					width = 0.85,
					height = 0.92,
					preview_cutoff = 120,
				},

				-- Default configuration for telescope goes here:
				mappings = {
					-- insert mode
					i = {
						-- map actions.which_key to <C-h> (default: <C-/>)
						-- actions.which_key shows the mappings for your picker,
						-- e.g. git_{create, delete, ...}_branch for the git_branches picker
						["<c-u>"] = false, --  clear prompt
						["<c-h>"] = "which_key", -- 显示快捷指令的作用
						["<f1>"]  = "which_key", -- 显示快捷指令的作用
					},
				},
			},

			pickers = {
				find_files = {
					find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
					mappings = {
						i = {
							["<CR>"] = actions.select_drop,
						},
					},
				},

				buffers = {
					show_all_buffers = true,
					sort_lastused = true,
					mappings = {
						i = {
							["<c-d>"] = actions.delete_buffer,
							["<CR>"] = actions.select_drop,
						},
					},
				},

				git_status = {
					preview = {
						hide_on_startup = false,
					},
					mappings = {
						i = {
							["<CR>"] = actions.select_drop,
						},
					},
				},

				live_grep = {
					preview = {
						hide_on_startup = false,
					},
					mappings = {
						i = {
							["<CR>"] = actions.select_drop,
						},
					},
				},

				old_files = {
					mappings = {
						i = {
							["<CR>"] = actions.select_drop,
						},
					},
				},
			},

			extensions = {
				-- Your extension configuration goes here:
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
				},
				["ui-select"] = { require("telescope.themes").get_dropdown({}) },
				-- aerial = {
				-- 	-- Display symbols as <root>.<parent>.<symbol>
				-- 	show_nesting = {
				-- 		["_"] = false, -- This key will be the default
				-- 		json = false, -- You can set the option for specific filetypes
				-- 		yaml = false,
				-- 	},
				-- },
			},
		})
		--
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")
		-- require("telescope").load_extension("vim_bookmarks")
		require("telescope").load_extension("lazygit")
		-- require("telescope").load_extension("aerial")
		-- require("telescope").load_extension("dap")

		-- 注册自动命令: 在 LSP 附加时覆盖该 buffer 的按键
		-- 说明：
		-- - 我们不在 attach.lua 修改原生映射, 而是在插件侧监听同一事件, 
		--   使用 telescope.builtin.lsp_* 将相同语义的键位(如 <leader>o / <leader>O)
		--   重定向到 Telescope UI。
		-- - Neovim 的自动命令按“定义顺序”执行；该回调在 attach.lua 之后定义, 
		--   因此会在同一 LspAttach 事件中更晚执行, 从而以 buffer-local 覆盖前者。
		--   参考 :h autocmd
		local TELE_ATTACH = api.nvim_create_augroup("telescope.override_lsp", { clear = true })
		api.nvim_create_autocmd("LspAttach", {
			group = TELE_ATTACH,
			callback = function(ev)
				-- ev.buf: 附加的 buffer；takeover 内部只用 telescope.builtin.lsp_*
				-- 并且带幂等标记, 重复进入不会反复设置。
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
        		if not client then
            		return
        		end
				takeover.takeover_lsp_buf(ev.buf, client)
			end,
		})

		-- 兜底: 对当前已存在且已附加 LSP 的 buffer 进行一次覆盖
		-- 说明：
		-- - LspAttach 只在“新发生的附加事件”时触发；当插件被 lazy.nvim 晚加载时, 
		--   进程里可能已经有若干 buffer 早就附加了 LSP(因此不会再触发 LspAttach)。
		-- - 这里主动遍历现有 buffer 并调用 takeover, 以保证它们也切换到 Telescope 的 UI。
		-- - takeover() 内部会判断该 bufnr 是否已附加 LSP、是否已经处理过, 因而是幂等的。
		for _, bufnr in ipairs(api.nvim_list_bufs()) do
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			local client = (clients and clients[1]) or nil
			takeover.takeover_lsp_buf(bufnr, client)
		end
	end,
}
