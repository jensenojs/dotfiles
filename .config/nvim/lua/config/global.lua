--[[
 模块: config.global
 
 意图:
   聚合与路径/目录相关的全局只读变量。
   平台特征位来自 config.env, 以 env 为单一真源, 避免重复探测。
 ]]
 
 local env = require("config.env")
 -- 使用只读代理: 数据存于局部 data, 对外通过 __index 读取, 任何写入给出清晰提示
 local function compute()
 	local t = {}
 	-- 平台特征位: 引用 env, 不重复探测
 	t.is_mac = env.is_mac
 	t.is_linux = env.is_linux
 	t.is_windows = env.is_windows
 	t.is_wsl = env.is_wsl
 	-- 路径聚合
 	t.vim_path = vim.fn.stdpath("config")
 	local path_sep = t.is_windows and "\\" or "/"
 	local home = t.is_windows and os.getenv("USERPROFILE") or os.getenv("HOME")
 	t.cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
 	t.modules_dir = t.vim_path .. path_sep .. "modules"
 	t.home = home
 	t.data_dir = string.format("%s/site/", vim.fn.stdpath("data"))
 	return t
 end
 
 local data = compute()
 local global = {}
 
 -- 兼容旧接口: 允许显式重算, 但外部仍不可写字段
 function global:load_variables()
 	data = compute()
 end
 
 setmetatable(global, {
 	__index = function(_, k) return data[k] end,
 	__newindex = function(_, k, _)
 		error(string.format("config.global is read-only (attempt to write key '%s'). Use config.env or local variables.", tostring(k)), 2)
 	end,
 	__metatable = false,
 })
 
 return global
