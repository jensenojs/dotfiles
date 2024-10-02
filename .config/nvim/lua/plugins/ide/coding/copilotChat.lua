-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
-- https://github.com/arthur-hsu/nvim/blob/main/lua/plugins/copilotchat.lua
local bind = require("utils.bind")
local map_cr = bind.map_cr
local map_callback = bind.map_callback
local map_cmd = bind.map_cmd

local keymaps = {
    ["n|<leader>cP"] = map_callback(function()
        vim.cmd("CopilotActions normal")
    end):with_noremap():with_silent():with_desc(" CopilotChat : Prompt actions"),

    ["vx|<leader>cP"] = map_callback(function()
        vim.api.nvim_command("y")
        vim.api.nvim_command("normal v")
        vim.cmd("CopilotActions visual")
    end):with_noremap():with_silent():with_desc(" CopilotChat : Prompt actions"),

    ["nv|<leader>cp"] = map_callback(function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
            require("CopilotChat").ask(input)
        end
    end):with_noremap():with_silent():with_desc(" CopilotChat : Quick chat"),


    -- ["n|<leader>"] = map_callback(function()
    -- end):with_noremap():with_silent():with_desc(" CopilotChat : ")

    ["nvx|<leader>cc"] = map_cmd(":CopilotChatAnnotations<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : add a comment"),

    ["nvx|<leader>ce"] = map_cmd(":CopilotChatExplain<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : explain code"),

    ["nvx|<leader>cf"] = map_cmd(":CopilotChatFixError<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : fix error"),

    ["nvx|<leader>cr"] = map_cmd(":CopilotChatRefactor<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : refactor code"),

    ["nvx|<leader>cs"] = map_cmd(":CopilotChatSuggestion<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : provide suggestion"),

    ["nvx|<leader>ct"] = map_cmd(":CopilotChatToggle<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : toggle chat"),

    ["nvx|<leader>cR"] = map_cmd(":CopilotChatReset<cr>"):with_noremap():with_silent():with_desc(
        " CopilotChat : reset chat")

    -- ["nvx|<leader>"] = map_cmd(":CopilotChat<cr>"):with_noremap():with_silent():with_desc(" CopilotChat : "),

}

bind.nvim_load_mapping(keymaps)

local function find_lines_between_separator(lines, pattern, at_least_one)
    local line_count = #lines
    local separator_line_start = 1
    local separator_line_finish = line_count
    local found_one = false

    -- Find the last occurrence of the separator
    for i = line_count, 1, -1 do -- Reverse the loop to start from the end
        local line = lines[i]
        if string.find(line, pattern) then
            if i < (separator_line_finish + 1) and (not at_least_one or found_one) then
                separator_line_start = i + 1
                break -- Exit the loop as soon as the condition is met
            end

            found_one = true
            separator_line_finish = i - 1
        end
    end

    if at_least_one and not found_one then
        return {}, 1, 1, 0
    end

    -- Extract everything between the last and next separator
    local result = {}
    for i = separator_line_start, separator_line_finish do
        table.insert(result, lines[i])
    end

    return result, separator_line_start, separator_line_finish, line_count
end

