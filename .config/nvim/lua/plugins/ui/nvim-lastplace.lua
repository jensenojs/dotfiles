-- https://github.com/ethanholz/nvim-lastplace
-- 记忆当前文件的位置, 在下次打开时自动定位到上次的位置
return {
	"ethanholz/nvim-lastplace",
	config = function()
		require("nvim-lastplace").setup({
			lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
			lastplace_ignore_filetype = { "gitcommit", "gitrebase", "svn", "hgcommit" },
			lastplace_open_folds = true,
		})
	end,
}
