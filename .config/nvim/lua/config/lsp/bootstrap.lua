-- 作用: LSP 运行时初始化
-- 注意: 此文件仅处理 LSP 的核心初始化, 不涉及插件增强 (如 blink.cmp, telescope 等)
-- LSP bootstrap autocommands group (idempotent and discoverable)
-- 全局 LSP 命令
local api, lsp, diagnostic = vim.api, vim.lsp, vim.diagnostic
local buf_util = require("utils.buf")

-- 模块导出
local M = {}

-- 存储所有 LSP 服务器配置和它们的 filetypes
-- 结构: { [server_name] = { config = {...}, filetypes = {...} } }
M._server_configs = {}

local LSP_BOOTSTRAP = vim.api.nvim_create_augroup("lsp.bootstrap", {
	clear = true,
})

local ui = {
	border = "rounded", -- 圆角
	zindex = 50, -- 保证在普通浮动窗口之上
	max_width = math.floor(vim.o.columns * 0.8),
	max_height = math.floor(vim.o.lines * 0.7),
}

local function should_bootstrap(bufnr)
	return buf_util.is_real_file(bufnr, {
		require_modifiable = true,
	})
end

-- 注册所有 LSP 服务器配置
-- 注意: vim.lsp.enable() 需要配置先通过 vim.lsp.config() 注册
local function register_lsp_configs()
	local ok_list, servers = pcall(require, "config.lsp.enable-list")
	if not ok_list or type(servers) ~= "table" then
		vim.notify("无法加载 LSP 服务器列表", vim.log.levels.ERROR)
		return
	end
	
	-- LSP 配置文件目录
	local lsp_config_dir = vim.fn.stdpath("config") .. "/lsp/"
	
	for _, server_name in ipairs(servers) do
		-- 加载服务器配置文件
		local config_file = lsp_config_dir .. server_name .. ".lua"
		if vim.fn.filereadable(config_file) == 1 then
			-- 使用 dofile 加载配置文件
			local ok_conf, config = pcall(dofile, config_file)
			if ok_conf and config then
				-- 保存配置和 filetypes 信息
				M._server_configs[server_name] = {
					config = config,
					filetypes = config.filetypes or {},
				}
				
				-- 注册配置
				local ok_reg = pcall(vim.lsp.config, server_name, config)
				if not ok_reg then
					vim.notify("注册 LSP 配置失败: " .. server_name, vim.log.levels.WARN)
				end
			else
				vim.notify("加载 LSP 配置失败: " .. server_name, vim.log.levels.WARN)
			end
		else
			vim.notify("LSP 配置文件不存在: " .. config_file, vim.log.levels.WARN)
		end
	end
end

-- 在模块加载时立即注册所有 LSP 配置
register_lsp_configs()

local lsp_bootstrap_done = false

-- 根据 filetype 获取匹配的 LSP 服务器列表
-- @param filetype string|nil buffer 的 filetype
-- @return table 匹配的服务器名称列表
local function get_servers_for_filetype(filetype)
	local matching_servers = {}
	
	if not filetype or filetype == "" then
		return matching_servers
	end
	
	for server_name, server_info in pairs(M._server_configs) do
		local filetypes = server_info.filetypes or {}
		-- 如果 server 没有指定 filetypes，默认启用（向后兼容）
		if #filetypes == 0 then
			matching_servers[#matching_servers + 1] = server_name
		else
			-- 检查 filetype 是否匹配
			for _, ft in ipairs(filetypes) do
				if ft == filetype then
					matching_servers[#matching_servers + 1] = server_name
					break
				end
			end
		end
	end
	
	return matching_servers
end

lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, ui)
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, ui)

diagnostic.config({
	float = vim.tbl_extend("force", ui, {
		header = "💡 诊断",
		source = "if_many",
	}),
	virtual_text = {
		prefix = '●',
		spacing = 4,
		source = "if_many",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
})

api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", {
	desc = "Alias to `:checkhealth vim.lsp`",
})

