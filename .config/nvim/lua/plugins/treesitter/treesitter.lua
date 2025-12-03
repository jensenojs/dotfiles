return {
    -- nvim-treesitter: https://github.com/nvim-treesitter/nvim-treesitter
    -- 设计意图: 语法高亮/增量解析/按 buffer 条件折叠。依赖 andymass/vim-matchup 可与 Treesitter 集成。
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {"andymass/vim-matchup"},
    opts = {
        -- 支持的语言, 它们的代码高亮就会更准确
        ensure_installed = require("utils.treesitter-languages").ensure_installed,
        sync_install = false,
        auto_install = true,
        matchup = {
            enable = true
        }
    },

    config = function(_, opts)
        local ts = require("nvim-treesitter")
        ts.setup(opts)

        -- 安装缺失的 parsers
        local ensure = opts.ensure_installed or {}
        if type(ensure) == "string" then
            ensure = {ensure}
        end
        local installed = ts.get_installed() or {}
        local need = {}
        for _, lang in ipairs(ensure) do
            if not vim.list_contains(installed, lang) then
                table.insert(need, lang)
            end
        end
        if #need > 0 then
            if vim.fn.executable("tree-sitter") == 1 then
                ts.install(need, {
                    summary = true
                })
            else
                vim.schedule(function()
                    vim.notify(
                        "nvim-treesitter: 未检测到 tree-sitter CLI. 请先安装, 例如: brew install tree-sitter-cli",
                        vim.log.levels.WARN, {
                            title = "nvim-treesitter"
                        })
                end)
            end
        end

        -- Treesitter 折叠配置
        local fold_group = vim.api.nvim_create_augroup("TreesitterFold", {
            clear = true
        })
        vim.api.nvim_create_autocmd("FileType", {
            group = fold_group,
            pattern = "*",
            callback = function(args)
                local buf = args.buf
                local has_parser = false
                pcall(function()
                    has_parser = require("nvim-treesitter.parsers").has_parser(vim.bo[buf].filetype)
                end)
                if has_parser then
                    vim.opt_local.foldmethod = "expr"
                    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                end
            end
        })

        -- Treesitter 高亮配置
        local hl_group = vim.api.nvim_create_augroup("TreesitterHighlight", {
            clear = true
        })
        vim.api.nvim_create_autocmd("FileType", {
            group = hl_group,
            pattern = "*",
            callback = function(args)
                local buf = args.buf
                local ft = vim.bo[buf].filetype
                if not ft or ft == "" then
                    return
                end

                local max = 200 * 1024
                local name = vim.api.nvim_buf_get_name(buf)
                local st = (name ~= "" and vim.uv and vim.uv.fs_stat(name)) or nil
                if not st and vim.loop then
                    st = (name ~= "" and vim.loop.fs_stat(name)) or nil
                end
                if ft ~= "markdown" and ft ~= "markdown.mdx" and st and st.size and st.size > max then
                    return
                end

                pcall(vim.treesitter.start, buf)
            end
        })
    end
}
