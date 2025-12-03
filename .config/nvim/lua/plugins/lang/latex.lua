-- https://github.com/jbyuki/nabla.nvim
return {
    "jbyuki/nabla.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
        autogen = true,
        silent = true,
    },
    config = function(_, opts)
        local nabla = require("nabla")
        local group = vim.api.nvim_create_augroup("NablaMarkdown", { clear = true })
        local saved_win_opts = {}

        local function apply_window_opts(win)
            if not win or win == 0 then
                return
            end
            if not saved_win_opts[win] then
                saved_win_opts[win] = {
                    conceallevel = vim.api.nvim_get_option_value("conceallevel", { win = win }),
                    concealcursor = vim.api.nvim_get_option_value("concealcursor", { win = win }),
                }
            end
            vim.api.nvim_set_option_value("conceallevel", 2, { win = win })
            vim.api.nvim_set_option_value("concealcursor", "", { win = win })
        end

        local function restore_window_opts(win)
            local state = saved_win_opts[win]
            if not state then
                return
            end
            vim.api.nvim_set_option_value("conceallevel", state.conceallevel, { win = win })
            vim.api.nvim_set_option_value("concealcursor", state.concealcursor, { win = win })
            saved_win_opts[win] = nil
        end

        local function enable(buf)
            if nabla.is_virt_enabled and nabla.is_virt_enabled(buf) then
                return
            end
            vim.api.nvim_buf_call(buf, function()
                nabla.enable_virt(opts)
            end)
        end

        local function disable(buf)
            if nabla.is_virt_enabled and not nabla.is_virt_enabled(buf) then
                return
            end
            vim.api.nvim_buf_call(buf, function()
                nabla.disable_virt()
            end)
        end

        local function ensure_keymaps(buf)
            if vim.b[buf].nabla_mapped then
                return
            end
            local function map(lhs, rhs, desc)
                vim.keymap.set("n", lhs, rhs, {
                    buffer = buf,
                    silent = true,
                    desc = desc,
                })
            end

            map("<leader>mp", function()
                vim.api.nvim_buf_call(buf, function()
                    nabla.popup({ border = "rounded" })
                end)
            end, "公式: Popup 预览")

            map("<leader>mt", function()
                vim.api.nvim_buf_call(buf, function()
                    nabla.toggle_virt(opts)
                end)
            end, "公式: 行内渲染开关")

            vim.b[buf].nabla_mapped = true
        end

        vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
            group = group,
            pattern = "*.md",
            callback = function(args)
                local win = vim.api.nvim_get_current_win()
                apply_window_opts(win)
                enable(args.buf)
                ensure_keymaps(args.buf)
            end,
        })

        vim.api.nvim_create_autocmd("BufWinLeave", {
            group = group,
            pattern = "*.md",
            callback = function()
                local win = vim.api.nvim_get_current_win()
                restore_window_opts(win)
            end,
        })

        vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
            group = group,
            pattern = "*.md",
            callback = function(args)
                disable(args.buf)
            end,
        })
    end,
}
