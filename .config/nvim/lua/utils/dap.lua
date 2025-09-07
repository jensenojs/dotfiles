--[[
模块: utils.dap

意图:
  为 nvim-dap 提供输入参数、可执行路径、目标文件与环境变量收集等小工具函数, 用于调试会话配置。

使用:
  推荐：使用一层闭包 API（延迟求值），可直接写入 nvim-dap 配置：
    program = require('utils.dap').fn.input_exec_path()
    args    = require('utils.dap').fn.input_args()

  同时也提供“直接函数”形式（立即求值），便于在脚本中独立调用：
    local args_array = require('utils.dap').input_args()
]]
-- 这里定义实际的函数实现集合
local M = {}

-- 安全输入: 捕捉 <C-c>/中断并静默返回
local function safe_input(prompt, default, completion)
	local ok, result = pcall(vim.fn.input, prompt, default, completion)
	if not ok then
		return nil
	end
	if type(result) ~= "string" then
		return nil
	end
	return result
end

--[[
函数: input_args()
作用:
  同步读取用户输入的一串命令行参数, 再按空格分割为数组.
返回:
  string[] 参数数组, 空输入时返回空数组。
注意:
  - `vim.fn.input(prompt)` 会在命令行提示用户输入; 第三个参数可指定补全类型(此处无需)。
  - `vim.fn.split(str, " ", true)` 使用 Lua 模式为字面空格分割; 第三个参数 `true` 表示忽略空字段。
]]
function M.input_args()
	local argument_string = safe_input("Program arg(s) (enter nothing to leave it null): ") or ""
	return vim.fn.split(argument_string, " ", true)
end

--[[
函数: input_exec_path()
作用:
  让用户输入可执行文件路径, 提供当前文件同目录下的 "a.out" 作为默认值.
返回:
  string 可执行文件绝对路径.
注意:
  - 第三个参数传 "file" 让输入框获得文件路径补全能力。
  - `vim.fn.expand("%:p:h")` 取当前缓冲区文件的目录; 拼接默认的 a.out。
]]
function M.input_exec_path()
	local default_path = vim.fn.expand("%:p:h") .. "/a.out"
	local path = safe_input('Path to executable (default to "a.out"): ', default_path, "file")
	return (path and #path > 0) and path or nil
end

--[[
函数: input_file_path()
作用:
  让用户输入被调试目标(程序/脚本)的文件路径, 默认当前文件。
返回:
  string 文件绝对路径。
]]
function M.input_file_path()
	local default_file = vim.fn.expand("%:p")
	local path = safe_input("Path to debuggee (default to the current file): ", default_file, "file")
	return (path and #path > 0) and path or nil
end

--[[
函数: get_env()
作用:
  将当前 Neovim 进程的环境变量表(vim.fn.environ())转为 { "K=V", ... } 数组形式, 便于传给调试器。
返回:
  string[] 形如 "K=V" 的字符串数组.
]]
function M.get_env()
  local variables = {}
  for k, v in pairs(vim.fn.environ()) do
    table.insert(variables, string.format("%s=%s", k, v))
  end
  return variables
end

--[[
一层闭包 API：`require('utils.dap').fn.<name>()`
返回一个可直接赋给 nvim-dap 配置字段的函数，便于延迟求值.
]]
local FN = {}

function FN.input_args()
	return function()
		return M.input_args()
	end
end

function FN.input_exec_path()
	return function()
		return M.input_exec_path()
	end
end

function FN.input_file_path()
	return function()
		return M.input_file_path()
	end
end

function FN.get_env()
  return function()
    return M.get_env()
  end
end

-- 导出：直观函数 + 闭包接口
M.fn = FN
return M
