-- https://github.com/CopilotC-Nvim/CopilotChat.nvim

return {
	"CopilotC-Nvim/CopilotChat.nvim",
	branch = "canary",
	dependencies = {
		{ "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
		{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
	},
	build = "make tiktoken", -- Only on MacOS or Linux
	config = function()
		require("copilot").setup({
	            debug = true, -- Enable debugging
	        })
	end,
	-- See Commands section for default commands if you want to lazy load on them
}
