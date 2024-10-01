-- https://github.com/neovim/nvim-lspconfig
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_callback = bind.map_callback
local map_cmd = bind.map_cmd

-- local keymaps = {
-- ["n|<F9>"] = map_cr():with_noremap():with_silent():with_desc("调试: 添加/删除断点")
-- }

-- bind.nvim_load_mapping(keymaps)

-- Replace termcodes in input string (e.g. converts '<C-a>' -> '').
local function replace_keycodes(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

return {
    "neovim/nvim-lspconfig",
    event = {"BufReadPre", "BufNewFile"},
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        --     border = "rounded"
        -- })

        -- -- 这个请求会在用户编写代码时触发，通常是在函数调用的参数列表内部，以显示当前光标下的函数签名信息。
        -- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        --     border = "rounded"
        -- })

        --------------------------------lspconfig-----------------------
        local lspconfig = require("lspconfig")
        local util = require("lspconfig/util")

        -- Mappings.
        -- See `:help vim.diagnostic.*` for documentation on any of the below functions
        local opts = {
            noremap = true,
            silent = true
        }
        vim.keymap.set("n", "<space>E", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
            vim.lsp.inlay_hint.enable(true, {bufnr})

            local signature_setup = {
                -- hint_prefix = "🐼 ",
                -- hint_prefix = "🐧 ",
                -- hint_prefix = "🦔 ",
                hint_prefix = "🦫 "
            }

            -- require("lsp_signature").on_attach(signature_setup, bufnr)

            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

            -- telescope integration
            telescope_builtin = require("telescope.builtin")

            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local bufopts = {
                noremap = true,
                silent = true,
                buffer = bufnr
            }

            vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "<C-b>", vim.lsp.buf.signature_help, bufopts)

            -- 还不太理解有什么用
            -- vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
            -- vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
            -- vim.keymap.set("n", "<space>wl", function()
            --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            -- end, bufopts)

            local keymaps = {
                -----------------
                --    insert   --
                -----------------

                -- Make <CR> to accept selected completion item or notify coc.nvim to format
                -- https://salferrarello.com/vim-keymap-set-coc-to-confirm-completion-with-lua/
                -- not work
                -- ["i|<CR>"] = map_cmd('coc#pum#visible() ? coc#pum#confirm() : "<CR>"'):with_silent():with_expr()
                --     :with_noremap():with_desc("自动补全:选中光标所在"),

                -- ["i|<tab>"] = map_callback(function()
                --     -- Used in Tab mapping above. If the popup menu is visible, switch to next item in that. Else prints a tab if previous
                --     -- char was empty or whitespace. Else triggers completion.
                --     local check_after_cursor = function()
                --         local col = vim.api.nvim_win_get_cursor(0)[2]
                --         local line = vim.api.nvim_get_current_line()
                --         local text_after_cursor = line:sub(col + 1)
                --         return text_after_cursor:match("[%]},%)`\"']") and true
                --     end

                --     local check_back_space = function()
                --         local col = vim.api.nvim_win_get_cursor(0)[2]
                --         return (col == 0 or vim.api.nvim_get_current_line():sub(col, col):match("%s")) and true
                --     end

                --     if vim.fn["coc#pum#visible"]() ~= 0 then
                --         return vim.fn["coc#pum#next"](1)
                --     elseif check_back_space() then
                --         return replace_keycodes("<Tab>")
                --     elseif check_after_cursor() then
                --         -- 使得光标自动地跳过右括号等
                --         return replace_keycodes("<Plug>(Tabout)")
                --     end
                --     -- trigger completion
                --     return vim.fn["coc#refresh"]()
                -- end):with_silent():with_buffer(bufnr):with_expr():with_desc("聪明的tab"),

                -- ["i|<s-tab>"] = map_callback(function()
                --     local check_before_cursor = function()
                --         local col = vim.api.nvim_win_get_cursor(0)[2]
                --         local line = vim.api.nvim_get_current_line()
                --         local text_before_cursor = line:sub(1, col)
                --         return text_before_cursor:match("[[{%(`\"']") and true
                --     end

                --     if vim.fn["coc#pum#visible"]() ~= 0 then
                --         return vim.fn["coc#pum#prev"](1)
                --     elseif check_before_cursor() then
                --         -- 使得光标自动地跳过左括号等
                --         return replace_keycodes("<Plug>(TaboutBack)")
                --     end
                --     -- map shift-tab to inverse tab, similar as << / >>
                --     return replace_keycodes("<c-d>")
                -- end):with_silent():with_buffer(bufnr):with_expr():with_desc("聪明的<s-tab>"),

                -----------------
                --    normal   --
                -----------------
                ["n|gd"] = map_callback(function()
                    vim.lsp.buf.definition()
                end):with_silent():with_buffer(bufnr):with_desc("跳转到定义"),

                ["n|gt"] = map_callback(function()
                    vim.lsp.buf.type_definition()
                end):with_silent():with_buffer(bufnr):with_desc("跳转到符号类型定义"),

                ["n|gD"] = map_callback(function()
                    vim.lsp.buf.declaration()
                end):with_silent():with_buffer(bufnr):with_desc("跳转到声明"),

                ["n|gi"] = map_callback(function()
                    vim.lsp.buf.implementation()
                end):with_silent():with_buffer(bufnr):with_desc("跳转到实现"),

                ["n|gr"] = map_callback(function()
                    require('telescope.builtin').lsp_references()
                end):with_silent():with_buffer(bufnr):with_desc("跳转到引用"),

                ["n|<leader>rn"] = map_callback(function()
                    vim.lsp.buf.rename()
                end):with_silent():with_buffer(bufnr):with_desc("变量重命名"),

                ["n|<c-s>"] = map_cr(":Telescope aerial"):with_noremap():with_silent():with_buffer(bufnr):with_desc(
                    "查找当前文件下的符号"),

                -- ["n|<c-s>"] = map_callback(function()
                --     require('telescope.builtin').lsp_document_symbols()
                -- end):with_noremap():with_silent():with_buffer(bufnr):with_desc("查找当前文件下的符号"),

                ["n|<c-w>"] = map_callback(function()
                    require('telescope.builtin').lsp_dynamic_workspace_symbols()
                end):with_noremap():with_silent():with_buffer(bufnr):with_desc("查找当前项目下的符号"),

                ["n|<leader>a"] = map_callback(function()
                    require("tiny-code-action").code_action()
                end):with_noremap():with_silent():with_buffer(bufnr):with_desc("查看有什么可以做的code action"),

                ["n|<leader>?"] = map_callback(function()
                    -- vim.diagnostic.setloclist()
                    require'telescope.builtin'.diagnostics()
                end):with_noremap():with_silent():with_buffer(bufnr):with_desc("列出所有warm/error")

                -- ["n|<leader>a"] = map_callback(function()

                -- end):with_noremap():with_silent():with_buffer(bufnr):with_desc("查看有什么可以做的code action"),

                -- show docs
                -- ["n|<s-k>"] = map_callback(function()
                --     -- Use K to show documentation in preview window
                --     local cw = vim.fn.expand("<cword>")
                --     if vim.fn.index({"vim", "help"}, vim.bo.filetype) >= 0 then
                --         vim.api.nvim_command("h " .. cw)
                --     elseif vim.api.nvim_eval("coc#rpc#ready()") then
                --         vim.fn.CocActionAsync("doHover")
                --     else
                --         vim.api.nvim_command("!" .. vim.o.keywordprg .. " " .. cw)
                --     end
                -- end):with_silent():with_buffer(bufnr):with_desc("显示光标所在处的文档")
            }

            bind.nvim_load_mapping(keymaps)
        end

        local lsp_flags = {
            -- This is the default in Nvim 0.7+
            debounce_text_changes = 150
        }

        local lsp_defaults = lspconfig.util.default_config
        lsp_defaults.capabilities = vim.tbl_deep_extend("force", lsp_defaults.capabilities, capabilities)

        local servers = {"cmake", "clangd", -- C/C++
        -- "pyright", -- python "pyright", 
        "ruff", -- python "pyright", 
        "rust_analyzer", -- rust
        "gopls", -- golang
        "sqlls", -- sql
        "lua_ls", -- lua
        "dockerls", -- docker
        "jsonls" -- json
        }

        for _, lsp in pairs(servers) do
            if lsp == "lua_ls" then
                lspconfig[lsp].setup({
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = {"vim"}
                            }
                        }
                    },
                    on_attach = on_attach,
                    flags = lsp_flags
                })
            elseif lsp == "rust_analyzer" then
                lspconfig[lsp].setup({
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = true,
                            check = {
                                command = "clippy",
                                features = "all"
                            },
                            assist = {
                                importGranularity = "module",
                                importPrefix = "self"
                            },
                            diagnostics = {
                                enable = true,
                                enableExperimental = true
                            },
                            cargo = {
                                loadOutDirsFromCheck = true,
                                features = "all" -- avoid error: file not included in crate hierarchy
                            },
                            procMacro = {
                                enable = true
                            },
                            inlayHints = {
                                chainingHints = true,
                                parameterHints = true,
                                typeHints = true
                            }
                        }
                    },
                    on_attach = on_attach,
                    flags = lsp_flags
                })
            elseif lsp == "ruff" then
                lspconfig[lsp].setup({
                    init_options = {
                        settings = {
                            -- Modification to any of these settings has no effect.
                            enable = true,
                            ignoreStandardLibrary = true,
                            organizeImports = true,
                            fixAll = true,
                            lint = {
                                enable = true,
                                run = 'onType'
                            }
                        }
                    }
                })
            else
                lspconfig[lsp].setup({
                    on_attach = on_attach,
                    flags = lsp_flags
                })
            end
        end
    end,
    -- dependencies = {{"ray-x/lsp_signature.nvim"}, {"rachartier/tiny-code-action.nvim"},
    --                 {"williamboman/mason-lspconfig.nvim"}}
    dependencies = {{"rachartier/tiny-code-action.nvim"}, {"williamboman/mason-lspconfig.nvim"}}
}
