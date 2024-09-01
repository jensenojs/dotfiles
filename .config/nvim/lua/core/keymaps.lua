-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_cmd = bind.map_cmd
local map_callback = bind.map_callback

-- leader键设置为空格
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--  按下 Home 键时, 会回到该行第一个非空白字符处; 再次按 Home, 又会跳转到行首.
local function home()
	local head = (vim.api.nvim_get_current_line():find("[^%s]") or 1) - 1
	local cursor = vim.api.nvim_win_get_cursor(0)
	cursor[2] = cursor[2] == head and 0 or head
	vim.api.nvim_win_set_cursor(0, cursor)
end

-- 利用bind的辅助函数封装了vim.keymap.系列的函数
local keymaps = {
	-----------------
	--   窗口管理   --
	-----------------
	-- vim的窗口管理逻辑和一般的ide不一样
	["n|<c-l>"] = map_cmd("<C-w>l"):with_noremap():with_silent():with_desc("窗口:光标向右移动"),
	["n|<c-h>"] = map_cmd("<C-w>h"):with_noremap():with_silent():with_desc("窗口:光标向左移动"),
	["n|<c-k>"] = map_cmd("<C-w>k"):with_noremap():with_silent():with_desc("窗口:光标向上移动"),
	["n|<c-j>"] = map_cmd("<C-w>j"):with_noremap():with_silent():with_desc("窗口:光标向下移动"),

	["n|<c-s-up>"] = map_cmd("<C-w>+"):with_noremap():with_silent():with_desc("窗口:增加当前的高度"),
	["n|<c-s-down>"] = map_cmd("<C-w>-"):with_noremap():with_silent():with_desc("窗口:减少当前的高度"),
	["n|<c-s-left>"] = map_cmd("<C-w>>"):with_noremap():with_silent():with_desc("窗口:增加当前的宽度"),
	["n|<c-s-right>"] = map_cmd("<C-w><"):with_noremap():with_silent():with_desc("窗口:减少当前的宽度"),

	-----------------
	--  标签页管理   --
	-----------------
	["n|<a-t>"] = map_cr("tabe"):with_noremap():with_silent():with_desc("标签:新建一个tab"),
	["n|<a-c>"] = map_cmd(":tabc<CR>"):with_noremap():with_silent():with_desc("标签:关闭当前tab"),
	["n|<a-o>"] = map_cmd(":tabo<CR>")
		:with_noremap()
		:with_silent()
		:with_desc("标签:关闭除了当前tab以外的其他tab"),

	-- 之所以用这个奇怪的快捷键是想要让它低成本地在tmux中也能用...
	["n|<a-s-l>"] = map_callback(function()
			-- 获取当前标签页的索引
			local current_tab = vim.fn.tabpagenr()
			-- 获取标签页总数
			local total_tabs = vim.fn.tabpagenr("$")
			-- 如果当前标签页不是最左边的标签页，则向左移动
			if current_tab < total_tabs then
				vim.cmd("tabnext")
			else
				-- 否则跳转回开始
				vim.cmd("tabfirst")
			end
		end)
		:with_noremap()
		:with_silent()
		:with_desc("标签:移动到右tab"),
	["n|<a-s-h>"] = map_callback(function()
			-- 获取当前标签页的索引
			local current_tab = vim.fn.tabpagenr()
			-- 获取标签页总数
			local total_tabs = vim.fn.tabpagenr("$")
			-- 如果当前标签页不是最右边的标签页，则向右移动
			if current_tab > 1 then
				vim.cmd("tabprevious")
			else
				-- 否则跳转回最后
				vim.cmd("tablast")
			end
		end)
		:with_noremap()
		:with_silent()
		:with_desc("标签:移动到左tab"),

	-----------------
	--   保存与退出  --
	-----------------
	["n|<leader>q"] = map_cr("q"):with_noremap():with_silent():with_desc("删除当前窗口"),
	["n|<leader>w"] = map_cr("w"):with_noremap():with_silent():with_desc("保存当前窗口指向的buffer"),
	["n|<leader>W"] = map_cr("wa"):with_noremap():with_silent():with_desc("保存所有的buffer"),
	["n|<leader>Q"] = map_cr("qa!"):with_noremap():with_silent():with_desc("强制退出neovim"),

	-----------------
	--    可视模式  --
	-----------------
	["v|J"] = map_cmd(":m '>+1<CR>gv=gv"):with_desc("可视:Move this line down"),
	["v|K"] = map_cmd(":m '<-2<CR>gv=gv"):with_desc("可视:Move this line up"),
	["v|<"] = map_cmd("<gv"):with_noremap():with_silent():with_desc("重新选择上一次选择的区域"),
	["v|>"] = map_cmd(">gv")
		:with_noremap()
		:with_silent()
		:with_desc("重新选择上一次选择的区域，并向右移动一次缩进"),

	["v|<leader>ss"] = map_callback(function()
			require("utils.quick_substitute")
		end)
		:with_noremap()
		:with_silent()
		:with_desc("在指定行间进行文本替换"),

	-----------------
	--    其他      --
	-----------------
	["in|<Home>"] = map_callback(home):with_desc("光标:先按相当于^, 再按到行首"),
	["n|0"] = map_callback(home):with_desc("光标:先按相当于^, 再按到行首"),
}

bind.nvim_load_mapping(keymaps)
