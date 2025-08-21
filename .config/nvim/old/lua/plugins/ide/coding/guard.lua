-- https://github.com/nvimdev/guard.nvim
-- 自动格式化, 比formatter好用一些
-- 其他的可能 :https://github.com/stevearc/conform.nvim
-- 不知道为什么, 这个插件不能用下面的方式绑定快捷键, 还是得是原始的方式
-- local bind = require("utils.bind")
-- local map_cr = bind.map_cr

-- local keymaps = {
--     -- more telescope-relative shortcut, plz refer to lsp-config.lua
--     ["n|<leader>f"] = map_cr("<leader>f"):with_noremap():with_silent():with_desc("格式化当前文件")

-- }

-- bind.nvim_load_mapping(keymaps)

-- return {
--     "nvimdev/guard.nvim",
--     -- Builtin configuration, optional
--     dependencies = {"nvimdev/guard-collection"},

--     -- lazy=false,
--     event = "VeryLazy",
--     config = function()
--         local status, guard = pcall(require, "guard")
--         if not status then
--             vim.notify("not found guard")
--             return {}
--         end

--         local ft = require("guard.filetype")

--         ft("json"):fmt({
--             cmd = "jq",
--             stdin = true
--         })

--         ft("sh"):fmt({
--             cmd = "shfmt",
--             stdin = true
--         })

--         ft("python"):fmt({
--             cmd = "black",
--             stdin = true
--         }):append({
--             cmd = "isort",
--             stdin = true
--         })

--         ft("c"):fmt({
--             cmd = "clang-format",
--             stdin = true
--         }) -- :lint('clang-tidy')

--         ft("go"):fmt({
--             cmd = "gofmt",
--             stdin = true
--         }):append({
--             cmd = "goimports",
--             stdin = true
--         })

--         ft("sql"):fmt({
--             cmd = "sqlfmt",
--             stdin = true
--         })

--         ft("lua"):fmt("lsp"):append("stylua"):lint("selene")

--         -- Call setup() LAST!
--         require("guard").setup({
--             -- the only options for the setup function
--             fmt_on_save = false,
--             -- Use lsp if no formatter was defined for this filetype
--             lsp_as_default_formatter = false
--         })
--     end,

--     vim.keymap.set("n", "<leader>f", ":GuardFmt<CR>"),
-- }
