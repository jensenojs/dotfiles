-- https://github.com/MattesGroeger/vim-bookmarks
-- 书签
-- 它还有一些其他的功能, 比如说：https://github.com/MattesGroeger/vim-bookmarks#bookmarks-per-working-directory
-- 但是用不到目前
local bind = require("utils.bind")
local map_cr = bind.map_cr

local keymaps = {
	["n|mm"] = map_cr("BookmarkToggle")
		:with_noremap()
		:with_silent()
		:with_desc("书签:在当前行添加/删除书签"),
	["n|mi"] = map_cr("BookmarkAnnotate"):with_noremap():with_silent():with_desc("书签:添加/修改注释"),
	["n|mc"] = map_cr("BookmarkClear"):with_noremap():with_silent():with_desc("书签:clear current file only"),
	["n|mx"] = map_cr("BookmarkClearAll"):with_noremap():with_silent():with_desc("书签:clear current workspace"),
	["n|mn"] = map_cr("BookmarkNext"):with_noremap():with_silent():with_desc("书签:jump to next"),
	["n|mp"] = map_cr("BookmarkPrev"):with_noremap():with_silent():with_desc("书签:jump to prev"),

	-- ["n|ma"] = map_cr("Telescope vim_bookmarks current_file")
	-- 	:with_noremap()
	-- 	:with_silent()
	-- 	:with_desc("书签:查找当前文件下的书签"),
	["n|ma"] = map_cr("Telescope vim_bookmarks all")
		:with_noremap()
		:with_silent()
		:with_desc("书签:查找当前项目下的书签"),
}

bind.nvim_load_mapping(keymaps)

return {
	"MattesGroeger/vim-bookmarks",
	config = function() end,
}
