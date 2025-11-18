# Telescope `current_buffer_fuzzy_find` 报错诊断

## 背景
- 当前使用的 Telescope 版本固定在 `lazy-lock.json` 中的 `3a12a853`（2025-??-?? 提交），见 `lazy-lock.json:68`。
- 你在 `lua/plugins/fuzzy_finder/telescope.lua:162-193` 里将原生 `/` 搜索映射到了 `telescope.builtin.current_buffer_fuzzy_find()`，并保留了默认的 `results_ts_highlight = true` 行为。
- 报错堆栈（E5108 + `attempt to index local 'query' (a nil value)`）指向 `~/.local/share/nvim/lazy/telescope.nvim/lua/telescope/builtin/__files.lua:495`，触发场景为在不具备 Tree-sitter highlight query 的 buffer 中打开该 picker（`help`、`gitcommit`、某些插件自定义 filetype 等都会命中）。

## 复现步骤（基于当前配置）
1. 打开任意缺少 Tree-sitter highlight query 的 buffer，例如 `:help telescope`。
2. 在 Normal 模式下按下 `/`（被重映射为 `current_buffer_fuzzy_find`）。
3. Telescope 初始化预览流程，`vim.treesitter.query.get(lang, "highlights")` 返回 `nil`。
4. `__files.lua:495` 无条件调用 `query:iter_captures`，Lua 抛出 `attempt to index local 'query' (a nil value)`，Nvim 打印三次 E5108。

## 代码级分析
- `lua/plugins/fuzzy_finder/telescope.lua`
  - `keys = { "/" = current_buffer_fuzzy_find }` 让问题变成常规 `/` 搜索的挡板。
  - 你新增的 `current_buffer_fuzzy_find_resilient`（`lines 101-176`）通过 `buffer_supports_ts_highlight` 判断 parser/query 是否存在，并在失败时降级 `results_ts_highlight = false`。这段逻辑已经可以兜底本地配置。
- `~/.local/share/nvim/lazy/telescope.nvim/lua/telescope/builtin/__files.lua`
  - `files.current_buffer_fuzzy_find` 默认设置 `opts.results_ts_highlight = vim.F.if_nil(opts.results_ts_highlight, true)`。
  - 当 `true` 且 `vim.treesitter.query.get(lang, "highlights")` 返回 `nil` 时，`query:iter_captures(... )`（第 495 行）直接报错，没有判空。
  - 只要任何一个 filetype 有 parser 但没有 `highlights.scm`，就会触发该路径。

## 影响范围
| 触发条件 | 说明 |
| --- | --- |
| buffer 有 Tree-sitter parser，但缺少 `highlights` query | help、gitcommit、lazy 产生的特殊 filetype、尚未维护 query 的语言等 |
| `current_buffer_fuzzy_find` 被频繁调用 | 例如重载 `/`、`<leader>/` 等高频键 |
| `results_ts_highlight` 保持默认 `true` | 没有在 picker 层显式关闭 |

## 为什么是 Tree-sitter query？
- `vim.treesitter.language.get_lang(filetype)` 返回的语言编码存在，但 `queries/<lang>/highlights.scm` 缺失 ⇒ `vim.treesitter.query.get` 返回 `nil`。
- Telescope 没有 guard，默认视作 query 对象，任何 `:iter_captures` 调用都会炸。
- 与文件体积、ripgrep、previewer 等无关，纯粹是高亮管线的问题。

## 上游状态
- 截至 2025-11-19，通过 GitHub issue 搜索（关键字 `current_buffer_fuzzy_find`, `results_ts_highlight`, `query nil`）尚未发现官方修复或讨论。
- master 分支最新 `lua/telescope/builtin/__files.lua` 仍旧缺少对 `query == nil` 的处理，因此该 bug 在上游仍可复现。

## 建议的修复策略

### A. 配置层兜底（当前 repo 已实现）
1. `buffer_supports_ts_highlight(bufnr)`：检测 parser + highlight query。
2. 若不支持则动态传入 `{ results_ts_highlight = false }`，并用 `vim.notify_once` 解释降级原因。
3. `pcall(builtin.current_buffer_fuzzy_find, opts)`，捕获 `attempt to index local 'query'`，二次降级调用。
4. 该方案已经写入 `lua/plugins/fuzzy_finder/telescope.lua:101-176`，即使上游未修复，也能稳定使用。

### B. Upstream PR 提案
1. 修改 `lua/telescope/builtin/__files.lua`：
   ```lua
   local ok, query = pcall(vim.treesitter.query.get, lang, "highlights")
   if not ok or not query then
     opts.results_ts_highlight = false
   else
     -- 原有高亮逻辑
   end
   ```
2. 或者更小的修补：在 `for id, node in query:iter_captures(...)` 前添加
   ```lua
   if not query then goto no_ts_highlight end
   ```
   并将 `no_ts_highlight` 分支设置 `opts.results_ts_highlight = false`。
3. 完成后附上 regression test：在没有 `highlights` 的 mock language 上运行 `current_buffer_fuzzy_find`，确保不会报错。
4. PR 描述需说明触发条件（parser 存在但 query 缺失），并引用报错堆栈。

### C. 运行时探测（可独立提交给 upstream）
- 在 `vim.treesitter.get_parser` 失败或 `vim.treesitter.language.get_lang` 返回空字符串时，也应跳过高亮。虽然本地 `buffer_supports_ts_highlight` 已覆盖，但 upstream 也应该一样处理。

## 建议输出
1. **内部文档**：保留本文件，以便未来定位原因或撰写 upstream issue/PR。
2. **Upstream Issue 模板要点**：
   - 触发步骤 & 最小复现（两行 Lua + `nvim -u NONE`）。
   - 环境信息：Neovim 版本、Telescope commit、是否启用 Tree-sitter parser。
   - 错误日志 & callstack。
   - 预期行为：缺少 highlights 时自动回退到纯文本高亮，而不是报错。
3. **可选**：将现有 `current_buffer_fuzzy_find_resilient` 提炼成 `utils`，方便其它 picker 复用。

## 结论
- 根因：Telescope 默认启用的 Tree-sitter 结果高亮在 `vim.treesitter.query.get` 返回 `nil` 时没有做任何保护，导致 `current_buffer_fuzzy_find` 在缺少 `highlights` 的 buffer 中必然报错。
- 影响：任何把 `/`（或其它常用键）映射到该 picker 的配置都会受影响，交互体验极差。
- 状态：本地已通过 runtime 探测 + 降级方案规避，但上游仍需补丁；一旦官方修复，可考虑移除本地兜底逻辑以减少维护成本。
