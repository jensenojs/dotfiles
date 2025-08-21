-- https://github.com/neovim/nvim-lspconfig
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_callback = bind.map_callback
local map_cmd = bind.map_cmd

-- local keymaps = {
-- ["n|<F9>"] = map_cr():with_noremap():with_silent():with_desc("调试: 添加/删除断点")
-- }

-- bind.nvim_load_mapping(keymaps)
local on_attach = function(client, bufnr)
	vim.lsp.inlay_hint.enable(true, { bufnr })

	local signature_setup = {
		hint_prefix = "🦫 ",
	}

	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- telescope integration
	telescope_builtin = require("telescope.builtin")

	-- 还不太理解有什么用
	-- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	-- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	-- vim.keymap.set("n", "<space>wl", function()
	--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	-- end, bufopts)

	local keymaps = {
		-----------------
		--    insert   --
		-----------------

		-----------------
		--    normal   --
		-----------------

		-- 如果考虑进一步修改的话, lspsaga, glance 可能会进一步替换, 现在先暂时这样
		-- https://github.com/ayamir/nvimdots/blob/main/lua/keymap/completion.lua
		["n|gd"] = map_callback(function()
				vim.lsp.buf.definition()
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("跳转到定义"),

		["n|gD"] = map_callback(function()
				vim.lsp.buf.declaration()
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("跳转到声明"),

		["n|gt"] = map_callback(function()
				telescope_builtin.lsp_type_definitions()
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("跳转到符号类型定义"),

		["n|gi"] = map_callback(function()
				vim.lsp.buf.implementation()
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("跳转到实现"),

		["n|gr"] = map_callback(function()
				telescope_builtin.lsp_references()
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("跳转到引用"),

		["n|<leader>rn"] = map_callback(function()
				vim.lsp.buf.rename()
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("变量重命名"),

		-- ["n|<c-s>"] = map_cr(":Telescope aerial")
		-- 	:with_noremap()
		-- 	:with_silent()
		-- 	:with_buffer(bufnr)
		-- 	:with_desc("查找当前文件下的符号"),

		["n|<c-s>"] = map_callback(function()
				telescope_builtin.lsp_document_symbols()
			end)
			:with_noremap()
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("查找当前文件下的符号"),

		["n|<c-w>"] = map_callback(function()
				telescope_builtin.lsp_dynamic_workspace_symbols()
			end)
			:with_noremap()
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("查找当前项目下的符号"),

		["n|<leader>a"] = map_callback(function()
				require("tiny-code-action").code_action()
			end)
			:with_noremap()
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("查看有什么可以做的code action"),

		-- ["n|<leader>a"] = map_callback(function()
		-- end):with_noremap():with_silent():with_buffer(bufnr):with_desc("查看有什么可以做的code action"),

		-- show docs
		["n|<s-k>"] = map_callback(function()
				-- Use K to show documentation in preview window
				local cw = vim.fn.expand("<cword>")
				if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
					vim.api.nvim_command("h " .. cw)
				else
					local bufnr = vim.api.nvim_get_current_buf()
					local clients = vim.lsp.get_clients()
					if #clients > 0 then
						-- 如果有附加的 LSP 客户端, 使用内置的 LSP 功能来显示文档
						vim.lsp.buf.hover()
					else
						-- 否则, 使用传统的 keywordprg 方式
						vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
					end
				end
			end)
			:with_silent()
			:with_buffer(bufnr)
			:with_desc("显示光标所在处的文档"),
	}

	bind.nvim_load_mapping(keymaps)
end

-- Replace termcodes in input string (e.g. converts '<C-a>' -> '').
local function replace_keycodes(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		--------------------------------lspconfig-----------------------
		local lspconfig = require("lspconfig")
		local util = require("lspconfig/util")

		-- Mappings : use trouble.nvim instead
		-- See `:help vim.diagnostic.*` for documentation on any of the below functions
		-- local opts = {
		--     noremap = true,
		--     silent = true
		-- }
		-- vim.keymap.set("n", "<space>E", vim.diagnostic.open_float, opts)
		-- vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		-- vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

		-- Use an on_attach function to only map the following keys
		-- after the language server attaches to the current buffer

		local lsp_flags = {
			allow_incremental_sync = true,
			-- This is the default in Nvim 0.7+
			debounce_text_changes = 150,
		}

		local lsp_defaults = lspconfig.util.default_config
		lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, capabilities)

		local servers = {
			"cmake",
			"clangd", -- C/C++
			-- "pyright", -- python
			"ruff", -- python "pyright",
			"rust_analyzer", -- rust
			"gopls", -- golang
			"sqlls", -- sql
			"lua_ls", -- lua
			"dockerls", -- docker
			"jsonls", -- json
		}

		for _, lsp in pairs(servers) do
			-- if lsp == "" then
			--     lspconfig[lsp].setup({
			-- 		settings = {
			--
			-- 		},
			--         on_attach = on_attach,
			--         flags = lsp_flags
			if lsp == "clangd" then
				lspconfig[lsp].setup({
					settings = {
						clangd = {
							capabilities = {
								offsetEncoding = { "utf-16" },
							},
							cmd = {
								"clangd",
								-- Neovim中语言服务器协议(LSP)的配置选项。
								-- 这些选项用于自定义LSP服务器的行为。
								"-j=12", -- 设置用于索引的线程数。
								"--enable-config", -- 启用配置文件。
								"--background-index", -- 启用后台索引。
								"--pch-storage=memory", -- 将预编译头文件存储在内存中。
								"--clang-tidy", -- 启用Clang-Tidy集成。
								"--header-insertion=iwyu", -- 使用“Include What You Use”(IWYU)风格进行头文件插入。
								"--completion-style=detailed", -- 使用详细的补全风格。
								"--function-arg-placeholders", -- 在补全中启用函数参数占位符。
								"--fallback-style=llvm", -- 使用LLVM编码风格作为后备。
								"--header-insertion-decorators", -- 启用头文件插入的装饰器。
								"--header-insertion=iwyu", -- 使用“Include What You Use”(IWYU)风格进行头文件插入(重复选项)。
								"--limit-references=3000", -- 将服务器返回的引用数量限制为3000。
								"--limit-results=350", -- 将服务器返回的结果数量限制为350。
							},
							init_options = {
								usePlaceholders = true,
								completeUnimported = true,
								clangdFileStatus = true,
							},
						},
					},
					on_attach = on_attach,
					flags = lsp_flags,
				})
				-- elseif lsp == "" then
				--     lspconfig[lsp].setup({
				-- 		settings = {

				-- 		},
				--         on_attach = on_attach,
				--         flags = lsp_flags
				-- 	})
				-- elseif lsp == "" then
				--     lspconfig[lsp].setup({
				-- 		settings = {

				-- 		},
				--         on_attach = on_attach,
				--         flags = lsp_flags
				-- 	})
				-- elseif lsp == "" then
				--     lspconfig[lsp].setup({
				-- 		settings = {

				-- 		},
				--         on_attach = on_attach,
				--         flags = lsp_flags
				-- 	})
			elseif lsp == "lua_ls" then
				lspconfig[lsp].setup({
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
					on_attach = on_attach,
					flags = lsp_flags,
				})
			elseif lsp == "rust_analyzer" then
				lspconfig[lsp].setup({
					settings = {
						["rust-analyzer"] = {
							checkOnSave = true,
							check = {
								command = "clippy",
								features = "all",
							},
							assist = {
								importGranularity = "module",
								importPrefix = "self",
							},
							diagnostics = {
								enable = true,
								enableExperimental = true,
							},
							cargo = {
								loadOutDirsFromCheck = true,
								features = "all", -- avoid error: file not included in crate hierarchy
							},
							procMacro = {
								enable = true,
							},
							inlayHints = {
								chainingHints = true,
								parameterHints = true,
								typeHints = true,
							},
						},
					},
					on_attach = on_attach,
					flags = lsp_flags,
				})
			elseif lsp == "gopls" then
				lspconfig[lsp].setup({
					settings = {
						gopls = {
							analyses = {
								fieldalignment = true, -- 字段对齐分析
								nilness = true, -- nil 值分析
								unusedparams = true, -- 未使用的参数分析
								unusedwrite = true, -- 未使用的写操作分析
								useany = true, -- 使用 any 类型分析
							},
							codelenses = {
								gc_details = false, -- 垃圾回收详情
								generate = true, -- 生成代码
								regenerate_cgo = true, -- 重新生成 cgo
								run_govulncheck = true, -- 运行 govulncheck
								test = true, -- 测试代码
								tidy = true, -- 整理代码
								upgrade_dependency = true, -- 升级依赖
								vendor = true, -- 管理 vendor 目录
							},
							completeUnimported = true, -- 自动补全未导入的包
							directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" }, -- 目录过滤
							gofumpt = true, -- 使用 gofumpt 格式化代码
							hints = {
								assignVariableTypes = true, -- 提示变量类型
								compositeLiteralFields = true, -- 提示复合字面量字段
								compositeLiteralTypes = true, -- 提示复合字面量类型
								constantValues = true, -- 提示常量值
								functionTypeParameters = true, -- 提示函数类型参数
								parameterNames = true, -- 提示参数名称
								rangeVariableTypes = true, -- 提示 range 变量类型
							},
							staticcheck = true, -- 启用 staticcheck
							semanticTokens = true, -- 启用语义标记
							usePlaceholders = true, -- 使用占位符
						},
					},
					on_attach = on_attach,
					flags = lsp_flags,
				})
			elseif lsp == "ruff" then
				lspconfig[lsp].setup({
					settings = {
						ruff = {
							-- Modification to any of these settings has no effect.
							enable = true,
							ignoreStandardLibrary = true,
							organizeImports = true,
							fixAll = true,
							lint = {
								enable = true,
								run = "onType",
							},
						},
					},
					on_attach = on_attach,
					flags = lsp_flags,
				})
			else
				lspconfig[lsp].setup({
					on_attach = on_attach,
					flags = lsp_flags,
				})
			end
		end
	end,
	-- dependencies = {{"ray-x/lsp_signature.nvim"}, {"rachartier/tiny-code-action.nvim"},
	--                 {"williamboman/mason-lspconfig.nvim"}}
	dependencies = { { "rachartier/tiny-code-action.nvim" }, { "williamboman/mason-lspconfig.nvim" } },
}
