-- mason 要去下载的一些插件
local mason_install = {}

local data = {
    format = {"clang-format", "sqlfmt", "prettierd", "jq", "gofumpt", "golangci-lint", "goimports", "shfmt", "black",
              "isort", "luacheck" -- formatters
    },
    dap = {"codelldb", "python", "delve"}
}
---Get a specific icon set.

---@param category "dap"|"formatter"
---@param add_space? boolean @Add trailing space after the icon.
function mason_install.get(category, add_space)
    if add_space then
        return setmetatable({}, {
            __index = function(_, key)
                return data[category][key] .. " "
            end
        })
    else
        return data[category]
    end
end

return mason_install

