# Lite Recipe 完整步骤

> 核心流程步骤 3 判定为 lite 后，按本文件中对应 recipe 的步骤**直接执行**。
> 所有命令均须加 `--format json`（下文省略）。

## #1 消息沟通

### send-message

1. 查收件人：单聊 → `contact user search --query "<姓名>"` → `openDingTalkId`（推荐）；若 contact 搜不到 → `aisearch person --keyword "<姓名>" --dimension name` → `userId`，再按 [chat.md](../products/chat.md)「openDingTalkId 获取方式」转为 `openDingTalkId`。群聊 → `chat search --query "<群名>"` → `openConversationId`。
2. 发送：`chat message send --open-dingtalk-id <openDingTalkId> --text "<内容>"`（推荐）或 `--group <openConversationId> --text "<内容>"`。仅当无法获取 openDingTalkId 时才用 `--user <userId>`（备选，不支持富媒体）。

### create-group

1. 查成员：`aisearch person --keyword "<姓名>" --dimension name` → 各 `userId`。
2. 建群：`chat group create --name "<群名>" --users <userId1>,<userId2>,...`

### send-by-webhook

`chat message send-by-webhook --token <token> --title "<标题>" --text "<内容>"`

### search-common-group

`chat search-common --nicks "<昵称1>,<昵称2>" --limit 20 --cursor 0`

- `--nicks` 传人员昵称/花名（逗号分隔）
- `--match-mode AND`（默认）= 所有人都在群里；`OR` = 任一人在群里
- 用户说"我和XX的共同群" → nicks 包含"我"时，需先 `contact user get-self` 取自己昵称，再拼接

### focus-messages

拉取"我特别关注的人最近发的消息"——一刀切聚合视图，**零参数即用**。

`chat message list-focused --limit 50`

- 触发 query：`"我特别关注的人最近发了什么消息"`、`"关注的人最近聊了啥"`、`"星标联系人最近的动态"`、`"星标联系人发的群消息"`、`"特别关注的消息"`
- **强消歧**（与 `contact relation list-my-followings` 区分）：query 含动词【发/说/聊/讲】或名词【消息/聊天/动态/最新内容】 → 走 `list-focused`；query 终点是"人员列表"（如"我关注了谁"、"特别关注的人有哪些"）→ 才走 `relation list-my-followings`
- 翻页：`hasMore=true` 时用响应中的 `nextCursor` 作为下次 `--cursor`
- 若需"按人精控"（每个特别关注人各自的消息流）：先 `contact relation list-my-followings` 取 `openDingTalkId`，再对每个 ID 调 `chat message list-by-sender --sender-open-dingtalk-id <openDingTalkId> --start <ISO> --end <ISO>`

## #2 任务管理

### create-todo

1. 确定执行者：指定姓名 → `aisearch person --keyword "<姓名>" --dimension name` → `userId`；未指定 → `contact user get-self` → `userId`；多人 → 逐个搜索逗号拼接。
2. 创建：`todo task create --title "<标题>" --executors <userId>[,<userId2>...]`（可选 `--due "<截止ISO>"`）→ `todoTaskId`

### todo-query-ops

- 查询：`todo task list [--status false|true]`（不传=全部）
- 详情：`todo task get --task-id <id>`
- 完成/重开：`todo task done --task-id <id> --status <true|false>`
- 按主题筛选：list 后按标题关键词过滤

## #3 会议日程

### list-today-meetings

**优先**：`python scripts/calendar_today_agenda.py [today|tomorrow|week]`
备选：`dws calendar event list --start "<今日起始ISO>" --end "<今日结束ISO>"`（须加 `--format json`）

### check-users-busy

查询多人在某时段内的闲忙（**busy**，不是用 `event list` 扫日程）：

1. 解析用户：对每个姓名执行 `aisearch person --keyword "<姓名>" --dimension name` → `userId`；多人将 `userId` 用英文逗号拼接（无空格或按 [calendar.md](../products/calendar.md) `busy search` 要求）。
2. 确认时段：用户须给出或可收敛为明确的 `--start` / `--end`（ISO-8601）；若未给出，**先追问**起止时间，禁止用任意默认全天窗口代替用户意图。
3. 执行：`dws calendar busy search --users <userId1,userId2,...> --start "<ISO>" --end "<ISO>" --format json`

详见 [calendar.md](../products/calendar.md) 中「查询用户闲忙状态」。

## #4 文档知识

### query-doc

1. `doc search --query "<关键词>"` → `nodeId`
2. `doc read --node <nodeId>`（按需；大文档只抽章节）

### list-folder-docs

`doc list --workspace <WS_ID>` 或 `--folder <FOLDER_ID>`

## #5 工作汇报

### view-report-inbox

**优先**：`python scripts/report_inbox_today.py [--days N]`
备选：1. `report list --start "<起始ISO>" --end "<结束ISO>"` → `reportId`。2. `report detail --report-id <reportId>`

### check-report-read-status

`report stats --report-id <reportId>` → 已读/未读

## #7 听记与会后

### minutes-query

- 列表：`minutes list mine --max <N>` 或 `minutes list all --query "<关键词>"`
- 批量详情：`minutes get batch --ids <uuid1,uuid2,…>`
- 摘要：`minutes get summary --id <taskUuid>`
- 转写：`minutes get transcription --id <taskUuid>`
- 复杂场景 → full [07-minutes.md](./07-minutes.md)

## #8 通讯录

### get-contact-self

`contact user get-self` → 当前用户 userId、部门、主管等

### search-person

**搜人首选入口**。凡是“找人/搜人/找同事/谁负责/上级/下级/负责人/团队成员”均优先用 `aisearch person`：

1. 从用户问题中提取 keyword（人名/业务关键词）和 dimension（维度），规则见 [aisearch.md](../products/aisearch.md)。
2. `aisearch person --keyword "<关键词>" --dimension <维度>`
3. 结果中提取 `userId` 和 `title`（姓名）展示给用户。
4. 若需要 userId 做后续操作（发消息/建待办），可直接使用结果中的 `userId`。
5. **重名消歧**：多人同名时禁止默认选第一个，须追加 `contact user get --ids` 获取部门/职位后请用户确认，详见 [08-directory.md](./08-directory.md)「多命中」。

### search-user

仅在以下**精确查询**场景使用，搜人请优先用 `search-person`：

- 需要获取 userId 给其他产品使用（发消息/建待办/约日程）
- 已有 userId 需查完整详情（`contact user get --ids`）

1. `aisearch person --keyword "<姓名>" --dimension name` → `userId`；**多命中须列出候选请用户确认**。
2. **重名消歧**：多人同名时禁止默认选第一个，须追加 `contact user get --ids` 获取部门/职位后请用户确认，详见 [08-directory.md](./08-directory.md)「多命中」。
3. 需详情时：`contact user get --ids <userId>`（多人可 `--ids id1,id2,...`）
