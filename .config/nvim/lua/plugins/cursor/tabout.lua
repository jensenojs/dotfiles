-- https://github.com/abecodes/tabout.nvim
-- 在Insert模式下, 按<Tab>可以跳出括号
return {
    "abecodes/tabout.nvim",
    -- 移除 lazy = false，使用 event 触发懒加载
    event = "InsertEnter", -- 进入插入模式时加载，比 InsertCharPre 更合理
    -- 移除无效的 opt = true
    opts = function()
        return {
            tabkey = "", -- we drive <Plug>(Tabout) from blink.cmp; don't map <Tab> directly here
            backwards_tabkey = "", -- same for <S-Tab>
            act_as_tab = true, -- shift content if tab out is not possible
            act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
            default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
            default_shift_tab = "<C-d>", -- reverse shift default action,
            enable_backwards = true, -- well ...
            completion = true, -- integrate with completion menu
            tabouts = {
                {
                    open = "'",
                    close = "'",
                },
                {
                    open = '"',
                    close = '"',
                },
                {
                    open = "`",
                    close = "`",
                },
                {
                    open = "(",
                    close = ")",
                },
                {
                    open = "[",
                    close = "]",
                },
                {
                    open = "{",
                    close = "}",
                },
            },
            ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
            exclude = {}, -- tabout will ignore these filetypes
        }
    end,
}
