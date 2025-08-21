-- https://github.com/neoclide/coc.nvim
-- Make your Vim/Neovim as smart as VS Code
local opt = vim.opt

--  https: //github.com/folke/trouble.nvim/issues/203
-- https://github.com/neoclide/coc.nvim/discussions/4102#discussioncomment-3482741

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"


local bind = require("utils.bind")
local map_callback = bind.map_callback
local map_cmd = bind.map_cmd
local map_cr = bind.map_cr

-- Replace termcodes in input string (e.g. converts '<C-a>' -> '').
local function replace_keycodes(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local keymaps = {
	-----------------
	--    insert   --
	-----------------

	-- Make <CR> to accept selected completion item or notify coc.nvim to format
	-- https://salferrarello.com/vim-keymap-set-coc-to-confirm-completion-with-lua/
	-- not work
	["i|<CR>"] = map_cmd('coc#pum#visible() ? coc#pum#confirm() : "<CR>"')
		:with_silent()
		:with_expr()
		:with_noremap()
		:with_desc("自动补全:选中光标所在"),

	["i|<tab>"] = map_callback(
		function()
			-- Used in Tab mapping above. If the popup menu is visible, switch to next item in that. Else prints a tab if previous
			-- char was empty or whitespace. Else triggers completion.
			local check_after_cursor = function()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				local line = vim.api.nvim_get_current_line()
				local text_after_cursor = line:sub(col + 1)
				return text_after_cursor:match("[%]},%)`\"']") and true
			end

			local check_back_space = function()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				return (col == 0 or vim.api.nvim_get_current_line():sub(col, col):match("%s")) and true
			end

			if vim.fn["coc#pum#visible"]() ~= 0 then
				return vim.fn["coc#pum#next"](1)
			elseif check_back_space() then
				return replace_keycodes("<Tab>")
			elseif check_after_cursor() then
				-- 使得光标自动地跳过右括号等
				return replace_keycodes("<Plug>(Tabout)")
			end
			-- trigger completion
			return vim.fn["coc#refresh"]()
		end
	)
		:with_silent()
		:with_expr()
		:with_desc("聪明的tab"),

	["i|<s-tab>"] = map_callback(
		function()
			local check_before_cursor = function()
				local col = vim.api.nvim_win_get_cursor(0)[2]
				local line = vim.api.nvim_get_current_line()
				local text_before_cursor = line:sub(1, col)
				return text_before_cursor:match("[[{%(`\"']") and true
			end

			if vim.fn["coc#pum#visible"]() ~= 0 then
				return vim.fn["coc#pum#prev"](1)
			elseif check_before_cursor() then
				-- 使得光标自动地跳过左括号等
				return replace_keycodes("<Plug>(TaboutBack)")
			end
			-- map shift-tab to inverse tab, similar as << / >>
			return replace_keycodes("<c-d>")
		end
	)
		:with_silent()
		:with_expr()
		:with_desc("聪明的<s-tab>"),

	-----------------
	--    normal   --
	-----------------

	-- ["n|gd"] = map_cr(":Telescope coc definitions"):with_silent():with_desc("跳转到定义"),
	["n|gd"] = map_cmd("<Plug>(coc-definition)"):with_silent():with_desc("跳转到定义"),
	["n|gr"] = map_cr("Telescope coc references"):with_silent():with_desc("跳转到引用"),
	-- ["n|gr"] = map_cmd("<Plug>(coc-references)"):with_silent():with_desc("跳转到引用"),
	["n|gi"] = map_cr("Telescope coc "):with_silent():with_desc("跳转到实现"),

	-- symbol renaming
	["n|<leader>rn"] = map_cmd("<Plug>(coc-rename)"):with_silent():with_desc("变量重命名"),

	-- show docs
	["n|<s-k>"] = map_callback(function()
			-- Use K to show documentation in preview window
			local cw = vim.fn.expand("<cword>")
			if vim.fn.index({ "vim", "help" }, vim.bo.filetype) >= 0 then
				vim.api.nvim_command("h " .. cw)
			elseif vim.api.nvim_eval("coc#rpc#ready()") then
				vim.fn.CocActionAsync("doHover")
			else
				vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
			end
		end)
		:with_silent()
		:with_desc("显示光标所在处的文档"),
}

-- bind.nvim_load_mapping(keymaps)

-- 设置支持的语言
vim.g.coc_global_extensions = {
	"coc-marketplace",
	"coc-highlight",
	"coc-snippets",
	"coc-dictionary",
	"coc-pairs",
	-- 非LSP插件
	"coc-json",
	"coc-yaml",
	"coc-toml", -- 配置语言
	"coc-pyright",
	"coc-clangd",
	"coc-go",
	"coc-java",
	"coc-java-intellicode",
	"coc-rls",
	"coc-sql",
	"coc-rust-analyzer", -- LSP
	"coc-vimlsp",
	"coc-docker",
	"coc-sh",
	"coc-imselect", -- 其他
    -- https://github.com/hexh250786313/coc-copilot
    -- not start
    "@hexuhua/coc-copilot",
}

return {
	-- "neoclide/coc.nvim",
	-- branch = "release",

	-- config = function()
	-- 	-- Highlight the symbol and its references on a CursorHold event(cursor is idle)
	-- 	vim.api.nvim_create_augroup("CocGroup", {})
	-- 	vim.api.nvim_create_autocmd("CursorHold", {
	-- 		group = "CocGroup",
	-- 		command = "silent call CocActionAsync('highlight')",
	-- 		desc = "Highlight symbol under cursor on CursorHold",
	-- 	})

	-- 	-- Update signature help on jump placeholder
	-- 	vim.api.nvim_create_autocmd("User", {
	-- 		group = "CocGroup",
	-- 		pattern = "CocJumpPlaceholder",
	-- 		command = "call CocActionAsync('showSignatureHelp')",
	-- 		desc = "Update signature help on jump placeholder",
	-- 	})
	-- end,
}
