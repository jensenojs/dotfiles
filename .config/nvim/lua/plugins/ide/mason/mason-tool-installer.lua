-- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	config = function()
		require("mason-tool-installer").setup({

			-- a list of all tools you want to ensure are installed upon
			-- start
			ensure_installed = {
				{ "vim-language-server" }, -- vim

				{ "lua_ls", "stylua", "luacheck" }, -- lua

				{
					"gopls",
					"golangci-lint",
					"golangci_lint_ls",
					"gofumpt",
					"gotests",
					"goimports",
					"golines",
					"gomodifytags",
					"impl",
					"go-debug-adapter",
					"delve",
				}, -- golang

				{
					"black",
					"pyright",
					"pylint",
					"isort",
					"mypy",
					"ruff",
				}, -- python

				{ "clangd", "cmake", "clang-format" }, -- C/C++

				{ "prettierd", "codelldb" }, -- rust

				{ "bash-language-server", "shellcheck", "shfmt" }, -- shell

				{ "sqlfmt" }, -- sql

				{ "yamlls", "yamlfmt" }, -- yaml

				{ "jq" }, -- json

				{ "mdformat", "markdownlint" }, -- markdown
			},

			auto_update = false,

			run_on_start = true,

			start_delay = 3000, -- 3 second delay

			debounce_hours = 5, -- at least 5 hours between attempts to install/update

			-- By default all integrations are enabled. If you turn on an integration
			-- and you have the required module(s) installed this means you can use
			-- alternative names, supplied by the modules, for the thing that you want
			-- to install. If you turn off the integration (by setting it to false) you
			-- cannot use these alternative names. It also suppresses loading of those
			-- module(s) (assuming any are installed) which is sometimes wanted when
			-- doing lazy loading.
			integrations = {
				["mason-lspconfig"] = true,
				["mason-null-ls"] = false,
				["mason-nvim-dap"] = true,
			},
		})
	end,

	dependencies = { "williamboman/mason.nvim" },
}
