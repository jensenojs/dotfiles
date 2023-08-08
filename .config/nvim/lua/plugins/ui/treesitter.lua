return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",

    -- https://github.com/andymass/vim-matchup
    dependencies = {
        -- better matchup which can be intergreted to treesitter
        "andymass/vim-matchup",
    },

    config = function()
        require("nvim-treesitter.configs").setup({
            -- 支持的语言, 它们的代码高亮就很漂亮啦
            ensure_installed = {"bash", "c", "cpp", "cmake", "make", "go", "gomod", "gosum", "gowork", "java", "rust",
                                "lua", "scheme", "python", "json", "vim", "vimdoc", "sql", "scala", "toml"},

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            -- auto_install = true,

            -- 启用代码高亮
            highlight = {
                enable = true,

                -- 如果文件太大了就算了
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end
            }

            -- 启用基于 Treesitter 的代码格式化。
            -- indent = {
            --     enable = true
            -- },
        })

        -- 开启treesitter加持的代码折叠
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
        -- 默认不折叠
        vim.wo.foldlevel = 99

    end
}
