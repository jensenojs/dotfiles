-- https://github.com/mikavilpas/yazi.nvim
return {
    "mikavilpas/yazi.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = {
        { "nvim-lua/plenary.nvim", lazy = true },
        "MagicDuck/grug-far.nvim",
    },
    -- 打开目录时的统一行为：用 yazi 接管（包括 nvim <目录> 和 dropbar :edit 目录）
    init = function()
        -- 禁用内置 netrw 插件
        vim.g.loaded_netrwPlugin = 1

        local api = vim.api
        local group = api.nvim_create_augroup("UserYaziOpenDir", { clear = true })

        api.nvim_create_autocmd("BufEnter", {
            group = group,
            callback = function(ev)
                local buf = ev.buf
                local file = ev.file
                if file == "" then
                    file = api.nvim_buf_get_name(buf)
                end

                if file == "" or vim.fn.isdirectory(file) ~= 1 then
                    return
                end

                -- 只处理普通缓冲区，避免干扰终端/特殊窗口
                if vim.bo[buf].buftype ~= "" then
                    return
                end

                -- 防止重复触发
                if vim.b[buf]._yazi_opened_for_dir then
                    return
                end
                vim.b[buf]._yazi_opened_for_dir = true

                local winid = api.nvim_get_current_win()
                local empty = api.nvim_create_buf(true, false)
                local prev = vim.fn.bufnr("#")
                local next_buf = (prev > 0 and api.nvim_buf_is_valid(prev)) and prev or empty

                vim.schedule(function()
                    pcall(api.nvim_win_set_buf, winid, next_buf)
                    pcall(api.nvim_buf_delete, buf, { force = true })
                    if next_buf ~= empty then
                        pcall(api.nvim_buf_delete, empty, { force = true })
                    end

                    -- 这里会按需加载 yazi.nvim 插件
                    require("yazi").yazi(nil, file)
                end)
            end,
        })
    end,
    opts = function()
        -- Example: when using the `copy_relative_path_to_selected_files` key (default
        -- <c-y>) in yazi, change the way the relative path is resolved.
        require("yazi").setup({
            integrations = {
                -- https://github.com/mikavilpas/yazi.nvim/blob/main/documentation/copy-relative-path-to-files.md
                resolve_relative_path_implementation = function(args, get_relative_path)
                    -- By default, the path is resolved from the file/dir yazi was focused on
                    -- when it was opened. Here, we change it to resolve the path from
                    -- Neovim's current working directory (cwd) to the target_file.
                    local cwd = vim.fn.getcwd()
                    local path = get_relative_path({
                        selected_file = args.selected_file,
                        source_dir = cwd,
                    })
                    return path
                end,
            },
            -- 目录接管逻辑在 init 的 BufEnter 自动命令中实现
            -- open_for_directories = false,
            -- 	keymaps = {
            -- 		show_help = "<f1>",
            -- 	},
        })
    end,
    keys = {
        {
            "<c-e>",
            mode = { "n", "v" },
            "<cmd>Yazi<cr>",
            desc = "Yazi : Open yazi at the current file",
        },
        -- no need for open in the current working directory
        {
            "<c-s-e>",
            mode = { "n", "v" },
            "<cmd>Yazi cwd<cr>",
            desc = "Yazi : Open yazi at the current working space",
        },
    },
}