local commit_callback = function(response, source, staged)
    local bufnr = source.bufnr
    local buftype = vim.api.nvim_get_option_value("filetype", {
        buf = bufnr
    })
    local notify = require("notify")
    local accept = require("CopilotChat").config.mappings.accept_diff.normal
    local quit = require("CopilotChat").config.mappings.close.normal
    local showdiff = require("CopilotChat").config.mappings.show_diff.normal
    local lines = {}

    for line in response:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local res, start_line, end_line, total_lines = find_lines_between_separator(lines, "^```%w*$", true)
    local max_line = 0
    for i, line in ipairs(res) do
        if #line > max_line then
            max_line = #line
        end
    end

    local result = table.concat(res, "\n")
    if total_lines == 0 then
        notify("No commit msg", "error", {
            title = "Git commit"
        })
        vim.api.nvim_input(quit)
        return
    end
    local separator = "\n" .. string.rep("─", max_line) .. "\n"
    local input = vim.fn.input("Commit message" .. separator .. result .. separator .. "auto commit? (y/n)")
    if string.match(input, "^[yY]$") then
        if string.match(buftype, "gitcommit") then
            vim.api.nvim_input(accept)
            vim.api.nvim_input(quit)
        else
            local tmpfile = "/tmp/copilot_commit_msg"
            local file = io.open(tmpfile, "w")
            if not file then
                notify("Failed to open file: " .. tmpfile, "error", {
                    title = "Git commit"
                })
                vim.api.nvim_input(quit)
                return
            end
            file:write(result)
            file:close()

            local add = "git add -A"
            local commit = "git commit -F " .. tmpfile
            local push = "git push"

            local cmd = ""

            if not staged then
                cmd = add .. " && "
            end
            local commit_cmd = cmd .. commit .. " && " .. push

            local first_notify = notify(result, "info", {
                title = "Git committing changes in backend ...",
                icon = "",
                on_open = function(win)
                    local buf = vim.api.nvim_win_get_buf(win)
                    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
                end
            })
            local handle
            handle = vim.loop.spawn("sh", {
                args = {"-c", commit_cmd},
                stdio = {nil, nil, nil}
            }, function(code, signal)
                handle:close()
                os.remove(tmpfile)
                if code == 0 then
                    notify(result, "info", {
                        title = "Git commit success",
                        icon = "",
                        replace = first_notify,
                        on_open = function(win)
                            local buf = vim.api.nvim_win_get_buf(win)
                            vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
                        end
                    })
                else
                    local message = "return code:" .. code .. " signal: " .. signal
                    notify(message, "error", {
                        title = "Git commit fail",
                        icon = "",
                        replace = first_notify,
                        on_open = function(win)
                            local buf = vim.api.nvim_win_get_buf(win)
                            vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
                        end
                    })
                end
            end)

            vim.api.nvim_input(quit)
        end
    else
        notify("Abort", "info", {
            icon = "",
            title = "Git commit"
        })
    end
end

