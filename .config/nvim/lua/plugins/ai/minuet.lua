-- https://github.com/milanglacier/minuet-ai.nvim
-- 仅启用“虚拟文本”前端, 默认不接入 blink 源, 避免与候选弹窗(PUM)互相干扰。
-- 如需接入 blink 源, 请参考同目录 README.md“可选：接入 blink 源(手动触发推荐)”。
return {
	"milanglacier/minuet-ai.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "saghen/blink.cmp" },
	config = function()
		require("minuet").setup({
			virtualtext = {
				auto_trigger_ft = { "go", "c", "cpp", "python", "rust", "sql" },
				keymap = {
					accept = "<A-y>",
					-- accept_line = '<A-a>',
					-- accept_n_lines = '<A-z>',
					next = "<A-]>",
					prev = "<A-[>",
					dismiss = "<A-e>",
				},
			},

			provider = "codestral",

			-- Default values
			-- Whether show virtual text suggestion when the completion menu
			-- (nvim-cmp or blink-cmp) is visible.
			show_on_completion_menu = false,
		})

		-- 说明：Tab 行为已在 `blink.cmp` 中统一维护，Minuet 不再在插入模式绑定 <Tab>。
		-- 如需在未启用 blink 的场景下启用旧逻辑，请参考下方“已弃用示例”注释块。

		-- local api = vim.api
		-- 如果希望在“未启用 blink.cmp”时依然在插入模式用 接受虚拟文本，则：
		-- 请把 has_blink = pcall(require, 'blink-cmp') 修正为 pcall(require, 'blink.cmp')
		-- “动态检测该 buffer 是否已应用 blink 映射”，即通过 vim.api.nvim_buf_get_keymap(buf, 'i') 查找 desc == 'blink.cmp'，再决定是否设置插入态 （因为 blink 是 InsertEnter 懒加载，光查 require 时机可能不准）。
		-- 目前我们已把逻辑放在 blink.lua，因此最简单、最干净的方案是完全移除 minuet 里的 插入态映射。

		-- local ok_vt, vt = pcall(require, 'minuet.virtualtext')
		-- local has_blink = pcall(require, 'blink-cmp')

		-- -- Buffer-local <Tab> 映射：在 LspAttach 时注册，确保时序与作用域
		-- local minuet_attach_grp = vim.api.nvim_create_augroup('minuet.virtualtext.attach', {
		--     clear = true
		-- })

		-- local function set_tabmap_for_virtualtext(bufnr)
		--     if not ok_vt or has_blink then
		--         return
		--     end
		--     pcall(vim.keymap.del, 'i', '<Tab>', {
		--         buffer = bufnr
		--     })

		--     vim.keymap.set('i', '<Tab>', function()
		--         -- 1) AI 态：接受 Minuet 虚拟文本
		--         if vt.action.is_visible() then
		--             vt.action.accept()
		--             return
		--         end
		--         -- 2) 候选态：PUM 可见则选下一项
		--         if vim.fn.pumvisible() == 1 then
		--             api.nvim_feedkeys(api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
		--             return
		--         end
		--         -- 3) 跳出态：尝试 tabout（若安装了 tabout.nvim）
		--         if vim.fn.mapcheck('<Plug>(Tabout)', 'i') ~= '' then
		--             api.nvim_feedkeys(api.nvim_replace_termcodes('<Plug>(Tabout)', true, true, true), 'm', false)
		--             return
		--         end
		--         -- 4) 普通态：插入制表符
		--         api.nvim_feedkeys(api.nvim_replace_termcodes('\t', true, false, true), 'n', false)
		--     end, {
		--         buffer = bufnr,
		--         desc = '[minuet.virtualtext] Tab accept or fallback (buffer-local)',
		--         silent = true
		--     })

		-- end

		-- api.nvim_create_autocmd('LspAttach', {
		--     group = minuet_attach_grp,
		--     callback = function(ev)
		--         set_tabmap_for_virtualtext(ev.buf)
		--     end,
		--     desc = '[minuet.virtualtext] Tab 接受'
		-- })

		-- -- 兜底：对当前已加载的 buffer 也注册一次（避免错过早期的 LspAttach）
		-- for _, b in ipairs(api.nvim_list_bufs()) do
		--     if api.nvim_buf_is_loaded(b) then
		--         set_tabmap_for_virtualtext(b)
		--     end
		-- end
	end,
}
