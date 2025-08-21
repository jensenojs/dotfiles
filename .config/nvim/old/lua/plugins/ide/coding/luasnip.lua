-- https://github.com/L3MON4D3/LuaSnip
-- copy from
-- https://github.com/yongtenglei/Neovim-QWERTY/blob/main/lua/rey/plugins/luasnip.lua
return {
	"L3MON4D3/LuaSnip",
	event = "InsertEnter",
	config = function()
		local luasnip_loader = require("luasnip.loaders.from_vscode")
		luasnip_loader.lazy_load()
		luasnip_loader.lazy_load({
			paths = { "~/.config/nvim/lua/utils/snippets" },
		})
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/lua/utils/snippets" } })

		local luasnip = require("luasnip")
		luasnip.config.setup({
			region_check_events = "CursorHold,InsertLeave,InsertEnter",
			delete_check_events = "TextChanged,InsertEnter",
		})
	end,
	dependencies = { { "rafamadriz/friendly-snippets" } },
}
