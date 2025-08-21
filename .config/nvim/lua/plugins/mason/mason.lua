-- 目标: 仅初始化 mason.nvim, 提供统一安装入口
local pip_args
local proxy = os.getenv 'PIP_PROXY'
if proxy then
    pip_args = {'--proxy', proxy}
else
    pip_args = {}
end

return {
    "williamboman/mason.nvim",
    cmd = {"Mason", "MasonInstall", "MasonUninstall", "MasonUpdate"},
    event = {'BufReadPost', 'BufNewFile', 'VimEnter'},
    opts = {
      pip = {
        upgrade_pip = false,
        install_args = pip_args
      },
    },
    config = function(_, opts)
        pip = {
            upgrade_pip = false,
            install_args = pip_args
        }
        local ok_mason, mason = pcall(require, "mason")
        if ok_mason then
            mason.setup(opts)
        end

        -- 自动安装工具(非 LSP server)
        local ok_utils, mason_utils = pcall(require, "utils.mason")
        if not ok_utils then
            return
        end
        local tools = mason_utils.tools()
        if #tools == 0 then
            return
        end

        local ok_reg, registry = pcall(require, "mason-registry")
        if not ok_reg then
            return
        end
        local function ensure()
            for _, name in ipairs(tools) do
                local ok_pkg, pkg = pcall(registry.get_package, name)
                if ok_pkg and not pkg:is_installed() then
                    pkg:install()
                end
            end
        end
        if registry.refresh then
            registry.refresh(ensure)
        else
            ensure()
        end
    end
}
