# 工作汇报

> lite recipe 见 [SKILL.md 速查表](../../../../SKILL.md#常用-recipe-速查表lite-recipe--可直接执行无需读行动指南文件)。

## 路径分歧（先判定后选 recipe）

`dws report` 与 `dws doc` 是两个不同的产品，覆盖不同的"周报 / 日报"场景。在选 recipe 前先做一次判定：

| query 中是否含强信号 | 选哪个 recipe | 默认值 |
|---------------------|---------------|--------|
| 含「钉钉日志 / OA 周报 / 我的钉钉日志 / 日报模板 / 周报模板 / 提交日志 / 填模版」 | `submit-report`（走 dws report create） | — |
| 含「在线文档 / 写一篇文档 / 整理成文档 / 文档保存」 | `generate-*-report`（走 dws doc create） | — |
| **无强信号**（如"写日报"、"写周报"、"整理本周工作"）| `generate-*-report`（走 dws doc create） | 默认 |

注：

- "钉钉日志"在用户口语中多指 OA 周报应用，但偶有泛指日志/记录，必要时反问澄清。
- 仅当用户**明确**说"钉钉日志（OA 应用）"或类似强信号时才切到 `submit-report`；否则不要主动推荐 OA 日志路径——多数用户的"周报"实际期望是文档（可分享、可编辑、长文本）。

## Recipe 速查

| Recipe | 行动指南（固定路线） |
|--------|-------------------|
| generate-daily-report | 1. 按[「多源并行采集」](../_common/conventions.md#多源并行采集公共模式)执行（时间=今日）<br>2. 交叉汇总并把日报内容写入临时文件 `<tmp>.md`（UTF-8，真实换行）<br>3. **创建文档**：`doc create --name "<日报名>" --content-file <tmp>.md`（> 200KB 按 [write-doc 兜底](./04-document.md) 走 create 空 → 循环 update） |
| generate-weekly-report | 1. 按[「多源并行采集」](../_common/conventions.md#多源并行采集公共模式)执行（时间=本周）<br>2. 交叉对比并把周报内容写入临时文件 `<tmp>.md`<br>3. **创建文档**：`doc create --name "<周报名>" --content-file <tmp>.md`（兜底同上） |
| submit-report | **0. 前置判定**：query 含「钉钉日志 / OA 周报模板 / 我的钉钉日志」等强信号？是 → 继续；否 → 切换到 `generate-weekly-report` 或 `generate-daily-report`（走 dws doc）<br>1. 按[「多源并行采集」](../_common/conventions.md#多源并行采集公共模式)执行（时间=当日）<br>2. `report template list --format json` → 取 `report_template_id`<br>3. `report template detail --name "<模版名>" --format json` → 取 `result.report_template_fields[]`，每项含 `field_name`/`field_sort`/`field_type`<br>4. **把 contents 写入临时文件**（避免 shell 引号问题）：每项含 `key`/`sort`/`content`/`contentType`/`type` 五个字段，**严格映射** `field_name → key`、`field_sort → sort`、`field_type → type`，再填 `content` 与 `contentType`<br>5. `report create --template-id <id> --contents-file <tmp>.json --format json` → CLI 会在创建成功后自动反查详情并追加 `dingtalkOpenMarkdownLink` / `dingtalkOpenUrl` / `dingtalkOpenLink` 字段；取返回的 `reportId` 与钉钉打开链接<br>6. final reply 优先直接使用 `dingtalkOpenMarkdownLink`，让用户点击跳转钉钉客户端查看 / 修改；仅当 create 返回中缺少 `dingtalkOpenUrl` 时，才手动执行 `report detail --report-id <reportId> --format json` 补取 `result.url`，再包装成 `[在钉钉中查看日志](result.url)`<br>**不要走 doc 写文档**；**禁止跳过 2/3 步**直接 create；**禁止把 raw `dingtalk://...` URL 直接粘到回复**，必须包成 markdown link |
| generate-monthly-report | 1. 按[「多源并行采集」](../_common/conventions.md#多源并行采集公共模式)执行（时间=当月）<br>2. `report sent --start "<月初ISO>" --end "<月末ISO>"` → 取当月已提交日志<br>3. 按周分段归纳并把月报内容写入临时文件 `<tmp>.md`<br>4. **创建文档**：`doc create --name "<月报名>" --content-file <tmp>.md`（兜底同上） |
| generate-topic-report | 1. 提取主题关键词；推断时间范围（"最近"默认近 30 天）<br>2. 按[「多源并行采集」](../_common/conventions.md#多源并行采集公共模式)执行<br>3. 按时间线排列，交叉归纳核心结论/决策/行动项/未解决问题/演进脉络，并把内容写入临时文件 `<tmp>.md`<br>4. **创建文档**：`doc create --name "<报告名>" --content-file <tmp>.md`（兜底同上） |
