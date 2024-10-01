-- https://github.com/zbirenbaum/copilot.lua
-- if you can't authenticating
-- https://github.com/orgs/community/discussions/75145#discussioncomment-8639303
return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	config = function()
		vim.g.copilot_proxy = "http://127.0.0.1:7890"
		require("copilot").setup({})
	end,
}
