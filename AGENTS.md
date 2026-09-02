# AGENTS.md（aicode 父仓库 / superproject）

> 本仓库（aicode superproject）的 AI 协作规范与开发纪律，以 `doc/开发规范汇总.md`（同仓库 doc 目录）为**唯一载体**。
> **开始任何任务前，必须先阅读并遵守该汇总文档**（含数据库/后端、飞鹅打印、前端交互、业务规则、源码管理五类约定与 git 协作铁律）。

> 注：「父仓库根目录」指 clone 下来的 aicode 目录；脚本用相对路径 `./check-commit.ps1` 在该目录运行。

## 仓库结构
- 父仓库（aicode），以下为其子模块（独立 git 仓库）：
  - `mall-admin`（前端）、`mallservice-python`（后端）、`mall-littleprogram`、`jinxiaocun`、`SDK_ReleaseforAndroid`
- 各子模块根目录含各自的 `AGENTS.md`（仓库特定说明），但**规范内容一律以 `doc/开发规范汇总.md` 为准**。

## 本文件不重复规范
- 源码管理铁律、子模块联动、提交前检查、禁止项等全部细节见 `doc/开发规范汇总.md` 第五章；本文件仅做索引与仓库事实说明。
