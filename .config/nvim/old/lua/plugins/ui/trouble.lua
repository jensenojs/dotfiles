-- https://github.com/folke/trouble.nvim
local bind = require("utils.bind")
local map_cmd = bind.map_cmd

local keymaps = {
    ["n|<leader>??"] = map_cmd(":Trouble diagnostics toggle filter.buf=0<cr>"):with_noremap():with_silent():with_desc(
        "Trouble : 当前文件"),
    ["n|<leader><S-?>?"] = map_cmd(":Trouble diagnostics toggle<cr>"):with_noremap():with_silent():with_desc(
        "Trouble : 当前工作区"),
    ["n|<leader>?s"] = map_cmd(":Trouble symbols toggle focus=false<cr>"):with_noremap():with_silent():with_desc(
        "Trouble : symbols"),
    ["n|<leader>?l"] = map_cmd(":Trouble lsp toggle focus=false win.position=right<cr>"):with_noremap():with_silent():with_desc(
        "Trouble : lsp"),
    ["n|<leader>?q"] = map_cmd(":Trouble qflist toggle<cr>"):with_noremap():with_silent():with_desc(
        "Trouble : quick fix list"),

}

bind.nvim_load_mapping(keymaps)

local icons = {
    ui = require("utils.icons").get("ui", true),
    diagnostics = require("utils.icons").get("diagnostics", true)
}

-- 快速查看工作区、文件中的LSP警告列表
-- refer : https://github.com/arthur-hsu/nvim/blob/90760dc1bebe13ba8fd1f60e9312d6eda51b5c4a/lua/plugins/troble.lua#L4
return {
    "folke/trouble.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    event = "VeryLazy",
    cmd = "Trouble",
    config = function()
        require("trouble").setup({
            height = 10, -- height of the trouble list
            mode = "loclist", -- "lsp_workspace_diagnostics", "lsp_document_diagnostics", "quickfix", "lsp_references", "loclist"
            action_keys = { -- key mappings for actions in the trouble list
                close = "q", -- close the list
                cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
                refresh = "r", -- manually refresh
                jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
                jump_close = {"o"}, -- jump to the diagnostic and close the list
                toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
                toggle_preview = "P", -- toggle auto_preview
                hover = "K", -- opens a small poup with the full multiline message
                preview = "p", -- preview the diagnostic location
                close_folds = {"zM", "zm"}, -- close all folds
                open_folds = {"zR", "zr"}, -- open all folds
                toggle_fold = {"zA", "za"}, -- toggle fold of current file
                previous = "k", -- preview item
                next = "j" -- next item
            },
            indent_lines = true, -- add an indent guide below the fold icons
            -- auto_open = true, -- automatically open the list when you have diagnostics
            auto_close = false, -- automatically close the list when you have no diagnostics
            auto_preview = true, -- automatyically preview the location of the diagnostic. <esc> to close preview and go back to last window
            auto_fold = false, -- automatically fold a file trouble list at creation
            signs = {
                error = icons.diagnostics.Error,
                warning = icons.diagnostics.Warning,
                hint = icons.diagnostics.Hint,
                information = icons.diagnostics.Information,
                other = "﫠"
            },
            use_lsp_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
        })
        -- keys = {{
        --     "<leader>xx",
        --     "<cmd>Trouble diagnostics toggle<cr>",
        --     desc = "Diagnostics (Trouble)"
        -- }, {
        --     "<leader>xX",
        --     "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        --     desc = "Buffer Diagnostics (Trouble)"
        -- }, {
        --     "<leader>cs",
        --     "<cmd>Trouble symbols toggle focus=false<cr>",
        --     desc = "Symbols (Trouble)"
        -- }, {
        --     "<leader>cL",
        --     "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        --     desc = "LSP Definitions / references / ... (Trouble)"
        -- }, {
        --     "<leader>xL",
        --     "<cmd>Trouble loclist toggle<cr>",
        --     desc = "Location List (Trouble)"
        -- }, {
        --     "<leader>xQ",
        --     "<cmd>Trouble qflist toggle<cr>",
        --     desc = "Quickfix List (Trouble)"
        -- }}
    end
}
