-- https://github.com/nvim-telescope/telescope.nvim
-- define common options
local buf_util = require("utils.buf")
local takeover = require("plugins.fuzzy_finder.lsp_takeover")
local api = vim.api
local log = vim.log.levels
local notify_once = vim.notify_once or vim.notify

local ROOT_MARKERS = {
    ".git",
    ".hg",
    ".svn",
    "pyproject.toml",
    "package.json",
    "Cargo.toml",
    "go.mod",
}

local function bool_var(name, default)
    local val = vim.g[name]
    if val == nil then
        return default
    end
    if type(val) == "string" then
        val = val:lower()
        if val == "false" or val == "0" then
            return false
        end
    end
    return not (val == false or val == 0)
end

local function string_var(name)
    local val = vim.g[name]
    if type(val) == "string" and val ~= "" then
        return vim.fn.expand(val)
    end
    return nil
end

local function list_var(name)
    local val = vim.g[name]
    if type(val) == "string" and val ~= "" then
        return { vim.fn.expand(val) }
    end
    if type(val) == "table" then
        local out = {}
        for _, entry in ipairs(val) do
            if type(entry) == "string" and entry ~= "" then
                out[#out + 1] = vim.fn.expand(entry)
            end
        end
        if #out > 0 then
            return out
        end
    end
    return nil
end

local function resolve_cwd(var_name)
    return string_var(var_name) or buf_util.find_root(nil, {
        markers = ROOT_MARKERS,
    })
end

local function find_files_opts()
    return {
        cwd = resolve_cwd("telescope_find_files_cwd"),
        hidden = bool_var("telescope_find_files_hidden", true),
        follow = bool_var("telescope_find_files_follow", true),
        no_ignore = bool_var("telescope_find_files_no_ignore", false),
        no_ignore_parent = bool_var("telescope_find_files_no_ignore_parent", false),
        search_dirs = list_var("telescope_find_files_dirs"),
    }
end

local function live_grep_opts()
    local extra = {}
    if bool_var("telescope_live_grep_hidden", true) then
        extra[#extra + 1] = "--hidden"
    end
    if bool_var("telescope_live_grep_no_ignore", false) then
        extra[#extra + 1] = "--no-ignore"
    end
    if bool_var("telescope_live_grep_no_ignore_parent", false) then
        extra[#extra + 1] = "--no-ignore-parent"
    end
    local additional
    if #extra > 0 then
        additional = function()
            return vim.deepcopy(extra)
        end
    end
    return {
        cwd = resolve_cwd("telescope_live_grep_cwd"),
        search_dirs = list_var("telescope_live_grep_dirs"),
        additional_args = additional,
    }
end

local function buffer_supports_ts_highlight(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    local ts = vim.treesitter
    if not ts or not ts.get_parser then
        return false, "Tree-sitter 没有可用的 get_parser"
    end

    local ok_parser, parser_or_err = pcall(ts.get_parser, bufnr)
    if not ok_parser then
        return false, parser_or_err
    end

    local ft = vim.bo[bufnr].filetype or ""
    local lang
    if ts.language and ts.language.get_lang then
        local ok_lang, resolved = pcall(ts.language.get_lang, ft)
        if ok_lang then
            lang = resolved
        end
    end
    lang = lang or ft

    if not lang or lang == "" then
        return false, "无法识别当前 filetype 的 Tree-sitter 语言"
    end

    if not ts.query or not ts.query.get then
        return false, "Tree-sitter query 模块不可用"
    end

    local ok_query, query = pcall(ts.query.get, lang, "highlights")
    if not ok_query then
        return false, query
    end

    if query == nil then
        return false, string.format("语言 %s 缺少 highlights.scm", lang)
    end

    return true
end

local QUERY_NIL_ERROR = "attempt to index local 'query'"

local function current_buffer_fuzzy_find_resilient()
    local builtin = require("telescope.builtin")
    local bufnr = api.nvim_get_current_buf()
    local supports_highlight, reason = buffer_supports_ts_highlight(bufnr)
    local opts

    if not supports_highlight then
        opts = { results_ts_highlight = false }
        if reason then
            notify_once(
                string.format("[telescope] %s, 当前 buffer 将禁用 results_ts_highlight。", reason),
                log.INFO
            )
        end
    end

    local ok, err = pcall(builtin.current_buffer_fuzzy_find, opts)
    if ok then
        return
    end

    local err_msg = tostring(err)
    if err_msg:find(QUERY_NIL_ERROR, 1, true) then
        notify_once("[telescope] 缺少 Tree-sitter highlights，已降级到非高亮模式。", log.WARN)
        builtin.current_buffer_fuzzy_find({ results_ts_highlight = false })
        return
    end

    error(err)
end

-- 对预览的设置
-- Ignore files bigger than a threshold
-- and don't preview binaries
local preview_setting = function(filepath, bufnr, opts)
    filepath = vim.fn.expand(filepath)
    local previewers = require("telescope.previewers")

    -- 同步检查文件大小/存在性
    local stat = vim.loop.fs_stat(filepath)
    if not stat then
        vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "FILE NOT FOUND" })
        end)
        return
    end
    if stat and stat.size > 1000000 then
        vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "FILE TOO LARGE" })
        end)
        return
    end

    -- 同步检查 MIME 类型
    local Job = require("plenary.job")
    local mime_type
    Job:new({
        command = "file",
        args = { "--mime-type", "-b", filepath },
        on_exit = function(j)
            local first = j:result()[1]
            if type(first) == "string" then
                mime_type = vim.split(first, "/")[1]
            end
        end,
    }):sync()

    if mime_type and mime_type ~= "text" then
        vim.schedule(function()
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
        end)
        return
    end

    -- 正常预览
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