api.nvim_create_user_command("LspLog", function()
	vim.cmd(string.format("tabnew %s", lsp.get_log_path()))
end, {
	desc = "Opens the Nvim LSP client log.",
})

local function complete_server(arg)
	local ok, servers = pcall(require, "config.lsp.enable-list")
	if not ok or type(servers) ~= "table" then
		return {}
	end
	local items = {}
	for _, name in ipairs(servers) do
		if name:sub(1, #arg) == arg then
			table.insert(items, name)
		end
	end
	return items
end

api.nvim_create_user_command("LspRestart", function(info)
	local ok_list, servers = pcall(require, "config.lsp.enable-list")
	servers = ok_list and servers or {}
	local whitelist = {}
	for _, s in ipairs(servers) do
		whitelist[s] = true
	end

	local targets = info.fargs
	for _, name in ipairs(targets) do
		if not whitelist[name] then
			vim.notify(("Invalid server name '%s'"):format(name), vim.log.levels.WARN, {
				title = "LspRestart",
			})
		else
			local ok_disable = pcall(vim.lsp.enable, name, false)
			if not ok_disable then
				for _, c in
					ipairs(vim.lsp.get_clients({
						name = name,
					}))
				do
					pcall(c.stop, c, true)
				end
			end
		end
	end

	vim.defer_fn(function()
		for _, name in ipairs(targets) do
			pcall(vim.lsp.enable, name)
		end
	end, 500)
end, {
	desc = "Restart the given client(s)",
	nargs = "+",
	complete = complete_server,
})

-- 为已经打开的 buffers 启用 LSP
-- 解决 lazy.nvim 加载后 LSP 不自动附加的问题
-- 因为当此脚本在 lazy.nvim 加载后执行时，文件可能已经打开，filetype 已设置
-- FileType 事件不会再触发，所以需要手动为已打开的 buffers 启用 LSP
local function enable_lsp_for_opened_buffers()
	local bufs = vim.api.nvim_list_bufs()
	local buf_count = 0
	local server_count = 0
	
	for _, buf in ipairs(bufs) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			if should_bootstrap(buf) then
				local filetype = vim.bo[buf].filetype
				local matching_servers = get_servers_for_filetype(filetype)
				
				for _, server_name in ipairs(matching_servers) do
					vim.lsp.enable(server_name, { bufnr = buf })
					server_count = server_count + 1
				end
				
				if #matching_servers > 0 then
					buf_count = buf_count + 1
				end
			end
		end
	end
	
	if server_count > 0 then
		vim.notify(string.format("已为 %d 个 buffer 启用 %d 个 LSP server", buf_count, server_count), vim.log.levels.INFO)
	end
end

-- 在文件打开时启用 LSP 服务器
-- 注意: 此 autocmd 在 lazy.nvim 加载后注册，确保 neotest 等插件已就绪
api.nvim_create_autocmd("FileType", {
	group = LSP_BOOTSTRAP,
	desc = "Enable configured LSP clients for buffer",
	callback = function(args)
		if not should_bootstrap(args.buf) then
			return
		end
		
		-- 根据 filetype 只启用匹配的 LSP 服务器
		local filetype = vim.bo[args.buf].filetype
		local matching_servers = get_servers_for_filetype(filetype)
		
		for _, server_name in ipairs(matching_servers) do
			vim.lsp.enable(server_name, { bufnr = args.buf })
		end
	end,
})

-- 导出函数供外部调用
M = M or {}
M.enable_lsp_for_opened_buffers = enable_lsp_for_opened_buffers
M._get_servers_for_filetype = get_servers_for_filetype  -- 用于测试和调试

-- 确保注册 LspAttach 相关自动命令与按键
local ok, mod = pcall(require, "config.lsp.attach")
if not ok then
	vim.notify("Failed to load config.lsp.attach", vim.log.levels.ERROR)
end

return M
