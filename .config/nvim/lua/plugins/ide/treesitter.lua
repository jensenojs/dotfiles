-- https://github.com/nvim-treesitter/nvim-treesitter
--
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",

	dependencies = { -- better matchup which can be intergreted to treesitter
		"andymass/vim-matchup",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			-- 支持的语言, 它们的代码高亮就很漂亮啦
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"cmake",
				"make",
				"go",
				"gomod",
				"gosum",
				"gowork",
				"java",
				"rust",
				"lua",
				"scheme",
				"python",
				"json",
				"vim",
				"vimdoc",
				"sql",
				"scala",
				"toml",
                "html",
                "markdown",
                "markdown_inline",
			},

			-- Install parsers synchronously (only applied to `ensure_installed`)
			sync_install = false,

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,

			-- 启用代码高亮
			highlight = {
				enable = true,

				-- 如果文件太大了就算了
				disable = function(lang, buf)
					local max_filesize = 200 * 1024 -- 200 KB
					local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
					if ok and stats and stats.size > max_filesize then
						return true
					end
				end,

				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},
		})

		-- 启用基于treesiter的代码折叠功能
		vim.opt.foldmethod = "expr"
		vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
		vim.opt.foldlevel = 10
	end,
}
