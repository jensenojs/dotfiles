-- https://github.com/abecodes/tabout.nvim
-- 在Insert模式下，按<Tab>可以跳出括号
return {
    "abecodes/tabout.nvim",
    lazy = true,
    event = { "InsertEnter" },
    config = function()
        require("tabout").setup({
            -- tabkey = "<Tab>",
            -- backwards_tabkey = "<S-Tab>",
            tabkey = "",
            backwards_tabkey = "",
            act_as_tab = true,
            act_as_shift_tab = false,
            default_tab = "<C-t>",
            default_shift_tab = "<C-d>",
            enable_backwards = true,
            completion = true,
            tabouts = {
                { open = "'", close = "'" },
                { open = '"', close = '"' },
                { open = "`", close = "`" },
                { open = "(", close = ")" },
                { open = "[", close = "]" },
                { open = "{", close = "}" },
            },
            ignore_beginning = true,
            exclude = {
                "qf",
                "NvimTree",
                "toggleterm",
                "TelescopePrompt",
                "alpha",
                "netrw",
            },
        })
    end,
    -- after = { "coc-nvim" },
}