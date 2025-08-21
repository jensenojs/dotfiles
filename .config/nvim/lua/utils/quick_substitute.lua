--[[
模块: quick_substitute

意图:
  提供一个健壮、可配置、可复用的“快速替换”工具, 支持三种可视模式与普通模式.
  真实代码提供中文注释, 包含文件头/函数级/关键语句级解释.

设计要点:
  1) 模块不在 require 时执行任何副作用; 导出 setup() 与 run().
  2) 统一的分隔符选择与转义策略, 避免用户输入中包含分隔符导致 :s 语法冲突.
  3) 默认使用 \V(very nomagic) 降低正则魔法误匹配风险; 可选整词匹配与大小写策略.
  4) 范围支持: 可视选区 / 当前行 / 整个缓冲区.
  5) 关键操作尽量使用 Neovim API(如获取选区), 避免 fragile 的 :normal hack.

状态与边界:
  - 长生命周期的默认配置保存在 M.state.defaults, 通过 setup() 合并.
  - run() 是纯动作函数, 读取当前 buffer 的上下文并执行 :s.

注意:
  - 本实现使用了 \V 降低魔法字符副作用; 若需要使用“正则语义”, 可在 flags 中移除 \V 或改造 escape.
  - 交互采用 vim.fn.input 以确保同步流程简单清晰; 后续可升级为 vim.ui.input.
]]

local M = {}

-- 默认配置, 可在 setup(opts) 中覆盖
M.state = {
  defaults = {
    scope = "line",           -- 非可视模式下的默认作用域: line|buffer
    word_boundary = false,     -- 是否仅整词匹配: 用 \< 和 \> 包裹模式
    flags = "g",              -- :s 标志位, 例如: g(全局)/c(确认)/i(忽略大小写)
    smartcase = true,          -- 若启用: 根据 ignorecase/smartcase 选项推断大小写行为
    keep_selection = true,     -- 可视模式执行后是否用 :normal! gv 恢复上次选区
    nohlsearch = false,        -- 执行后是否 :noh 清理高亮
    preview = true,            -- 执行前是否预览最终命令
    delimiters = { "/", "#", "@", "|", "%", "~", "+", "=", ":", ",", ";" }, -- 候选分隔符
  },
}

-- 默认键位方案: 可视选区/当前行/整个缓冲区
local DEFAULT_KEYS = {
  visual = "<leader>s",
  line = "<leader>ss",
  buffer = "<leader>sS",
}

-- 小工具: 判断是否处于任意可视模式
local function in_visual_mode()
  -- vim.fn.mode() 返回当前模式标识, 常见: "n" 普通, "i" 插入, "v" 字符可视, "V" 行可视, "\022" 块可视(CTRL-V)
  local m = vim.fn.mode()
  return m == "v" or m == "V" or m == "\022"
end

-- 小工具: 获取可视选区的起止坐标, 统一为 0-based 行列
-- 说明: nvim_buf_get_mark(0, "<") / (">") 取得 '< 与 '> 两个标记
local function get_visual_range()
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<")) -- 1-based 行, 0-based 列
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
  -- 将行统一为 0-based; 注意: srow/erow 是 1-based
  srow, erow = srow - 1, erow - 1
  -- 归一化: 保证 (srow,scol) 不大于 (erow,ecol)
  if srow > erow or (srow == erow and scol > ecol) then
    srow, erow, scol, ecol = erow, srow, ecol, scol
  end
  return srow, scol, erow, ecol
end

-- 小工具: 读取选中文本(二维范围), 返回行数组
local function get_selected_lines(buf, srow, scol, erow, ecol)
  -- nvim_buf_get_text: [start_row, start_col, end_row, end_col) 半开区间
  local lines = vim.api.nvim_buf_get_text(buf, srow, scol, erow, ecol, {})
  return lines
end

-- 小工具: 选择分隔符. 从 candidates 中挑选一个不出现在 old/new 中的字符; 否则询问用户
local function choose_delimiter(oldword, newword, candidates)
  for _, d in ipairs(candidates) do
    if not string.find(oldword or "", d, 1, true) and not string.find(newword or "", d, 1, true) then
      return d
    end
  end
  -- 回退: 同步输入一个单字符分隔符
  local input = vim.fn.input("分隔符不可用, 请输入一个不含于两端字符串的单字符: ")
  if type(input) == "string" and #input >= 1 then
    return string.sub(input, 1, 1)
  end
  -- 最后兜底: 使用 /, 但这可能碰撞; 仍然可用 escape 缓解
  return "/"
end

-- 小工具: 根据配置决定 flags 字符串
local function resolve_flags(flags, smartcase)
  local f = flags or ""
  -- smartcase: 仅当 ignorecase 配合 smartcase 启用时, 让 Vim 自己决定, 我们不强加 i
  -- 若用户已显式包含 i/I, 则尊重用户
  if smartcase then
    -- 不做额外处理, 交给 'ignorecase' 与 'smartcase' 共同生效
  end
  return f
end

-- 小工具: 构造 :s 的范围字符串
local function build_range(has_visual, scope)
  if has_visual then
    return "'<,'>" -- 对应上次可视选区
  end
  if scope == "line" then
    return ".,." -- 显式限定当前行
  elseif scope == "buffer" then
    return "%"    -- 整个缓冲区
  else
    -- 未知 scope 时退回当前行
    return ".,."
  end
end

-- 小工具: 构造 \V + 整词边界的模式串, 并对分隔符与反斜杠做转义
local function build_pattern(oldword, delimiter, word_boundary)
  -- 在 \V very nomagic 下, 仅 \\ 保持转义意义; 其他大多字符以字面含义匹配
  local pat = vim.fn.escape(oldword, "\\" .. delimiter)
  if word_boundary then
    -- 注意: 在 \V 语境下, \\< 和 \\> 仍具备“单词边界”的特殊意义
    pat = "\\<" .. pat .. "\\>"
  end
  -- 前置 \V 降低魔法风险
  return "\\V" .. pat
