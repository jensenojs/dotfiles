-- 服务清单 (The Server Manifest)
--
-- 一个简单的 Lua 表, 作为需要被管理的 LSP 服务的"清单"或"白名单"。
-- `bootstrap.lua` 会遍历此列表, 并为每个条目调用 `vim.lsp.enable()`。
-- 添加或移除一个服务器就像编辑这个列表一样简单。

return {
	-- "bashls",
	"clangd",
	"golangci_lint_ls",
	"gopls",
	-- "jsonls",
	"lua_ls",
	-- "markdown_oxide",
	"ruff",
	-- "rust_analyzer",  -- 由rustaceanvim插件管理
	-- "sqls",
	-- "vimls",
	-- "yamlls",
}