return {
    "nvim-telescope/telescope.nvim",

    dependencies = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
        },
        "nvim-telescope/telescope-ui-select.nvim", -- "nvim-telescope/telescope-dap.nvim",
        "tom-anders/telescope-vim-bookmarks.nvim",
        "nvim-tree/nvim-web-devicons", -- "nvim-telescope/telescope-aerial.nvim"
    },

    keys = {
        {
            "/",
            mode = "n",
            function()
                -- 注意: 您的 helper functions 必须在文件顶部定义
                current_buffer_fuzzy_find_resilient()
            end,
            desc = "Telescope: 模糊搜索当前文件",
        },
        {
            "<leader>/",
            mode = "n",
            function()
                require("telescope.builtin").live_grep(live_grep_opts())
            end,
            desc = "Telescope: 全局模糊搜索 (live_grep)",
        },
        {
            "<c-p>",
            mode = "n",
            function()
                require("telescope.builtin").find_files(find_files_opts())
            end,
            desc = "Telescope: 查找文件",
        },
        {
            "<leader>r",
            mode = "n",
            function()
                require("telescope.builtin").registers()
            end,
            desc = "Telescope: 打开寄存器列表",
        },
        {
            "<leader>O",
            mode = "n",
            function()
                require("telescope").extensions.aerial.aerial()
            end,
            desc = "Telescope(aerial): 打开LSP大纲",
        },
    },

    opts = function()
        local actions = require("telescope.actions")

        return {
            defaults = {
                -- 可爱捏
                prompt_prefix = "Search: ",

                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--hidden",
                    "--glob=!.git/",
                },

                -- 让预览的设置生效
                buffer_previewer_maker = preview_setting,

                initial_mode = "insert",

                -- 这些路径下的文件不需要被搜索, 但注意下面的 current_buffer_fuzzy_find 也会失效...
                -- https://github.com/nvim-telescope/telescope.nvim/issues/3318
                -- file_ignore_patterns = { ".git/", "%.pdf", "%.mkv", "%.mp4", "%.zip" },
                file_ignore_patterns = { "%.pdf", "%.mkv", "%.mp4", "%.zip" },

                layout_config = {
                    horizontal = {
                        prompt_position = "top",
                        preview_width = 0.55,
                        results_width = 0.8,
                    },
                    vertical = {
                        mirror = false,
                    },
                    width = 0.85,
                    height = 0.92,
                    preview_cutoff = 120,
                },

                -- Default configuration for telescope goes here:
                mappings = {
                    -- insert mode
                    i = {
                        -- map actions.which_key to <C-h> (default: <C-/>)
                        -- actions.which_key shows the mappings for your picker,
                        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                        ["<c-l>"] = false, --  clear prompt
                        ["<c-h>"] = "which_key", -- 显示快捷指令的作用
                        ["<f1>"] = "which_key", -- 显示快捷指令的作用
                        ["<Esc>"] = actions.close,
                        ["<C-c>"] = actions.close,
                    },
                    n = {
                        ["<Esc>"] = actions.close,
                        ["<C-c>"] = actions.close,
                        ["q"] = actions.close,
                    },
                },
            },

            pickers = {
                find_files = {
                    find_command = function(_, opts)
                        opts = opts or {}
                        local cmd = { "fd", "--type", "f", "--strip-cwd-prefix" }
                        if opts.follow then
                            cmd[#cmd + 1] = "--follow"
                        end
                        if opts.hidden then
                            cmd[#cmd + 1] = "--hidden"
                        end
                        if opts.no_ignore then
                            cmd[#cmd + 1] = "--no-ignore"
                        end
                        if opts.no_ignore_parent then
                            cmd[#cmd + 1] = "--no-ignore-parent"
                        end
                        return cmd
                    end,
                    mappings = {
                        i = {
                            ["<CR>"] = actions.select_drop,
                        },
                    },
                },

                buffers = {
                    show_all_buffers = true,
                    sort_lastused = true,
                    mappings = {
                        i = {
                            ["<c-d>"] = actions.delete_buffer,
                            ["<CR>"] = actions.select_drop,
                        },
                    },
                },

                -- git_status = {
                -- 	preview = {
                -- 		hide_on_startup = false,
                -- 	},
                -- 	mappings = {
                -- 		i = {
                -- 			["<CR>"] = actions.select_drop,
                -- 		},
                -- 	},
                -- },

                live_grep = {
                    preview = {
                        hide_on_startup = false,
                    },
                    mappings = {
                        i = {
                            ["<CR>"] = actions.select_drop,
                        },
                    },
                },

                old_files = {
                    mappings = {
                        i = {
                            ["<CR>"] = actions.select_drop,
                        },
                    },
                },
            },

            extensions = {
                -- Your extension configuration goes here:
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case", -- or "ignore_case" or "respect_case"
                },
                ["ui-select"] = {
                    -- require("telescope.themes").get_dropdown({
                    -- 	-- even more opts
                    -- 	winblend = 10,
                    -- }),
                },
                aerial = {
                    -- Set the width of the first two columns (the second
                    -- is relevant only when show_columns is set to 'both')
                    col1_width = 4,
                    col2_width = 30,
                    -- How to format the symbols
                    format_symbol = function(symbol_path, filetype)
                        if filetype == "json" or filetype == "yaml" then
                            return table.concat(symbol_path, ".")
                        else
                            return symbol_path[#symbol_path]
                        end
                    end,
                    -- Available modes: symbols, lines, both
                    show_columns = "both",
                },
            },
        }
    end,
    config = function(_, opts)
        local telescope = require("telescope")
        telescope.setup(opts)

        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "ui-select")
        pcall(telescope.load_extension, "aerial")
        -- require("telescope").load_extension("vim_bookmarks")
        -- require("telescope").load_extension("dap")

        -- 注册自动命令: 在 LSP 附加时覆盖该 buffer 的按键
        -- 说明：
        -- - 我们不在 attach.lua 修改原生映射, 而是在插件侧监听同一事件,
        --   使用 telescope.builtin.lsp_* 将相同语义的键位(如 <leader>o / <leader>O)
        --   重定向到 Telescope UI。
        -- - Neovim 的自动命令按“定义顺序”执行；该回调在 attach.lua 之后定义,
        --   因此会在同一 LspAttach 事件中更晚执行, 从而以 buffer-local 覆盖前者。
        --   参考 :h autocmd
        local TELE_ATTACH = api.nvim_create_augroup("telescope.override_lsp", {
            clear = true,
        })
        api.nvim_create_autocmd("LspAttach", {
            group = TELE_ATTACH,
            callback = function(ev)
                -- ev.buf: 附加的 buffer；takeover 内部只用 telescope.builtin.lsp_*
                -- 并且带幂等标记, 重复进入不会反复设置。
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then
                    return
                end
                takeover.takeover_lsp_buf(ev.buf, client)
            end,
        })

        -- 兜底: 对当前已存在且已附加 LSP 的 buffer 进行一次覆盖
        -- 说明：
        -- - LspAttach 只在“新发生的附加事件”时触发；当插件被 lazy.nvim 晚加载时,
        --   进程里可能已经有若干 buffer 早就附加了 LSP(因此不会再触发 LspAttach)。
        -- - 这里主动遍历现有 buffer 并调用 takeover, 以保证它们也切换到 Telescope 的 UI。
        -- - takeover() 内部会判断该 bufnr 是否已附加 LSP、是否已经处理过, 因而是幂等的。
        for _, bufnr in ipairs(api.nvim_list_bufs()) do
            local clients = vim.lsp.get_clients({
                bufnr = bufnr,
            })
            if clients and #clients > 0 then
                local client = clients[1]
                takeover.takeover_lsp_buf(bufnr, client)
            end
        end
    end,
}
