-- https://github.com/williamboman/mason.nvim
-- 在启动的时候它会将环境路径加进去, 所以让它的调用顺序高一些
-- Easily install and manage LSP servers, DAP servers, linters, and formatters.
return {
    "williamboman/mason.nvim",
    event = "VimEnter",

    config = function()
        local status, mason = pcall(require, "mason")
        if not status then
            vim.notify("not found mason")
            return
        end

        -- local formatlist = require("utils.mason-list").get("format", true)
        -- local mason_registry = require("mason-registry")
        -- local mason_dap = require("mason-nvim-dap")

        local icons = {
            ui = require("utils.icons").get("ui", true),
            misc = require("utils.icons").get("misc", true)
        }

        mason.setup({
            ui = {
                border = "single",
                icons = {
                    package_pending = icons.ui.Modified_alt,
                    package_installed = icons.ui.Check,
                    package_uninstalled = icons.misc.Ghost
                },
                keymaps = {
                    toggle_server_expand = "<CR>",
                    install_server = "i",
                    update_server = "u",
                    check_server_version = "c",
                    update_all_servers = "U",
                    check_outdated_servers = "C",
                    uninstall_server = "X",
                    cancel_installation = "<C-c>"
                }
            },
            pip = {
                -- These args will be added to `pip install` calls. Note that setting extra args might impact intended behavior
                -- and is not recommended.
                --
                -- Example: { "--proxy", "https://proxyserver" }
                install_args = {"-i", "https://pypi.tuna.tsinghua.edu.cn/simple"}
            }

        })

        -- local ensure_installed = function()
        --     for _, name in pairs(formatlist) do
        --         if not mason_registry.is_installed(name) then
        --             local package = mason_registry.get_package(name)
        --             package:install()
        --         end
        --     end
        -- end

        -- mason_registry.refresh(vim.schedule_wrap(ensure_installed))
    end
}
