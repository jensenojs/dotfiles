-- https://github.com/milanglacier/minuet-ai.nvim
local env = require("config.environment")
if env.offline then
    return {}
end

return {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "saghen/blink.cmp" },
    event = "InsertEnter",
    opts = function()
        require("minuet").setup({
            virtualtext = {
                auto_trigger_ft = { "go", "c", "cpp", "python", "rust", "sql", "sh", "zsh", "lua", "toml" },
                keymap = {
                    accept = "<A-y>",
                    -- accept_line = '<A-a>',
                    -- accept_n_lines = '<A-z>',
                    next = "<A-]>",
                    prev = "<A-[>",
                    dismiss = "<A-e>",
                },
            },

            -- Default values
            -- provider = "codestral",
            provider = "openai_compatible",
            provider_options = {
                openai_compatible = {
                    end_point = "https://api.deepseek.com/beta/completions",
                    api_key = "DEEPSEEK_API_KEY",
                    name = "deepseek",
                    optional = {
                        max_tokens = 256,
                        top_p = 0.9,
                    },
                },
            },

            -- Default values
            -- Whether show virtual text suggestion when the completion menu
            -- (nvim-cmp or blink-cmp) is visible.
            show_on_completion_menu = false,
        })
    end,
}
