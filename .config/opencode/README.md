# OpenCode 配置分层与角色总览

<https://opencode.ai/docs/tools/>

- **目的**: 用一张表说明在 OpenCode 中，各类配置项/文件在“从抽象到具体”的分层中扮演什么角色
- **视角**: 更偏向解释 OpenCode 配置模型本身，而非某个具体个人配置

---

## 分层概要

| 分层 | OpenCode 概念 | 配置位置 / 关键字段 | 主要职责 | 典型问题 |
| --- | --- | --- | --- | --- |
| 行为规则层 | 规则与指令(Rules / Instructions) | `AGENTS.md`、`instructions[]` | 约束所有会话/agent 的通用行为、工具使用习惯、语言与风格 | 「这个助手应该怎么说话、怎么用工具?」|
| 全局配置层 | 核心配置(Config) | `opencode.jsonc` 根级字段 | 定义全局行为: 使用哪些规则文件、哪些 MCP、默认权限、主题等 | 「这台机器上的 OpenCode 默认能力边界是什么?」|
| 能力提供层 | 工具与 MCP 服务器(Tools / MCP Servers) | `tools`、`mcp`、`.config/opencode/tool/*` | 向 LLM 暴露可以调用的实际能力: 文件操作、Web 搜索、文档检索、AST 搜索等 | 「LLM 现在到底能做哪些事? 这些事是怎么被封装的?」|
| 角色定义层 | Agents | `agent/*.md` 或 config 中的 `agents` 字段 | 定义长期角色(主 agent / subagent): 提示词、可用工具、权限、模型选择等 | 「什么样的专家在和我对话? 他的习惯和边界是什么?」|
| 任务模板层 | Commands | `command/*.md` 或 config 中的 `command` 字段 | 定义一次性任务模板: review/test/analyze/commit-message 等 | 「我要触发哪类标准化任务? 用什么输入模板?」|
| 执行策略层 | 权限与 Hook | `permission`、`watcher`、`experimental.hook` | 控制工具调用的交互级别(allow/ask/deny)、以及在文件变更等事件发生时自动触发的命令 | 「哪些操作要先问我? 哪些事情可以自动跑?」|
| 模型与提供方层 | Provider / Model | `provider`、根级 `model`、agent/command 中的 `model` 字段 | 指定底层使用哪个提供商/模型组合，但不写死在指令文案里 | 「这套配置默认跑哪个模型? 某个 agent 需要特殊模型吗?」|

> 阅读顺序建议: 从上到下看这一张表，理解的是「谁规定行为 → 谁定义全局环境 → 谁提供能力 → 谁扮演角色 → 谁描述任务 → 谁控制执行策略 → 谁决定调用哪个 LLM」。

---

## 分层之间的协作关系

- **规则层(Rules)**
    - 提供统一的行为基线: 语言、风格、如何引用文件、何时优先用 MCP 等
    - 被所有 agent/command 共享，是「约束整个系统」的一层

- **配置层(Config)**
    - 通过 `instructions[]` 选择要加载哪些规则文件
    - 通过 `mcp` / `tools` 控制系统拥有的工具集合
    - 通过 `permission` / `watcher` / `experimental.hook` 控制安全边界和自动化行为

- **能力层(Tools / MCP)**
    - 决定「LLM 实际能做什么」: 读写文件、跑命令、查文档、转格式、做 AST 搜索等
    - 有些是内置工具(bash/edit/grep/patch)，有些是通过 MCP 或自定义 tool 提供

- **角色层(Agents)**
    - 在统一规则之上，定义不同的「人格/工作方式」: 学习顾问、文档写手、架构顾问等
    - 同一个工具集合，在不同 agent 下可以被以不同策略调用(例如: 学习型 agent 更偏向解释，review 型 agent 更偏向批判)

- **任务层(Commands)**
    - 把高频任务固化成可复用的模板，使得触发成本很低(`/review`、`/test` 等)
    - 可以指定使用某个 agent 或某个模型，但本身不持久保持上下文

- **执行策略层(Permission / Hook)**
    - 保护边界: 哪些操作允许自动执行，哪些必须 `ask`，哪些彻底禁止
    - 与工具层/任务层交织在一起，形成一套「有约束的自动化」

---

## 如何在扩展配置时使用这张表

