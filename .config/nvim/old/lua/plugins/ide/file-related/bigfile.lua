-- https://github.com/LunarVim/bigfile.nvim
local ftdetect = {
    name = "ftdetect",
    opts = {
        defer = true
    },
    disable = function()
        vim.api.nvim_set_option_value("filetype", "bigfile", {
            scope = "local"
        })
    end
}

local cmp = {
    name = "nvim-cmp",
    opts = {
        defer = true
    },
    disable = function()
        require("cmp").setup.buffer({
            enabled = false
        })
    end
}

return {
    "LunarVim/bigfile.nvim",
    config = function()
        require("bigfile").setup({
            filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
            pattern = {"*"}, -- autocmd pattern or function see <### Overriding the detection of big files>
            features = { -- features to disable
            "indent_blankline", "illuminate", "lsp", "treesitter", "syntax", "matchparen", "vimopts", "filetype", cmp,
            ftdetect}
        })
    end
}
