-- https://github.com/stevearc/aerial.nvim
-- 文件大纲
return {
	"stevearc/aerial.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	-- 关键：使用 event 触发加载，确保 autocommands 被创建
	event = "LspAttach",

	opts = function()
		local api = vim.api
		local bind = require("utils.bind")
		local map_callback = bind.map_callback
		local is_lsp_attached = require("utils.lsp").is_lsp_attached

		-- 键位接管函数: 在 LSP buffer 上覆盖 <leader>o
		local function takeover_lsp_buf(bufnr, client)
			if not is_lsp_attached(bufnr) then
				return
			end

			-- 幂等: 已处理过就跳过
			local ok_done = pcall(api.nvim_buf_get_var, bufnr, "aerial_lsp_takenover")
			if ok_done then
				return
			end

			-- 检查 client 是否支持 documentSymbol
			local if_support = function(method)
				return require("utils.lsp").if_support(method, bufnr)
			end

			if not if_support(vim.lsp.protocol.Methods.textDocument_documentSymbol) then
				return
			end

			-- 覆盖 <leader>o: 聚焦并打开 aerial
			local keymaps = {
				["n|<leader>lo"] = map_callback(function()
						require("aerial").toggle({
							focus = true,
							direction = "right",
						})
					end)
					:with_buffer(bufnr)
					:with_noremap()
					:with_silent()
					:with_desc("大纲: 打开/关闭 Aerial"),
			}

			bind.nvim_load_mapping(keymaps)

			-- 标记已接管
			api.nvim_buf_set_var(bufnr, "aerial_lsp_takenover", true)
		end

		-- 返回 aerial 配置表
		local aerial_config = {
			-- 🚨 关键：强制禁用 lazy_load，确保 autocommands 被创建
			lazy_load = false,

			-- 自动打开: 仅当 LSP 支持 documentSymbol 时
			open_automatic = function(bufnr)
				local clients = vim.lsp.get_clients({
					bufnr = bufnr,
				})
				for _, client in ipairs(clients) do
					if client.server_capabilities.documentSymbolProvider then
						return true
					end
				end
				return false
			end,

			autojump = true,

			close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },

			on_attach = function(bufnr)
				-- Jump forwards/backwards with '{' and '}'
				vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", {
					buffer = bufnr,
				})
				vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", {
					buffer = bufnr,
				})
			end,
		}

		-- ⚠️ 重要：这里不能直接调用 require("aerial").setup()
		-- lazy.nvim 会自动处理 setup 调用

		-- 设置 LspAttach autocmd: 在 LSP 附加时自动接管键位
		local AERIAL_ATTACH = api.nvim_create_augroup("AerialLspAttach", {
			clear = true,
		})
		api.nvim_create_autocmd("LspAttach", {
			group = AERIAL_ATTACH,
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if not client then
					return
				end
				takeover_lsp_buf(args.buf, client)
			end,
		})

		-- 兜底: 对当前已存在且已附加 LSP 的 buffer 进行一次覆盖
		for _, bufnr in ipairs(api.nvim_list_bufs()) do
			local clients = vim.lsp.get_clients({
				bufnr = bufnr,
			})
			if clients and #clients > 0 then
				local client = clients[1]
				takeover_lsp_buf(bufnr, client)
			end
		end

		-- 返回配置表给 lazy.nvim
		return aerial_config
	end,
}
