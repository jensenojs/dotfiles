-- https://github.com/williamboman/mason-lspconfig.nvim
return {
	"williamboman/mason-lspconfig.nvim",
	-- config = function()
	opts = function()
		require("mason-lspconfig").setup({
			-- migrate tool installation task to mason-tool-installer
			ensure_installed = {},
			automatic_installation = true,
		})
	end,
	dependencies = { "williamboman/mason.nvim" },
}
