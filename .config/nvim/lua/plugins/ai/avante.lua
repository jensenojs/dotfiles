-- https://github.com/yetone/avante.nvim
return {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    event = "VeryLazy",
    version = false,

    opts = function()
        local Config = require("avante.config")

        local function dual_boost_on()
            local current_dual = Config.dual_boost or {}
            Config.override({
                mode = "legacy",
                dual_boost = vim.tbl_extend("force", current_dual, {
                    enabled = true,
                }),
            })
        end

        local function dual_boost_off()
            local current_dual = Config.dual_boost or {}
            Config.override({
                mode = "agentic",
                dual_boost = vim.tbl_extend("force", current_dual, {
                    enabled = false,
                }),
            })
        end

        pcall(vim.api.nvim_create_user_command, "AvanteDualBoostOn", function()
            dual_boost_on()
        end, {})

        pcall(vim.api.nvim_create_user_command, "AvanteDualBoostOff", function()
            dual_boost_off()
        end, {})

        pcall(vim.api.nvim_create_user_command, "AvanteDualBoostReview", function(cmd_opts)
            dual_boost_on()
            require("avante.api").full_view_ask({
                new_chat = true,
                question = cmd_opts.args ~= "" and cmd_opts.args or nil,
            })
        end, { nargs = "*" })

        return {
            instructions_file = "AGENTS.md",
            system_prompt = function()
                local parts = {}

                -- 1) OpenCode 全局 AGENTS.md: 作为真正的 System Prompt 基底
                local global_agents = vim.fn.expand("~/.config/opencode/AGENTS.md")
                if vim.fn.filereadable(global_agents) == 1 then
                    local ok_file, lines = pcall(vim.fn.readfile, global_agents)
                    if ok_file and lines and #lines > 0 then
                        table.insert(parts, table.concat(lines, "\n"))
                    end
                end

                -- 2) 项目级额外规则: utils.ai_instructions.load_extra(cwd)
                local ok_utils, utils = pcall(require, "utils")
                if ok_utils and utils and utils.ai_instructions and utils.ai_instructions.load_extra then
                    local root = vim.fn.getcwd()
                    local extra = utils.ai_instructions.load_extra(root)
                    if extra and extra ~= "" then
                        table.insert(parts, extra)
                    end
                end

                -- 3) MCP Hub: 当前可用服务器/工具的说明, 辅助 LLM 选择 MCP 工具
                local ok_hub, mcphub = pcall(require, "mcphub")
                if ok_hub and mcphub and mcphub.get_hub_instance then
                    local hub = mcphub.get_hub_instance()
                    if hub and hub.get_active_servers_prompt then
                        local ok_prompt, prompt = pcall(hub.get_active_servers_prompt, hub)
                        if ok_prompt and prompt and prompt ~= "" then
                            table.insert(parts, prompt)
                        end
                    end
                end

                if #parts == 0 then
                    return nil
                end
                return table.concat(parts, "\n\n")
            end,
            custom_tools = function()
                local ok_ext, ext = pcall(require, "mcphub.extensions.avante")
                if not ok_ext or not ext or not ext.mcp_tool then
                    return {}
                end
                return { ext.mcp_tool() }
            end,
            disabled_tools = {
                "list_files",
                "search_files",
                "read_file",
                "create_file",
                "rename_file",
                "delete_file",
                "create_dir",
                "rename_dir",
                "delete_dir",
                "bash",
            },
            behaviour = {
                enable_cursor_planning_mode = true,
                enable_fastapply = true, -- Enable Fast Apply feature
            },
            suggestion = {
                enabled = false,
            },
            provider = "minimax",
            dual_boost = {
                enabled = false,
                first_provider = "minimax",
                second_provider = "deepseek",
                prompt = "根据以下两个参考输出，生成一个结合两者元素但反映您自己判断和独特视角的响应。不要提供任何解释，只需直接给出响应。参考输出 1: [{{provider1_output}}], 参考输出 2: [{{provider2_output}}]",
                timeout = 60000,
            },
            providers = {
                minimax = {
                    __inherited_from = "openai",
                    endpoint = "https://api.minimaxi.com/v1",
                    api_key_name = "MINIMAX_API_KEY",
                    model = "MiniMax-M2",
                    extra_request_body = {
                        reasoning_split = true,
                    },
                },
                moonshot = {
                    endpoint = "https://api.moonshot.cn/v1",
                    api_key_name = "KIMI_API_KEY",
                    model = "kimi-k2-0905-preview",
                    timeout = 30000, -- 超时时间（毫秒）
                    extra_request_body = {
                        temperature = 0.65,
                        max_tokens = 32768,
                    },
                },
                deepseek = {
                    __inherited_from = "openai",
                    api_key_name = "DEEPSEEK_API_KEY",
                    endpoint = "https://api.deepseek.com",
                    model = "deepseek-reasoner",
                },
                morph = {
                    model = "auto",
                },
            },
            rag_service = {
                enabled = false,
                host_mount = os.getenv("HOME"),
                runner = "docker",
                -- 这里改为基于本地 Ollama 的默认模板, 不依赖 OpenAI/Gemini 等闭源云服务
                llm = {
                    provider = "ollama",
                    endpoint = "http://localhost:11434",
                    api_key = "", -- Ollama 通常不需要 API key
                    -- 具体模型名称需与你在 Ollama 中实际拉取的模型一致, 例如 "llama2"/"mistral"/"qwen2" 等
                    model = "llama2",
                    extra = nil,
                },
                embed = {
                    provider = "ollama",
                    endpoint = "http://localhost:11434",
                    api_key = "", -- Ollama 通常不需要 API key
                    -- 建议使用专门的向量模型, 如 "nomic-embed-text" 等
                    model = "nomic-embed-text",
                    extra = {
                        embed_batch_size = 10,
                    },
                },
                docker_extra_args = "",
            },
        }
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-telescope/telescope.nvim", -- 用于文件选择器提供者 telescope
        "nvim-tree/nvim-web-devicons", -- 或 echasnovski/mini.icons
        {
            -- 支持图像粘贴
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- Windows 用户必需
                    use_absolute_path = true,
                },
            },
        },
        {
            -- 如果您有 lazy=true，请确保正确设置
            "MeanderingProgrammer/render-markdown.nvim",
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
