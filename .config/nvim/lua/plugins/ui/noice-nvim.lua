-- https://github.com/folke/noice.nvim
-- 覆写了很多neovim原本UI的插件，很大幅度地提升了美观性
return {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        -- add any options here
    },
    dependencies = { -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim", -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify"},

    config = function()
        require("noice").setup({

            -- 过滤器
            -- routes = {{
            --     filter = { -- Avoid all messages with kind ""
            --         event = "msg_show",
            --         kind = ""
            --     },
            --     opts = {
            --         skip = true
            --     }
            -- }},

            lsp = {
                -- 据说是影响性能, 把它关掉叭
                progress = {
                    enabled = false
                },

                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true
                }
            },

            -- you can enable a preset for easier configuration
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
                command_palette = true, -- position the cmdline and popupmenu together
                long_message_to_split = true, -- long messages will be sent to a split
                inc_rename = false, -- enables an input dialog for inc-rename.nvim
                lsp_doc_border = false -- add a border to hover docs and signature help
            },

            messages = {
                enabled = true,
                view = "notify",
                view_error = "notify",
                view_warn = "notify",
                view_history = "messages",
                view_search = "virtualtext"
            },

            -- Use a Classic Bottom Cmdline for Search
            cmdline = {
                format = {
                    search_down = {
                        view = "cmdline"
                    },
                    search_up = {
                        view = "cmdline"
                    }
                }
            },

            -- Display the Cmdline and Popupmenu Together
            views = {
                cmdline_popup = {
                    position = {
                        row = 5,
                        col = "50%"
                    },
                    size = {
                        width = 60,
                        height = "auto"
                    }
                },
                popupmenu = {
                    relative = "editor",
                    position = {
                        row = 8,
                        col = "50%"
                    },
                    size = {
                        width = 60,
                        height = 10
                    },
                    border = {
                        style = "rounded",
                        padding = {0, 1}
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "Normal",
                            FloatBorder = "DiagnosticInfo"
                        }
                    }
                }
            }

        })
    end

}
