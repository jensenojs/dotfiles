# config 模块应用说明

- 大纲
    - 目标与边界: 提供易读、可逐步迁移的应用侧配置
    - 快速使用: 如何在不影响正式配置的情况下加载 tmp/config
    - 关键选项: `options.lua` 的重要取舍与行号定位
    - 自动命令: `autocmds.lua` 的行为与文本类优化
    - 依赖与条件: `config.env` 与 `im-select` 的可选依赖
    - 权衡与建议: UI 噪声、编辑体验、按文件类型覆写
    - 结构示意: 目录与加载路径

## 目标与边界

- 本目录提供最小但可用的应用端配置, 便于在 tmp 沙箱内快速验证。
- 避免“覆盖式写法”, 尽量采用增量式配置(如 `opt.shortmess:append`).

## 快速使用

- 在 Neovim 内加载 tmp 入口:

  ```vim
  :luafile /Users/jensen/.config/nvim/tmp/init.lua
  ```

- 或在你的正式 `init.lua` 中临时加入(手动清理):

  ```lua
  dofile("/Users/jensen/.config/nvim/tmp/init.lua")
  ```

## 关键选项与取舍

- 文件: `tmp/lua/config/options.lua`
    - 短消息精简 `shortmess` [约 L68-L78]
        - 采用 append 避免覆盖上游默认: `a s t W A I c C`
        - 降低噪声, 尤其补全与写入提示; 与 `report` 形成叠加抑制
    - 反馈时延 `updatetime = 200` [L24-L25]
        - 加速 CursorHold/LSP 诊断刷新, 与插件兼容性较好
    - 持久撤销 `undofile = true` [L110-L112]
        - 需保证撤销目录可写(默认路径已存在即可)
    - 分屏策略 `splitright=true, splitbelow=true` [L152-L154]
        - 更符合现代编辑器直觉, 降低窗口管理负担
    - 语法高亮 `vim.cmd("syntax on")` [L16-L18]
        - 避免将 `opt.syntax` 误作“语言名”设置
    - 兼容模式注释说明 [L33-L34]
        - Neovim 无 `compatible` 选项, 仅保留注释阐述

## 自动命令与文本类优化

- 文件: `tmp/lua/config/autocmds.lua`
    - 焦点/终端事件 `checktime` [L17-L21]
    - yank 高亮 [L39-L45]
    - 分屏均衡 [L47-L53]
    - 快速关闭某些 FileType 窗口 [L55-L77]
    - 文本类优化 `gitcommit, markdown` [L79-L89]
        - `wrap=true, spell=true`
        - `conceallevel=2` 降低隐藏过度, 兼顾可读性
        - `formatoptions:remove {"o","t"}` 避免续注释与自动软折行
    - 目录自动创建 [L89-L99]
    - telescope 折叠修复 [L101-L105]

### 输入法守卫

- 仅当 `require("config.env").has.im_select` 为真, 才注册 `ModeChanged` 自动切换英文输入法 [L23-L37].
- 避免在未安装 `im-select` 的环境里产生无意义系统调用。

## 权衡与建议

- UI 噪声: `shortmess` 与 `report=99999` 共同减噪, 若信息缺失可降低短消息级别或调小 `report`.
- 可见性: 全局 `conceallevel=3` 时 Markdown 可能“隐藏过度”, 已在文本类局部降至 2.
- 行高与状态显示: 若使用现代状态栏, 可视情况将 `cmdheight`(当前为 2) 与 `showcmd`(当前为 true) 降低或关闭以节省空间.
- 按文件类型细化: 借助 `ftplugin` 可进一步对 `formatoptions/wrap/spell/conceallevel` 做更精细控制.

## 目录结构

```text
/Users/jensen/.config/nvim/tmp/
└─ lua/
   └─ config/
      ├─ autocmds.lua
      ├─ env.lua
      ├─ global.lua
      ├─ keymaps.lua
      ├─ options.lua
      └─ README.md  ← 本文件
```

## 加载关系(简化)

```mermaid
flowchart TD
  A[init.lua] --> B[config/global]
  A --> C[config/keymaps]
  A --> D[config/options]
  A --> E[config/autocmds]
  E -->|ModeChanged (opt)| F[im-select 守卫]
  E --> G[文本类优化]
```

## 故障排查

- 查看短消息生效: `:set shortmess?` 观察是否包含 `astWAIcC` 中的标志位.
- 诊断更新迟缓: 确认 `:set updatetime?` 为 200, 以及 LSP 插件未强制覆盖.
- Markdown 显示异常: `:setlocal conceallevel? formatoptions?` 对比期望值.
