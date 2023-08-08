-- https://github.com/nvim-tree/nvim-tree.lua
-- 目录树

-- define common options
local opts = {
    noremap = true, -- non-recursive
    silent = true -- do not show message
}

local function edit_or_open()
    local api = require("nvim-tree.api")
    local node = api.tree.get_node_under_cursor()

    if node.nodes ~= nil then
        -- expand or collapse folder
        api.node.open.edit()
    else
        -- open file
        api.node.open.edit()
        -- Close the tree if file was opened
        api.tree.close()
    end
end

-- open as vsplit on current node
local function vsplit_preview()
    local api = require("nvim-tree.api")
    local node = api.tree.get_node_under_cursor()

    if node.nodes ~= nil then
        -- expand or collapse folder
        api.node.open.edit()
    else
        -- open file as vsplit
        api.node.open.vertical()
    end

    -- Finally refocus on tree if it was lost
    api.tree.focus()
end

-- Collapses the nvim-tree recursively, but keep the directories open, which are
-- used in an open buffer.
local function collapse_keep_buffer()
    local api = require "nvim-tree.api"
    api.tree.collapse_all(true)
end

local function open_tab_silent(node)
    local api = require("nvim-tree.api")
    api.node.open.tab(node)
    vim.cmd.tabprev()
end

-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach
local function my_on_attach(bufnr)
    local api = require "nvim-tree.api"

    local function opts(desc)
        return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true
        }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- on_attach
    vim.keymap.set("n", "l", edit_or_open, opts("Edit Or Open"))
    vim.keymap.set("n", "L", vsplit_preview, opts("Vsplit Preview"))
    vim.keymap.set("n", "h", collapse_keep_buffer, opts("Collapse but keep buffer"))
    vim.keymap.set('n', 'T', open_tab_silent, opts("Open Tab Silent"))
    vim.keymap.set("n", "<CR>", api.node.open.tab_drop, opts("Tab drop"))

end

----------------------------------------------------------------

-- 自动打开nvim-tree的辅助函数
local function open_nvim_tree(data)
    -- buffer is a real file on the disk
    local real_file = vim.fn.filereadable(data.file) == 1
    -- buffer is a [No Name]
    local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
    if not real_file and not no_name then
        return
    end
    -- open the tree, find the file but don't focus it
    require("nvim-tree.api").tree.toggle({
        focus = false,
        find_file = true
    })
end

-- 自动关闭nvim-tree的辅助函数
local function tab_win_closed(winnr)
    local api = require "nvim-tree.api"
    local tabnr = vim.api.nvim_win_get_tabpage(winnr)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local buf_info = vim.fn.getbufinfo(bufnr)[1]
    local tab_wins = vim.tbl_filter(function(w)
        return w ~= winnr
    end, vim.api.nvim_tabpage_list_wins(tabnr))
    local tab_bufs = vim.tbl_map(vim.api.nvim_win_get_buf, tab_wins)
    if buf_info.name:match(".*NvimTree_%d*$") then -- close buffer was nvim tree
        -- Close all nvim tree on :q
        if not vim.tbl_isempty(tab_bufs) then -- and was not the last window (not closed automatically by code below)
            api.tree.close()
        end
    else -- else closed buffer was normal buffer
        if #tab_bufs == 1 then -- if there is only 1 buffer left in the tab
            local last_buf_info = vim.fn.getbufinfo(tab_bufs[1])[1]
            if last_buf_info.name:match(".*NvimTree_%d*$") then -- and that buffer is nvim tree
                vim.schedule(function()
                    if #vim.api.nvim_list_wins() == 1 then -- if its the last buffer in vim
                        vim.cmd "quit" -- then close all of vim
                    else -- else there are more tabs open
                        vim.api.nvim_win_close(tab_wins[1], true) -- then close only the tab
                    end
                end)
            end
        end
    end
end

-- r : 重命名文件或者目录
-- a : 创建一个文件
-- d : 删除一个文件(需要最后确认)
-- x : 剪切一个文件到剪切版或者从剪切版移除一个剪切
-- c : 拷贝一个文件到剪切版或者从剪切版移除一个拷贝
-- p : 粘贴文件或者目录
return {
    "nvim-tree/nvim-tree.lua",

    dependencies = {"nvim-tree/nvim-web-devicons"},

    config = function()
        require("nvim-tree").setup({
            -- 设置nvim-tree的快捷键
            on_attach = my_on_attach,

            sort_by = "case_sensitive",

            -- 以图标显示git的状态
            git = {
                enable = true
            },

            renderer = {
                group_empty = true
            },

            filters = {
                -- 不显示隐藏文件
                dotfiles = true
            },

            actions = {
                use_system_clipboard = true,
                change_dir = {
                    enable = true,
                    global = false,
                    restrict_above_cwd = false
                },
                open_file = {
                    quit_on_open = false,
                    resize_window = true,
                    window_picker = {
                        enable = true,
                        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                        exclude = {
                            filetype = {"notify", "packer", "qf", "diff", "fugitive", "fugitiveblame"},
                            buftype = {"nofile", "terminal", "help"}
                        }
                    }
                }
            }

        })

        -- 自动打开nvim-tree, 这个东西不能放在setup里面
        vim.api.nvim_create_autocmd("Vimenter", {
            callback = open_nvim_tree
        })

        -- 自动关闭的脚本, 其实也看不懂, 用着先吧, 这个东西也不能放在setup里面
        vim.api.nvim_create_autocmd("WinClosed", {
            callback = function()
                local winnr = tonumber(vim.fn.expand("<amatch>"))
                vim.schedule_wrap(tab_win_closed(winnr))
            end,
            nested = true
        })

        vim.keymap.set('n', '<F2>', ':NvimTreeToggle<CR>', opts)
    end
}