- 增加一个**新角色**(例如长期 code reviewer):
    - 落点主要在 **Agent 层**(新增 agent markdown)，可选地在 **Command 层** 加一个 `/long-review` 命令做入口
    - 少量在 **规则层** 或 **能力层** 调整: 如果这个角色需要额外工具，再更新 MCP/自定义 tool

- 增加一个**新工具能力**(例如新的性能分析脚本):
    - 落点主要在 **能力层**(新增 MCP server 或 custom tool)
    - 视情况在 **规则层**(AGENTS.md) 中加「何时使用该工具」说明
    - 如有固定调用模式，可在 **任务层(Command)** 中增加对应命令

- 修改**安全策略**:
    - 主要在 **执行策略层**(permission / watcher / hook)，不需要修改 agent/command 的文案

从这个视角看，你可以始终先问:「我要改的是行为规则、环境能力、角色、任务模板，还是执行策略?」再去找对应的配置位置。

---

## 当前这份配置的具体落地

| 分层 | 当前配置内容 | 备注 | 后续演进方向 / TODO |
| --- | --- | --- | --- |
| 行为规则层 | `AGENTS.md` + `CLAUDE.md` + `GEMINI.md` + `QWEN.md` + `.cursor/rules/*.md` | 多工具共享一套规则，AGENTS.md 以中文、自顶向下分析为主，工具/文档/代码规范都在此约定 | 视需要补充「内核/性能/追踪」领域特定约定；如某些项目需要更严格规范，可在项目级 AGENTS.md 进行覆盖 |
| 全局配置层 | `opencode.jsonc` 根级: `autoupdate: true`, `theme: transparent`, `instructions[]` 已指向上述规则文件 | 统一从全局配置加载规则与 MCP，不在项目级重复配置，保留 `experimental.hook` 作为未来扩展位 | 后续按项目实践情况，在 `experimental.hook` 中按需增加自动化任务(如保存时自动测试/静态检查)，并为项目级配置提供参考模板 |
| 能力提供层 | MCP: `tavily`, `context7`, `ast-grep`, `jupyter`(按需), `serena`, `sequential-thinking`, `markitdown`(按需) | 针对「内核工程 + 数据挖掘」场景定制；API Key 通过 `{env:...}` 注入；serena 已默认启用、jupyter/markitdown 按需启用 | 待 perf/trace 分析脚本成熟后，将其封装为 custom tool 或新增 MCP；视需要评估更多专用 MCP(如 profiler/DB introspection) 并补充到此层 |
| 角色定义层 | 默认主 agent + 交互式创建的 `study`、`doc-writer` | `study` 负责系统设计/理论学习，`doc-writer` 负责文档输出；长期 code reviewer / 架构顾问目前在 README 中规划，尚未落为具体 agent 文件 | 在实践中稳定长期 code review / 架构顾问的工作方式后，将其下沉为独立 agent markdown，并视需要为特定项目增加领域子 agent |
| 任务模板层 | `command/`: `review`, `analyze`, `commit-message`, `perf`, `trace` | 只保留高价值命令：代码审查、深度分析、提交信息、性能/追踪分析；不在 JSON 里硬编码 command，全部通过文件模块化管理 | 视实际工作流需要，按需补充 `/test`、基准测试、数据挖掘等命令模板；为长期角色设计与之配套的命令入口(例如长期 review 会话的便捷启动命令) |
| 执行策略层 | `permission`: `bash/edit/webfetch: allow`, `external_directory: ask`, `doom_loop: deny`; `watcher.ignore` 覆盖 node_modules/dist/build/**pycache**/target 等 | 偏向「熟练用户」的设定：依赖 Git 回滚与审查，防止外部目录误访问与无限循环；文件监控尽量降噪 | 如将来在更敏感的仓库中使用，可在项目级配置中收紧 `bash/edit` 权限或增加 safemode profile；根据实际体验再微调 `watcher.ignore` 白名单 |
| 模型与提供方层 | `provider.minimax` 配置了 `MiniMax-M2` 的访问方式，但未在规则/提示词中写死具体模型 | 通过 provider 抽象出访问端点，真正的模型选择交给运行时或上层工具决定，避免在配置/提示词中硬编码模型名 | 如未来接入更多 provider，可在此统一声明并为特定 agent/command 指定 override；保持提示词与模型解耦，只在此层进行切换与调优 |

> 可以把上一节的「抽象分层」理解为模型，把本节表格理解为当前这台机器上的一个具体实例。