return {{
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    event = "VeryLazy",
    dependencies = {{"zbirenbaum/copilot.lua"}, -- or github/copilot.vim
    {"nvim-lua/plenary.nvim"}, -- for curl, log wrapper
    {"nvim-telescope/telescope.nvim"} -- for telescope help actions (optional)
    },
    opts = {
        question_header = "  User ", -- Header to use for user questions
        answer_header = "  Copilot ", -- Header to use for AI answers
        error_header = "  Error ", -- Header to use for errors
        window = {
            layout = "vertical", -- 'vertical', 'horizontal', 'float'
            relative = "editor", -- 'editor', 'win', 'cursor', 'mouse'
            border = "rounded", -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
            width = 0.5, -- fractional width of parent
            height = 0.6, -- fractional height of parent
            row = nil, -- row position of the window, default is centered
            col = nil, -- column position of the window, default is centered
            title = "  CopilotChat ", -- title of chat window
            footer = nil, -- footer of chat window
            zindex = 1 -- determines if window is on top or below other floating windows
        },
        mappings = {
            complete = {
                detail = "Use @<Tab> or /<Tab> for options.",
                insert = "<Tab>"
            },
            close = {
                normal = "q",
                insert = "<C-c>"
            },
            reset = {
                normal = "<C-l>",
                insert = "<C-l>"
            },
            submit_prompt = {
                normal = "<CR>",
                insert = "<C-m>"
            },
            accept_diff = {
                normal = "<C-a>",
                insert = "<C-a>"
            },
            show_diff = {
                normal = "gd"
            },
            show_system_prompt = {
                normal = "gp"
            },
            show_user_selection = {
                normal = "gs"
            }
        }
    },

    config = function(_, opts)
        vim.api.nvim_set_hl(0, "CopilotChatSpinner", {
            link = "DiagnosticVirtualTextInfo"
        })

        local select = require("CopilotChat.select")

        local prompts = {
            QuickChat = {
                selection = select.unnamed
            },
            QuickChatWithFiletype = {},
            Explain = {
                prompt = "/COPILOT_EXPLAIN 解释这段代码如何运行。"
            },
            FixError = {
                prompt = "/COPILOT_FIX 请解释以上代码中的错误并提供解决方案。"
            },
            Suggestion = {
                prompt = "/COPILOT_REFACTOR 请查看以上代码并提供改进建议的sample code。"
            },
            Annotations = {
                prompt = "/COPILOT_REFACTOR 为所选程序编写文档。 回复应该是一个包含原始程序的程序块，并将文档作为注释新增。 为所使用的编程语言使用最合适的文档样式（例如 JavaScript的JSDoc, Python的docstrings等)"
            },
            Refactor = {
                prompt = "/COPILOT_REFACTOR 请重构以上代码以提高其清晰度和可读性。"
            },
            Tests = {
                prompt = "/COPILOT_TESTS 简要说明以上代码的工作原理，然后生成单元测试。"
            },
            Translate = {
                prompt = "将英文翻译成简体中文, 或是将中文翻译成英文, 回答中不需要包含行数"
            },
            FixDiagnostic = {
                prompt = "/COPILOT_FIX Please assist with the following diagnostic issue in file:",
                selection = select.diagnostics
            },
            Commit = {
                prompt = "使用中文总结这次提交的更改，并使用 commitizen 惯例编写提交消息。确保标题最多 50 个字符，消息在 72 个字符处换行。将整个消息用 gitcommit 语言的代码块包裹起来。",
                selection = select.gitdiff,
                callback = function(response, source)
                    commit_callback(response, source, false)
                end
            },
            CommitStaged = {
                -- prompt            = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
                prompt = "使用中文总结这次提交的更改，并使用 commitizen 惯例编写提交消息。确保标题最多 50 个字符，消息在 72 个字符处换行。将整个消息用 gitcommit 语言的代码块包裹起来。",
                selection = function(source)
                    local bufnr = source.bufnr
                    local buftype = vim.api.nvim_get_option_value("filetype", {
                        buf = bufnr
                    })
                    if string.match(buftype, "gitcommit") then
                        return opts.selection(source)
                    else
                        return select.gitdiff(source, true)
                    end
                end,
                callback = function(response, source)
                    commit_callback(response, source, true)
                end
            }
        }
        opts.prompts = prompts
        require("CopilotChat").setup(opts)

        -- NOTE: This function creates an unordered list.
        -- local options = {}
        -- table.insert(options, "Quick Chat")
        -- table.insert(options, "Quick Chat with file type")
        -- for key, value in pairs(prompts) do
        --     table.insert(options, key)
        -- end

        -- NOTE: So we need to create an ordered list.
        local options = {"QuickChat", "QuickChatWithFiletype", "Translate", "Commit", "CommitStaged", "Explain",
                         "FixError", "Suggestion", "Annotations", "Refactor", "Tests"}

        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local Chat_cmd = "CopilotChat"
        local Chat_prompts = require("CopilotChat").prompts()

        local Telescope_CopilotActions = function(opts, mode)
            opts = opts or {}
            pickers.new(opts, {
                prompt_title = "Select Copilot prompt",
                finder = finders.new_table({
                    results = options
                }),
                sorter = conf.generic_sorter(opts),

                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local selected = action_state.get_selected_entry()
                        local choice = selected[1]
                        local get_type = vim.api.nvim_buf_get_option(0, "filetype")
                        local FiletypeMsg = Chat_cmd .. " " .. "这是一段 " .. get_type .. " 代码, "

                        local msg = nil
                        local selection = nil
                        local callback = nil
                        -- Find the item message and selection base on the choice
                        for item, body in pairs(Chat_prompts) do
                            if item == choice then
                                msg = body.prompt
                                selection = body.selection
                                callback = body.callback
                                break
                            end
                        end
                        -- If the choice is QuickChat or QuickChatWithFiletype, open the input dialog
                        if msg == nil then
                            local input = vim.fn.input("Quick Chat: ")
                            if input ~= "" then
                                msg = input
                            end
                        end
                        -- If the choice is QuickChat, set the selection to nil
                        if choice == "QuickChat" then
                            Ask_msg = msg
                            selection = function()
                                return nil
                            end
                        else
                            if string.find(choice, "Commit") or string.find(choice, "Translate") then
                                Ask_msg = msg
                            else
                                Ask_msg = FiletypeMsg .. msg
                            end

                            if selection == nil then
                                if mode == "normal" then
                                    selection = select.buffer
                                else
                                    selection = select.visual
                                end
                                print("selection is nil")
                            end
                        end

                        require("CopilotChat").ask(Ask_msg, {
                            selection = selection,
                            callback = callback
                        })
                    end)
                    return true
                end
            }):find()
        end

        vim.api.nvim_create_user_command("CopilotActions", function(args)
            local mode = string.lower(args.args)
            Telescope_CopilotActions(require("telescope.themes").get_dropdown({
                selection_caret = " "
            }), mode)
        end, {
            nargs = 1,
            range = true,
            complete = function()
                return {"normal", "visual"}
            end
        })
    end,

    -- keys = {{
    --     "<leader>cq",
    --     function()
    --         local input = vim.fn.input("Quick Chat: ")
    --         if input ~= "" then
    --             require("CopilotChat").ask(input)
    --         end
    --     end,
    --     desc = " CopilotChat - Quick chat",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cp",
    --     function()
    --         vim.api.nvim_command("y")
    --         vim.api.nvim_command("normal v")
    --         vim.cmd("CopilotActions visual")
    --     end,
    --     desc = " CopilotChat - Prompt actions",
    --     mode = {"v", "x"}
    -- }, {
    --     "<leader>cp",
    --     function()
    --         -- require("CopilotChat.code_actions").show_prompt_actions()
    --         vim.cmd("CopilotActions normal")
    --     end,
    --     desc = " CopilotChat - Prompt actions",
    --     mode = {"n"}
    -- }, {
    --     "<leader>co",
    --     "<cmd>CopilotChatOpen<cr>",
    --     desc = " CopilotChat - Open chat",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cq",
    --     "<cmd>CopilotChatClose<cr>",
    --     desc = " CopilotChat - Close chat",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>ct",
    --     "<cmd>CopilotChatToggle<cr>",
    --     desc = " CopilotChat - Toggle chat",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cR",
    --     "<cmd>CopilotChatReset<cr>",
    --     desc = " CopilotChat - Reset chat",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cD",
    --     "<cmd>CopilotChatDebugInfo<cr>",
    --     desc = " CopilotChat - Show diff",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>ce",
    --     "<cmd>CopilotChatExplain<cr>",
    --     desc = " CopilotChat - Explain code",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cf",
    --     "<cmd>CopilotChatFixError<cr>",
    --     desc = " CopilotChat - Fix Error",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cs",
    --     "<cmd>CopilotChatSuggestion<cr>",
    --     desc = " CopilotChat - Provide suggestion",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cr",
    --     "<cmd>CopilotChatRefactor<cr>",
    --     desc = " CopilotChat - Refactor code",
    --     mode = {"n", "v", "x"}
    -- }, {
    --     "<leader>cc",
    --     "<cmd>CopilotChatAnnotations<cr>",
    --     desc = " CopilotChat - Add a comment",
    --     mode = {"n", "v", "x"}
    -- }}
}}