end

-- 小工具: 构造替换串, 需要转义 & 与 \\ 以及分隔符本身
local function build_replacement(newword, delimiter)
  return vim.fn.escape(newword, "\\" .. delimiter .. "&")
end

-- 小工具: 从选区推导默认 oldword. 多行选区时取第一行的非空子串; 若为空则退回 <cword>
local function derive_default_oldword_from_selection(lines)
  if #lines == 0 then
    return nil
  end
  local s = lines[1] or ""
  -- 去除前后空白, 避免默认值过于“宽松”
  s = (s:gsub("^%s+", ""):gsub("%s+$", ""))
  if s == "" then
    return nil
  end
  -- 若过长, 仅取前 80 字符作为默认值, 防止 input 框显示不友好
  if #s > 80 then
    s = string.sub(s, 1, 80)
  end
  return s
end

-- 小工具: 统一的交互输入. 目前用 vim.fn.input 实现同步流程; 后续可替换为 vim.ui.input
local function prompt(label, default)
  local prompt_text = label .. (default and (" [默认: " .. default .. "]") or "") .. ": "
  local v = vim.fn.input(prompt_text)
  if v == nil or v == "" then
    return default or ""
  end
  return v
end

-- 导出: 设置默认配置与可选键位绑定
-- opts.keys 可选:
--   { visual = "<leader>s", line = "<leader>ss", buffer = "<leader>sS" }
function M.setup(opts)
  -- 合并配置(浅拷贝足够, 嵌套较浅)
  if type(opts) == "table" then
    for k, v in pairs(opts) do
      M.state.defaults[k] = v
    end
  end

  -- 键位注册策略:
  --  - 若 opts.keys == false, 明确禁用默认键位
  --  - 若 opts.keys 为表, 使用该表
  --  - 否则使用 DEFAULT_KEYS
  local provided_keys = opts and opts.keys
  if provided_keys ~= false then
    local keys = provided_keys or DEFAULT_KEYS
    if keys then
      if keys.visual then
        vim.keymap.set({"v", "x"}, keys.visual, function()
          M.run({})
        end, { desc = "快速替换: 作用于可视选区" })
      end
      if keys.line then
        vim.keymap.set("n", keys.line, function()
          M.run({ scope = "line" })
        end, { desc = "快速替换: 当前行" })
      end
      if keys.buffer then
        vim.keymap.set("n", keys.buffer, function()
          M.run({ scope = "buffer" })
        end, { desc = "快速替换: 整个缓冲区" })
      end
    end
  end
end

-- 导出: 核心执行函数
-- opts:
--   - scope: "line"|"buffer" (非可视模式时有效)
--   - word_boundary: boolean
--   - flags: string, 如 "g", "gc", "gi" 等
--   - smartcase: boolean
--   - keep_selection: boolean
--   - nohlsearch: boolean
--   - preview: boolean
function M.run(opts)
  opts = opts or {}
  local cfg = M.state.defaults

  -- 计算最终配置(浅合并)
  local scope          = opts.scope ~= nil and opts.scope or cfg.scope
  local word_boundary  = opts.word_boundary ~= nil and opts.word_boundary or cfg.word_boundary
  local flags          = resolve_flags(opts.flags ~= nil and opts.flags or cfg.flags, opts.smartcase ~= nil and opts.smartcase or cfg.smartcase)
  local keep_selection = opts.keep_selection ~= nil and opts.keep_selection or cfg.keep_selection
  local nohlsearch     = opts.nohlsearch ~= nil and opts.nohlsearch or cfg.nohlsearch
  local preview        = opts.preview ~= nil and opts.preview or cfg.preview
  local delimiters     = cfg.delimiters

  local has_visual = in_visual_mode()
  local buf = 0 -- 当前 buffer

  -- 推导默认 oldword
  local default_old
  local srow, scol, erow, ecol
  if has_visual then
    srow, scol, erow, ecol = get_visual_range()
    local lines = get_selected_lines(buf, srow, scol, erow, ecol)
    default_old = derive_default_oldword_from_selection(lines)
  else
    -- 非可视: 取光标下单词作为默认
    default_old = vim.fn.expand("<cword>")
  end

  -- 交互获取 old/new. 允许用户清空后回退默认值
  local oldword = prompt("要替换的旧字符串", default_old)
  if oldword == nil or oldword == "" then
    vim.notify("未提供旧字符串, 已取消", vim.log.levels.INFO, { title = "quick_substitute" })
    return
  end
  local newword = prompt("替换成的新字符串", "")

  -- 选择分隔符并构造模式/替换串
  local delimiter = choose_delimiter(oldword, newword, delimiters)
  local pattern = build_pattern(oldword, delimiter, word_boundary)
  local replacement = build_replacement(newword, delimiter)

  -- 构造范围
  local range = build_range(has_visual, scope)

  -- 预览执行命令(仅展示, 便于用户理解): 注意不要泄漏过长字符串
  local preview_cmd = string.format("%ss%s%s%s%s%s", range, delimiter, pattern, delimiter, replacement, delimiter .. flags)
  if preview then
    vim.notify("即将执行: :" .. preview_cmd, vim.log.levels.INFO, { title = "quick_substitute" })
  end

  -- 执行替换
  vim.cmd(preview_cmd)

  -- 可选恢复可视选区
  if has_visual and keep_selection then
    -- gv: 重新选择上一次可视选区, 比单纯 :normal! v 更准确
    vim.cmd("normal! gv")
  end

  if nohlsearch then
    vim.cmd("noh")
  end
end

return M
