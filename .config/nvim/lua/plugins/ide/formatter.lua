-- https://github.com/mhartington/formatter.nvim
-- 自动格式化, https://github.com/nvimdev/guard.nvim 类似，
return {
    'mhartington/formatter.nvim',
    config = function()

        require("formatter").setup({
        filetype = {
            go = {function()
                return {
                    exe = "gofmt",
                    args = {"-w"},
                    stdin = false
                }
            end},
            -- shell script formatter
            sh = {function()
                return {
                    exe = "shfmt",
                    args = {"-i", 2},
                    stdin = true
                }
            end},
            -- python formatter
            python = {function()
                return {
                    exe = "python3 -m autopep8",
                    args = {"--in-place --aggressive --aggressive", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
                    stdin = false
                }
            end}
        }
        })

        vim.cmd[[augroup FormatAutogroup
                autocmd!
                autocmd BufWritePost * FormatWrite
                augroup END
        ]]

    end
}
