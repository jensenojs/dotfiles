-- https://github.com/ravitemer/mcphub.nvim
-- MCP Hub integration: bridge Neovim with external MCP servers defined in ~/.config/mcphub/servers.json
return {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim", { "Joakker/lua-json5", build = "./install.sh" } },
    build = "npm install -g mcp-hub@latest",
    event = "VeryLazy",
    opts = {
        -- 1. 动态构建绝对路径，不依赖 expand，也不写死用户名
        config = (os.getenv("HOME") or "") .. "/.config/mcphub/servers.json",

        -- 2. 具备回退机制的解析器 (Defensive Coding)
        json_decode = function(str)
            -- 尝试安全加载 json5 模块
            local ok, json5 = pcall(require, "json5")

            if ok then
                -- A计划: 如果加载成功，使用 json5 解析 (支持注释、尾随逗号)
                -- 注意: json5.parse 可能会抛错，也可以再包一层 pcall，视严谨程度而定
                return json5.parse(str)
            else
                -- B计划 (Fallback): 模块未找到，降级使用 Neovim 内置标准解析器
                -- 这样即使插件没装好，Neovim 也能正常启动，只是不能写注释了
                return vim.json.decode(str)
            end
        end,

        auto_approve = function(params)
            local readonly_servers = {
                ["ast-grep"] = true,
                ["context7"] = true,
                ["deepwiki"] = true,
                ["gh_grep"] = true,
                ["markitdown"] = true,
                ["minimax-coding-plan"] = true,
                ["sequential-thinking"] = true,
                ["tavily"] = true,
            }

            -- mcphub 自身的 introspection 工具是只读的, 可以直接放行
            if params.server_name == "mcphub" then
                return true
            end

            -- 纯查询/只读类服务器, 默认自动通过
            if readonly_servers[params.server_name] then
                return true
            end

            -- 若在 servers.json 或 UI 中对某些工具/服务器显式配置了 autoApprove, 则尊重该配置
            if params.is_auto_approved_in_server then
                return true
            end

            -- 其他情况返回 nil, 让系统走默认逻辑(弹确认窗口)
        end,
        -- 其余选项基本采用插件默认值, 这里只开 avante 扩展
        extensions = {
            avante = {
                -- 将 MCP 服务器的 prompts 暴露为 Avante 的 /mcp:server:prompt 命令
                make_slash_commands = true,
            },
        },
    },
}
