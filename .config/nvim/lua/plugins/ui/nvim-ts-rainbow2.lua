-- https://github.com/HiPhish/nvim-ts-rainbow2
-- 基于nvim-treesitter, 将匹配的括号进行彩色的标注, 方便确认
return {
    "HiPhish/nvim-ts-rainbow2",
    -- Bracket pair rainbow colorize
    lazy = true,
    event = {"User FileOpened"},
    config = function()
        require('nvim-treesitter.configs').setup {
            rainbow = {
                enable = true,
                -- Which query to use for finding delimiters
                query = 'rainbow-parens',
                -- Highlight the entire buffer all at once
                strategy = require('ts-rainbow').strategy.global
            }
        }
    end
}
