-- 工具: buffer 检测与归类
-- 提供 is_real_file 判断, 统一过滤虚拟/特殊窗口

local api = vim.api

local DEFAULT_ALLOWED_BUFTYPES = { "", "acwrite" }
local DEFAULT_SKIP_FILETYPES = {
    "DiffviewFiles",
    "DiffviewFileHistory",
    "git",
    "gitcommit",
    "gitrebase",
    "aerial",
    "TelescopePrompt",
    "TelescopeResults",
    "TelescopePreview",
}
local DEFAULT_SKIP_NAME_PATTERNS = {
    "^diffview://",
}
local DEFAULT_ROOT_MARKERS = {
    ".git",
    ".hg",
    ".svn",
    "pyproject.toml",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "setup.py",
}

local function normalize_path(path)
    if not path or path == "" then
        return nil
    end
    return vim.fs.normalize(path)
end

local function is_descendant(path, base)
    path = normalize_path(path)
    base = normalize_path(base)
    if not path or not base then
        return false
    end
    if path == base then
        return true
    end
    local prefix = base
    if not prefix:match("[/\\]$") then
        prefix = prefix .. package.config:sub(1, 1)
    end
    return path:sub(1, #prefix) == prefix
end

local function normalize_bufnr(bufnr)
    bufnr = bufnr or api.nvim_get_current_buf()
    if not bufnr or bufnr == 0 then
        return nil
    end
    if not api.nvim_buf_is_valid(bufnr) then
        return nil
    end
    return bufnr
end

local function build_lookup(list)
    local lookup = {}
    for _, item in ipairs(list or {}) do
        lookup[item] = true
    end
    return lookup
end

local function matches_pattern(str, patterns)
    if not str or str == "" then
        return false
    end
    for _, p in ipairs(patterns or {}) do
        if str:match(p) then
            return true
        end
    end
    return false
end

local M = {}

--[[@param bufnr number|nil @param opts table?]]
function M.is_real_file(bufnr, opts)
    local b = normalize_bufnr(bufnr)
    if not b then
        return false
    end
    opts = opts or {}
    if opts.require_loaded ~= false and not api.nvim_buf_is_loaded(b) then
        return false
    end
    local allowed_bt = opts.allowed_buftypes or DEFAULT_ALLOWED_BUFTYPES
    local bt_lookup = build_lookup(allowed_bt)
    local bt = vim.bo[b].buftype
    if not bt_lookup[bt] then
        return false
    end
    if opts.require_modifiable ~= false and not vim.bo[b].modifiable then
        return false
    end
    local name = api.nvim_buf_get_name(b)
    if opts.require_name ~= false and name == "" then
        return false
    end
    local skip_patterns = opts.skip_name_patterns or DEFAULT_SKIP_NAME_PATTERNS
    if matches_pattern(name, skip_patterns) then
        return false
    end
    local skip_fts = opts.skip_filetypes or DEFAULT_SKIP_FILETYPES
    if opts.extra_skip_filetypes then
        skip_fts = vim.list_extend(vim.list_extend({}, skip_fts), opts.extra_skip_filetypes)
    end
    local ft_lookup = build_lookup(skip_fts)
    local ft = vim.bo[b].filetype or ""
    if ft_lookup[ft] then
        return false
    end
    return true
end

--[[@param bufnr number|nil @param opts table?{markers?:table,start_path?:string}]]
function M.find_root(bufnr, opts)
    opts = opts or {}
    local markers = opts.markers or DEFAULT_ROOT_MARKERS
    local start_path = opts.start_path
    if not start_path then
        local b = normalize_bufnr(bufnr)
        local name = b and api.nvim_buf_get_name(b) or ""
        if name ~= "" then
            start_path = vim.fs.dirname(name)
        else
            start_path = vim.loop.cwd()
        end
    end
    local match = vim.fs.find(markers, {
        path = start_path,
        upward = true,
    })[1]
    local normalized_start = normalize_path(start_path)
    if match then
        local dir = vim.fs.dirname(match)
        if dir and dir ~= "" then
            return dir
        end
    else
        -- fallback: stdpath("config") / cwd / user-defined路径
        local fallbacks = {}
        local cfg_root = normalize_path(vim.fn.stdpath("config"))
        if cfg_root then
            fallbacks[#fallbacks + 1] = cfg_root
        end
        local cwd = normalize_path(vim.loop.cwd())
        if cwd then
            fallbacks[#fallbacks + 1] = cwd
        end
        if opts.fallback_paths then
            for _, p in ipairs(opts.fallback_paths) do
                local norm = normalize_path(p)
                if norm then
                    fallbacks[#fallbacks + 1] = norm
                end
            end
        end
        for _, candidate in ipairs(fallbacks) do
            if is_descendant(normalized_start, candidate) then
                return candidate
            end
        end
    end
    return normalized_start or start_path
end

M.root = M.find_root

return M
