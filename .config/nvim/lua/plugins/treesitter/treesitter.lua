return {
    -- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter
    -- 设计意图: 语法高亮/增量解析/按 buffer 条件折叠。依赖 andymass/vim-matchup 可与 Treesitter 集成。
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = { "andymass/vim-matchup" },
    opts = {
        -- 支持的语言, 它们的代码高亮就会更准确
        ensure_installed = require("utils.treesitter-languages").ensure_installed,
        sync_install = false,
        auto_install = true,
        highlight = {
            enable = true,
            -- 如果文件太大了就算了(>200KB)
            disable = function(_, buf)
                local max = 200 * 1024
                local name = vim.api.nvim_buf_get_name(buf)
                local st = (name ~= "" and vim.uv and vim.uv.fs_stat(name)) or nil
                if not st and vim.loop then
                    st = (name ~= "" and vim.loop.fs_stat(name)) or nil
                end
                return st and st.size and st.size > max
            end,
            additional_vim_regex_highlighting = false,
        },
        matchup = {
            enable = true,
        },
    },
    init = function()
        -- Treesitter 折叠配置（main 分支使用新的 API）
        local group = vim.api.nvim_create_augroup("treesitter-fold", {
            clear = true,
        })
        vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
            group = group,
            callback = function(args)
                local buf = args.buf
                local has_parser = false
                pcall(function()
                    has_parser = require("nvim-treesitter.parsers").has_parser(vim.bo[buf].filetype)
                end)
                local name = vim.api.nvim_buf_get_name(buf)
                local st = (name ~= "" and vim.uv and vim.uv.fs_stat(name)) or nil
                if not st and vim.loop then
                    st = (name ~= "" and vim.loop.fs_stat(name)) or nil
                end
                local max = 200 * 1024
                if has_parser and (not st or not st.size or st.size <= max) then
                    vim.api.nvim_buf_call(buf, function()
                        vim.opt_local.foldmethod = "expr"
                        -- main 分支使用 vim.treesitter.foldexpr() 而不是 nvim_treesitter#foldexpr()
                        vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                        vim.opt_local.foldlevel = 10
                    end)
                end
            end,
        })
    end,

    config = function(_, opts)
        -- 使用 main 分支提供的新 API，显式安装 ensure_installed 里的语言，
        -- 确保 parsers/queries 被写入 stdpath('data') .. '/site'，实现可迁移性。
        local ts = require("nvim-treesitter")

        -- 使用默认 install_dir（stdpath('data') .. '/site'），不覆写其它配置。
        ts.setup(opts)

        local ensure = opts.ensure_installed or {}
        if type(ensure) == "string" then
            ensure = { ensure }
        end

        local installed = ts.get_installed() or {}
        local need = {}
        for _, lang in ipairs(ensure) do
            if not vim.list_contains(installed, lang) then
                table.insert(need, lang)
            end
        end

        if #need > 0 then
            local has_cli = vim.fn.executable("tree-sitter") == 1
            if not has_cli then
                vim.schedule(function()
                    vim.notify(
                        "nvim-treesitter: 未检测到 tree-sitter CLI (tree-sitter). 请先安装, 例如: brew install tree-sitter-cli",
                        vim.log.levels.WARN,
                        { title = "nvim-treesitter" }
                    )
                end)
                return
            end
            -- 默认异步安装缺失语言, 启动时不阻塞, 需要时可在 Neovim 内显式使用 TSInstall 同步安装。
            ts.install(need, { summary = true })
        end
    end,
}
