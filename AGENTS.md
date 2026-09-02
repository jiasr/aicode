# AGENTS.md（aicode 父仓库 / superproject）

> 本文件是 AI 编码 Agent（CodeBuddy / Qoder / Cursor / Claude / Copilot 等）在 **aicode** 父仓库工作时的总入口。
> **开发规范的唯一载体是 `doc/开发规范汇总.md`**（同仓库 `doc/` 目录，跨所有工具/仓库共享）。本文件不重复规范细节，只做索引与跨仓库协作纪律补充。开始任何任务前，**必须先阅读该汇总并遵守其全部条款**。

## 必读（开工前）
- 规范唯一载体：`doc/开发规范汇总.md`（数据库/后端、飞鹅打印、前端交互、业务规则、源码管理五类约定）
- 源码管理铁律（第五章）：push 前必拉、原子提交、子模块联动、禁敏感信息、文档走正规流程、提交信息 `<type>: <中文描述>`
- 提交前必须运行 `e:\aicode\check-commit.ps1`，并确保通过 `.githooks/pre-push` 检查

## 仓库结构（superproject）
`e:\aicode` 是 git 父仓库（superproject），以下为其子模块（独立 git 仓库）：
- `mall-admin`：前端（Vue3 + Vite + Element Plus + Pinia）
- `mallservice-python`：后端（Flask + Flask-RestX + MySQL）
- `mall-littleprogram`：微信小程序
- `jinxiaocun`：进销存相关
- `SDK_ReleaseforAndroid`：Android SDK

各子模块根目录均含各自的 `AGENTS.md`（项目特定说明），但**规范内容一律以 `doc/开发规范汇总.md` 为准**。

## 跨仓库 / 多 Agent 协作纪律
1. **先读规范再动手**：每次新会话、重开工作区先读 `doc/开发规范汇总.md` 与本地记忆；规范以该汇总为准。
2. **分支隔离**：每个并行任务用独立分支（`feat/*`、`fix/*`）；禁止在 detached HEAD 或 main 上直接开发；push 前 `git pull --rebase`，禁止 `--force` push。
3. **契约先行**：跨仓库（前后端）改动先冻结接口/字段契约，再并行实现。
4. **勿碰临时/敏感文件**：`*_tmp*`、本地缓存、`token`/`密钥`/`.env`/`*.key`/`*.pem` 一律不纳入提交。
5. **改规范走正规流程**：新增/修正规范必须同时更新 `doc/开发规范汇总.md`（更新日期 + 注明来源 `[CodeBuddy]`/`[Qoder]`/`[人工:姓名]` + 说明原因），随代码或单独提交（铁律 5）。
6. **子模块联动（铁律 3）**：任一子模块提交推送后，必须在本父仓库执行 `git add <子模块路径>` 并提交推送指针更新，否则父仓库持续显示子模块 M 变更。

## 禁止
- 禁止 `git push --force`
- 禁止把敏感信息（`gds_token`、`.env`、`*.key`、`*.pem`、`password`、`secret`）提交入库
- 禁止绕过 `check-commit.ps1` 与 pre-push hook（`--no-verify` 仅限确认合规时）

## 提交前自检
```powershell
cd e:\aicode
powershell -ExecutionPolicy Bypass -File .\check-commit.ps1
```
全部 PASS 再 push；任一 FAIL 先修复。
