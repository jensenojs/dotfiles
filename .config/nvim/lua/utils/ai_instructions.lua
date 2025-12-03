local M = {}

M.primary = "AGENTS.md"

M.extra = {
    "CLAUDE.md",
    ".cursor/rules/*.md",
    ".windsurf/rules/*.md",
    "GEMINI.md",
    "QWEN.md",
}

local uv = vim.uv or vim.loop

local function read_file(path)
    local fd = uv.fs_open(path, "r", 438)
    if not fd then
        return nil
    end
    local stat = uv.fs_fstat(fd)
    if not stat or stat.size == 0 then
        uv.fs_close(fd)
        return nil
    end
    local content = uv.fs_read(fd, stat.size, 0)
    uv.fs_close(fd)
    if not content or content == "" then
        return nil
    end
    content = content:gsub("\r\n", "\n")
    if not content:match("%S") then
        return nil
    end
    return content
end

local function expand_pattern(root, pattern)
    local full_pattern = vim.fs.joinpath(root, pattern)
    local ok, result = pcall(vim.fn.glob, full_pattern, true, true)
    if not ok or type(result) ~= "table" then
        return {}
    end
    return result
end

---@param root string
---@return string[]
function M.get_extra_files(root)
    local files = {}
    for _, pattern in ipairs(M.extra) do
        for _, path in ipairs(expand_pattern(root, pattern)) do
            table.insert(files, path)
        end
    end
    return files
end

---@param root string
---@return string|nil
function M.load_extra(root)
    local parts = {}
    for _, path in ipairs(M.get_extra_files(root)) do
        local content = read_file(path)
        if content then
            local name = vim.fs.basename(path)
            table.insert(parts, string.format("# Instructions from %s\n\n%s", name, content))
        end
    end
    if #parts == 0 then
        return nil
    end
    return table.concat(parts, "\n\n")
end

return M
