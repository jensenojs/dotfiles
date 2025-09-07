--[[
模块: utils.dap

意图:
  为 nvim-dap 提供输入参数、可执行路径、目标文件与环境变量收集等小工具函数, 用于调试会话配置。

使用:
  直接 `require("utils.dap").input_args()` 等按需取用。
  导出为带 __index 的元表以适配延迟调用场景(多层函数返回)。

三层调用说明:
  由于 nvim-dap 的配置机制和延迟执行需求，本模块采用三层函数返回设计：
  
  第一层: require("utils.dap").input_file_path
    - 返回一个函数（闭包），不执行实际逻辑
    - 用于配置文件加载时的延迟绑定
  
  第二层: require("utils.dap").input_file_path()  
    - 调用第一层返回的函数
    - 返回另一个函数（更内层的闭包）
    - 仍然不执行实际逻辑
  
  第三层: require("utils.dap").input_file_path()()
    - 调用第二层返回的函数
    - 这时才真正执行 M.input_file_path() 的逻辑
    - 显示输入框并等待用户输入
  
  在 nvim-dap 配置中使用时，应该包装成函数形式：
  program = function()
      return require("utils.dap").input_file_path()()()
  end
  
  这样可以确保：
  1. 配置文件加载时不会立即执行（避免Neovim启动时弹出输入框）
  2. 调试会话启动时才请求用户输入
  3. 符合 nvim-dap 对配置值为函数的期望
]]
-- 这里定义实际的函数实现集合
local M = {}

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
	local argument_string = vim.fn.input("Program arg(s) (enter nothing to leave it null): ")
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
	return vim.fn.input('Path to executable (default to "a.out"): ', vim.fn.expand("%:p:h") .. "/a.out", "file")
end

--[[
函数: input_file_path()
作用:
  让用户输入被调试目标(程序/脚本)的文件路径, 默认当前文件。
返回:
  string 文件绝对路径。
]]
function M.input_file_path()
	return vim.fn.input("Path to debuggee (default to the current file): ", vim.fn.expand("%:p"), "file")
end

--[[
函数: get_env()
作用:
  将当前 Neovim 进程的环境变量表(vim.fn.environ())转为 { "K=V", ... } 数组形式, 便于传给调试器。
返回:
  string[] 形如 "K=V" 的字符串数组。
说明:
  - `vim.fn.environ()` 返回一个字典表; 逐项转换后插入数组。
]]
function M.get_env()
	local variables = {}
	for k, v in pairs(vim.fn.environ()) do
		table.insert(variables, string.format("%s=%s", k, v))
	end
	return variables
end

--[[
导出形式:
  返回一个带 __index 元方法的表; 外层再调用一次可返回闭包, 适配 nvim-dap 的 lazy 调用场景。
  例如: `require("utils.dap").input_args()()()` 最终调用 `M.input_args()`。
  
  使用示例：
  在 nvim-dap 配置中：
  program = function()
      return require("utils.dap").input_file_path()()()
  end
]]
return setmetatable({}, {
	__index = function(_, key)
		return function()
			return function()
				return M[key]()
			end
		end
	end,
})
