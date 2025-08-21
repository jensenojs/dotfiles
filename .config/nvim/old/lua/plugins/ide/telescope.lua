-- define common options
local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cr = bind.map_cr

local keymaps = {
	-- more telescope-relative shortcut, plz refer to lsp-config.lua
	["n|<leader>/"] = map_callback(function()
			-- You can pass additional configuration to telescope to change theme, layout, etc.
			require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 20,
			}))
		end)
		:with_noremap()
		:with_silent()
		:with_desc("模糊搜索当前文件"),

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
			build = "make",
		},
		"nvim-telescope/telescope-ui-select.nvim",
		"nvim-telescope/telescope-dap.nvim",
		"tom-anders/telescope-vim-bookmarks.nvim",
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local actions = require("telescope.actions")

		require("telescope").setup({
			defaults = {
				-- 可爱捏
				prompt_prefix = "🔍 ",

				vimgrep_arguments = {
					"rg",
					-- "--color=never",
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
					},
				},
			},

			pickers = {
				find_files = {
					-- find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
					find_command = { "fd", "--type", "f" },
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
		require("telescope").load_extension("vim_bookmarks")
		require("telescope").load_extension("lazygit")
		-- require("telescope").load_extension("aerial")
		require("telescope").load_extension("dap")
	end,
}
