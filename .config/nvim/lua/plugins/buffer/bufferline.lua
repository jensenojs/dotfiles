-- https://github.com/akinsho/bufferline.nvim
-- 缓冲区/标签栏。使用 tabs 模式模拟原生 tabline
-- https://github.com/roobert/bufferline-cycle-windowless.nvim
-- 需要么? 还是算了
return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	main = "bufferline",
	opts = function()
		local icons = require("utils.icons").get("ui")
		
		-- 获取编辑器背景色
		local function get_hl_color(group, attr)
			local hl = vim.api.nvim_get_hl(0, { name = group })
			if hl and hl[attr] then
				return string.format("#%06x", hl[attr])
			end
			return nil
		end
		
		-- 颜色变暗函数
		local function darken(hex, amount)
			local r = tonumber(hex:sub(2, 3), 16)
			local g = tonumber(hex:sub(4, 5), 16)
			local b = tonumber(hex:sub(6, 7), 16)
			r = math.max(0, math.floor(r * (1 - amount)))
			g = math.max(0, math.floor(g * (1 - amount)))
			b = math.max(0, math.floor(b * (1 - amount)))
			return string.format("#%02x%02x%02x", r, g, b)
		end
		
		-- 透明背景适配：使用 NONE 让背景透明
		local bg = "NONE" -- 透明背景
		local fg = get_hl_color("Normal", "fg") or "#cdd6f4"
		local bg_inactive = "NONE" -- 未选中也透明
		local bg_visible = "NONE" -- 可见也透明
		local fg_inactive = darken(fg, 0.4) -- 未选中标签文字（暗40%）
		local accent = get_hl_color("String", "fg") or "#a6e3a1" -- 高亮色
		
		return {
			options = {
				number = nil,
				modified_icon = icons.Modified,
				buffer_close_icon = icons.Close,
				left_trunc_marker = icons.Left,
				right_trunc_marker = icons.Right,
				max_name_length = 20,
				max_prefix_length = 13,
				tab_size = 20,
				color_icons = true,
				show_buffer_icons = true,
				show_buffer_close_icons = true,
				show_close_icon = true,
				show_tab_indicators = true,
				enforce_regular_tabs = false,
				persist_buffer_sort = true,
				always_show_bufferline = true,
				separator_style = "slope",

				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
			},
			highlights = {
				fill = {
					bg = bg, -- 填充区域透明
				},
				-- 未选中标签
				background = {
					fg = fg_inactive,
					bg = bg_inactive,
				},
				-- 可见但未聚焦的标签
				buffer_visible = {
					fg = fg,
					bg = bg_visible,
				},
				-- 选中的标签（当前激活）
				buffer_selected = {
					fg = accent, -- 用高亮色
					bg = bg,     -- 透明背景
					bold = true,
					italic = false,
					underline = true, -- 加下划线区分
				},
				-- 分隔符（透明）
				separator = {
					fg = bg,
					bg = bg,
				},
				separator_visible = {
					fg = bg,
					bg = bg,
				},
				separator_selected = {
					fg = bg,
					bg = bg,
				},
				-- 关闭按钮
				close_button = {
					fg = fg_inactive,
					bg = bg_inactive,
				},
				close_button_visible = {
					fg = fg,
					bg = bg_visible,
				},
				close_button_selected = {
					fg = accent,
					bg = bg,
				},
				-- 指示器（选中标签的左侧竖线）
				indicator_selected = {
					fg = accent,
					bg = bg,
				},
			},
		}
	end,
}
