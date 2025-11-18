-- TypeScript/JavaScript LSP 配置
-- 使用 typescript-language-server
return {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte"
    },
    root_markers = {
        "package.json",
        "tsconfig.json",
        "jsconfig.json",
        ".git"
    },
    settings = {
        typescript = {
            updateImportsOnFileMove = { enabled = true },
            completeFunctionCalls = true,
        },
        javascript = {
            updateImportsOnFileMove = { enabled = true },
            completeFunctionCalls = true,
        }
    }
}