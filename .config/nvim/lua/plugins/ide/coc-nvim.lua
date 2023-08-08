-- 设置支持的语言
vim.g.coc_global_extensions = { 'coc-marketplace', 'coc-highlight', 'coc-snippets', 'coc-json', 'coc-vimlsp',
    'coc-dictionary', 'coc-docker', 'coc-markdownlint', 'coc-sh', 'coc-pyright', 'coc-xml',
    'coc-yaml', 'coc-toml', 'coc-clangd', 'coc-go', 'coc-translator', 'coc-java',
    'coc-java-intellicode', 'coc-rls', 'coc-sql', 'coc-lua', 'coc-git', 'coc-rust-analyzer',
    'coc-imselect' -- 用来做输入法之间的切换
}

-- Some servers have issues with backup files, see #649
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
-- delays and poor user experience
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appeared/became resolved
vim.opt.signcolumn = "yes"

-- Use Tab for trigger completion with characters ahead and navigate
-- NOTE: There's always a completion item selected by default, you may want to enable
-- no select by setting `"suggest.noselect": true` in your configuration file
-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
-- other plugins before putting this into your config
local opts = {
    silent = true,
    noremap = true,
    expr = true,
    replace_keycodes = false
}

-- https://github.com/gibfahn/dot/blob/92ec72ddf4a475492afef50c6d95866a1707db02/dotfiles/.config/nvim/init.lua#L415
-- Used in Tab mapping above. If the popup menu is visible, switch to next item in that. Else prints a tab if previous
-- char was empty or whitespace. Else triggers completion.
function Smart_Tab()
    local function replace_keycodes(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
    end

    local check_back_space = function()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        return (col == 0 or vim.api.nvim_get_current_line():sub(col, col):match('%s')) and true
    end


    local check_after_cursor = function()
        local col = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        local text_after_cursor = line:sub(col + 1)
        return text_after_cursor:match('[%]},%)"\']') and true
    end

    if (vim.fn['coc#pum#visible']() ~= 0) then
        return vim.fn['coc#pum#next'](1)
    elseif (check_back_space()) then
        return replace_keycodes('<Tab>')
    elseif (check_after_cursor()) then
        return "<Plug>(Tabout)"
    end
    return vim.fn['coc#refresh']()
end

return {
    "neoclide/coc.nvim",
    branch = "release",

    config = function()
        local keyset = vim.keymap.set


        keyset("i", "<tab>", Smart_Tab, {noremap = false, replace_keycodes = true, expr = true})

        keyset("i", "<S-tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

        -- Make <CR> to accept selected completion item or notify coc.nvim to format
        -- <C-g>u breaks current undo, please make your own choice
        keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

        -- Use <c-j> to trigger snippets
        -- 触发一些代码片段的补齐
        keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")

        -- Use <c-space> to trigger completion
        keyset("i", "<c-space>", "coc#refresh()", {
            silent = true,
            expr = true
        })

        -- Use `[g` and `]g` to navigate diagnostics
        -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
        keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {
            silent = true
        })
        keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {
            silent = true
        })

        -- GoTo code navigation
        keyset("n", "gd", "<Plug>(coc-definition)", {
            silent = true
        })
        keyset("n", "gy", "<Plug>(coc-type-definition)", {
            silent = true
        })
        keyset("n", "gi", "<Plug>(coc-implementation)", {
            silent = true
        })
        keyset("n", "gr", "<Plug>(coc-references)", {
            silent = true
        })

        -- Use K to show documentation in preview window
        function _G.show_docs()
            local cw = vim.fn.expand('<cword>')
            if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
                vim.api.nvim_command('h ' .. cw)
            elseif vim.api.nvim_eval('coc#rpc#ready()') then
                vim.fn.CocActionAsync('doHover')
            else
                vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
            end
        end

        keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {
            silent = true
        })

        -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
        vim.api.nvim_create_augroup("CocGroup", {})
        vim.api.nvim_create_autocmd("CursorHold", {
            group = "CocGroup",
            command = "silent call CocActionAsync('highlight')",
            desc = "Highlight symbol under cursor on CursorHold"
        })

        -- Symbol renaming
        keyset("n", "<leader>rn", "<Plug>(coc-rename)", {
            silent = true
        })

        -- Formatting selected code
        keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {
            silent = true
        })
        keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {
            silent = true
        })

        -- Setup formatexpr specified filetype(s)
        vim.api.nvim_create_autocmd("FileType", {
            group = "CocGroup",
            pattern = "typescript,json",
            command = "setl formatexpr=CocAction('formatSelected')",
            desc = "Setup formatexpr specified filetype(s)."
        })

        -- Update signature help on jump placeholder
        vim.api.nvim_create_autocmd("User", {
            group = "CocGroup",
            pattern = "CocJumpPlaceholder",
            command = "call CocActionAsync('showSignatureHelp')",
            desc = "Update signature help on jump placeholder"
        })
    end
}
