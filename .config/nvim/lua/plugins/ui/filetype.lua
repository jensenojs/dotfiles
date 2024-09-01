-- https://github.com/nathom/filetype.nvim
-- 对neovim的filetype进行了优化，可以使打开文件时识别文件类型的速度更快
return {
	"nathom/filetype.nvim",
	lazy = true,
	event = { "BufRead", "BufNewFile" },
	config = function()
		require("filetype").setup({
			-- overrides = {
			--     extensions = {
			--         h = "cpp"
			--     }
			-- }
		})
	end,
}
