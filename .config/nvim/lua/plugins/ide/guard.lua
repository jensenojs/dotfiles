-- https://github.com/nvimdev/guard.nvim
-- 自动格式化, 比formatter好用一些
return {
    'nvimdev/guard.nvim',
    event = "VeryLazy",
    config = function()
        local status, guard = pcall(require, "guard")
        if not status then
            vim.notify("not found guard")
            return {}
        end

        local ft = require('guard.filetype')

        ft('json'):fmt('jq'):fmt({
            cmd = "jq",
            stdin = true
        })

        ft('sh'):fmt({
            cmd = 'shfmt',
            stdin = true
        })

        ft('python'):fmt({
            cmd = "black",
            stdin = true
        }):append({
            cmd = "isort",
            stdin = true
        })

        ft('c'):fmt({
            cmd = 'clang-format',
            stdin = true
        }) -- :lint('clang-tidy')

        ft("go"):fmt({
            cmd = "gofmt",
            stdin = true
        }):append({
            cmd = "goimports",
            stdin = true
        })

        ft("sql"):fmt({
            cmd = "sqlfmt",
            stdin = true
        })

        -- Call setup() LAST!
        require('guard').setup({
            -- the only options for the setup function
            fmt_on_save = false,
            -- Use lsp if no formatter was defined for this filetype
            lsp_as_default_formatter = false
        })
    end,

    vim.keymap.set("n", "<leader>f", ":GuardFmt<CR>")
}
