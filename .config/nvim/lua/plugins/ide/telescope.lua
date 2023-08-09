-- Add any additional keymaps here
-- define common options
local opts = {
    noremap = true, -- non-recursive
    silent = true -- do not show message
}

-- 对预览的设置
-- Ignore files bigger than a threshold
-- and don't preview binaries
local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    filepath = vim.fn.expand(filepath)

    local previewers = require("telescope.previewers")
    local Job = require("plenary.job")

    -- 如果是二进制, 不预览
    Job:new({
        command = "file",
        args = {"--mime-type", "-b", filepath},
        on_exit = function(j)
            local mime_type = vim.split(j:result()[1], "/")[1]
            if mime_type ~= "text" then
                -- maybe we want to write something to the buffer here
                vim.schedule(function()
                    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {"BINARY"})
                end)
            end
        end
    }):sync()

    -- 如果文件太大, 也不预览
    vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then
            return
        end
        if stat.size > 100000 then
            return
        else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
    end)
end

return {
    'nvim-telescope/telescope.nvim',

    dependencies = {"nvim-lua/plenary.nvim", {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make'
    }, 'nvim-telescope/telescope-ui-select.nvim', 'fannheyward/telescope-coc.nvim',
                    'tom-anders/telescope-vim-bookmarks.nvim', 'nvim-tree/nvim-web-devicons'},

    config = function()
        local builtin = require('telescope.builtin')
        local actions = require('telescope.actions')

        vim.keymap.set('n', '<leader>/', function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require('telescope.builtin').current_buffer_fuzzy_find(
                require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false
                })
        end, opts, {
            desc = '<leader>+/ : 在当前文件下模糊搜索'
        })
        vim.keymap.set('n', '<leader><space>', builtin.buffers, opts, {
            desc = '<leader>+<space> : 查找当前打开的buffer'
        })
        vim.keymap.set('n', '<leader>?', builtin.oldfiles, opts, {
            desc = '<leader>+? : 查找打开过的文件'
        })

        -- vim.keymap.set('n', '<leader>fg', builtin.live_grep, opts, {
        --     desc = '<leader>+fg : 模糊搜索当前项目'
        -- })
        vim.keymap.set('n', '<leader>g', builtin.git_status, opts, {
            desc = '<leader>+g : 列出当前git项目下做了哪些修改'
        })
        -- vim.keymap.set('n', '<leader>a', ':Telescope coc code_actions<cr>', opts, {
        --     desc = '<leader>+a : '
        -- })
        vim.keymap.set('n', '<leader>b', ':Telescope coc diagnostics<cr>', opts, {
            desc = '<leader>+b : 搜索当前项目下有bug的地方'
        })
        vim.keymap.set('n', 'gr', ':Telescope coc references<cr>', opts, {
            desc = '<leader>+r : 搜索当前光标下的函数引用'
        })
        vim.keymap.set('n', 'gi', ':Telescope coc implementations<cr>', opts, {
            desc = '<leader>+i : 搜索当前光标下的函数实现'
        })
        -- 适应vscode的快捷键
        vim.keymap.set('n', '<c-p>', builtin.find_files, opts, {
            desc = 'ctrl+p : 查找文件'
        })
        vim.keymap.set('n', '<c-s-o>', ':Telescope coc document_symbols<cr>', opts, {
            desc = 'ctrl+s : 搜索当前文件下的符号'
        })
        vim.keymap.set('n', '<c-t>', ':Telescope coc workspace_symbols<cr>', opts, {
            desc = 'ctrl+t : 搜索当前项目下的符号'
        })

        require('telescope').setup {
            defaults = {
                -- 可爱捏
                prompt_prefix = "🔍 ",

                vimgrep_arguments = {"rg", "--color=never", "--no-heading", "--with-filename", "--line-number",
                                     "--column", "--smart-case", "--hidden", "--glob=!.git/"},

                -- 让预览的设置生效
                buffer_previewer_maker = new_maker,

                -- Default configuration for telescope goes here:
                mappings = {
                    -- insert mode
                    i = {
                        -- map actions.which_key to <C-h> (default: <C-/>)
                        -- actions.which_key shows the mappings for your picker,
                        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                        ["<c-u>"] = false, --  clear prompt
                        ["<c-h>"] = "which_key" -- 显示快捷指令的作用

                        -- 上下移动, 但是tab和shift+tab已经能用了
                        -- ["<c-j>"] = actions.move_selection_next,
                        -- ["<c-k>"] = actions.move_selection_previous
                    },

                    -- normal mode
                    n = {}
                }
            },

            pickers = {
                -- Default configuration for builtin pickers goes here:
                -- picker_name = {
                --   picker_config_key = value,
                --   ...
                -- }
                -- 
                -- Now the picker_config_key will be applied every time you call this
                -- builtin picker
                find_files = {
                    find_command = {"fd", "--type", "f", "--strip-cwd-prefix"}
                },
                buffers = {
                    show_all_buffers = true,
                    sort_lastused = true,
                    mappings = {
                        i = {
                            ["<c-d>"] = actions.delete_buffer
                        }
                    }
                },
                git_status = {
                    preview = {
                        hide_on_startup = false
                    }
                },
                live_grep = {
                    preview = {
                        hide_on_startup = false
                    }
                }

            },

            extensions = {
                -- Your extension configuration goes here:
                fzf = {
                    fuzzy = true, -- false will only do exact matching
                    override_generic_sorter = true, -- override the generic sorter
                    override_file_sorter = true, -- override the file sorter
                    case_mode = "smart_case" -- or "ignore_case" or "respect_case"
                },
                ["ui-select"] = {require("telescope.themes").get_cursor {
                    borderchars = {" ", " ", " ", " ", " ", " ", " ", " "}
                    -- borderchars = {
                    -- prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
                    -- results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
                    -- preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    -- }
                }},
                coc = {
                    -- always use Telescope locations to preview definitions/declarations/implementations etc
                    prefer_locations = true
                }

            }
        }
        require('telescope').load_extension('fzf')
        require('telescope').load_extension('ui-select')
        require('telescope').load_extension('coc')
        require('telescope').load_extension('vim_bookmarks')
        require("telescope").load_extension("lazygit")

    end
}
