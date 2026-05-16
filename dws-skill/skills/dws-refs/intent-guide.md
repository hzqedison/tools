# 意图路由指南

当用户请求难以判断归属哪个产品时，参考本指南。

## 易混淆场景快速对照表

| 用户说... | 真实意图 | 应该用 | 不要用 | 理由 |
|-----------|----------|--------|--------|------|
| "搜一下 OAuth2 接入文档" | 搜索开发文档 | `devdoc` | `doc search` | 搜索开放平台技术文档，不是钉钉内部内容 |
| "帮我建一个项目跟踪表" | 创建数据表格 | `aitable` | `doc` / `sheet` | 涉及结构化数据/行列操作，不是富文本文档或电子表格 |
| "帮我写个项目周报" | 创建钉钉文档 | `doc` | `aitable` | 富文本内容创作，不是数据表 |
| "创建一个电子表格" | 创建表格文档 | `sheet` | `aitable` | Excel 式表格/单元格操作，不是多维表记录 |
| "帮我读一下表格 A1:D10 的数据" | 读取单元格数据 | `sheet` | `aitable` | 按单元格区域读写，不是按记录查询 |
| "这个 alidocs 表格链接帮我看下"（粘贴原始 URL） | 先 probe 节点类型 | `dws doc info --node` → 按 `extension` 路由 | 直接调 `sheet` | `alidocs/i/nodes/{id}` 可能是文档/axls/able/xlsx 等，禁止凭 URL 猜类型 |
| "读一下这个 xlsx 的数据" / xlsx 节点链接 | 下载本地表格文件 | `dws doc download --node` | `sheet range read` | xlsx / xls / xlsm / csv 是上传的本地文件（`contentType=DOCUMENT`），sheet 命令只支持在线表格，必须下载后本地解析 |
| "把这个在线表格导出为 xlsx 文件" | 在线表格格式转换 | `dws sheet export` | `dws doc download` | `export` 是 axls → xlsx 的导出转换；`download` 只能下载已有的 xlsx 节点 |
| "帮我记一下明天要做的事" | 创建个人待办 | `todo` | `doc` | 个人待办提醒，非文档内容 |
| "给自己留一个明天下午的时间块/建个个人日程" | 创建个人日程 | `calendar event create` | `todo` | 个人 schedule 仍属于日历事件，不是待办 |
| "帮我把这个文件传到网盘" | 钉盘上传 | `drive` | `doc` | 文件存储/上传，不是文档内容编辑 |
| "帮我把这个文件传到网盘" | 钉盘上传 | `drive upload` | `doc upload` | 钉盘文件存储，不是文档空间 |
| "帮我把文件上传到知识库" | 文档空间上传 | `doc upload` | `drive upload` | 钉钉文档知识库/文档空间，不是钉盘 |
| "上传文件到文档空间" | 文档空间上传 | `doc upload` | `drive upload` | 提到"文档空间/知识库"→ doc |
| "上传文件到钉盘/我的文件" | 钉盘上传 | `drive upload` | `doc upload` | 提到"钉盘/网盘/我的文件"→ drive |
| "上传文件"（未指定目标） | 默认钉盘 | `drive upload` | `doc upload` | 未明确目标时默认上传到钉盘 |
| "帮我看看知识库里的文件" | 文档空间 | `doc` | `drive` | 钉钉文档知识库，不是钉盘文件管理 |
| "帮我预约一个视频会议" | 视频会议 | `conference` | `calendar` | 视频会议预约（含入会链接），不是日历日程 |
| "帮我建一个明天下午的日程" | 日历日程 | `calendar` | `conference` | 日历日程管理（可含参与者/会议室）|
| "明早 9 点提醒我提交周报" | 创建个人待办，但需先声明 reminder 边界 | `todo` | `calendar` | todo 当前只支持 dueTime 截止时间，不支持独立精确 reminder |
| "通知群里的人都来开会" | 个人身份群发 | `chat message send` | `chat message send-by-bot` | 以个人身份向群发消息 |
| "让机器人每天推送日报" | 机器人定时推送 | `chat message send-by-bot` | `chat message send` | 需要机器人身份定期发送 |
| "CPU 超过 90% 自动告警" | Webhook 告警 | `chat message send-by-webhook` | `chat message send-by-bot` | 系统告警场景，需自定义 Webhook |
| "帮我看看收到的日报" | 日志收件箱 | `report` | `doc` | 钉钉日志系统（日报/周报），不是文档 |
| "帮我创建一个待办提醒" | 个人待办 | `todo` | `report` | 个人任务提醒，不是日志汇报 |
| "拉取一下上周项目群的聊天记录" | 拉取会话消息 | `chat message list` | — | 拉取指定群聊的消息列表 |
| "看看张三发给我的消息" | 按发送者查询消息 | `chat message list-by-sender` | `chat message list --user` | 用户未明确说"单聊"时优先用 list-by-sender（跨单聊/群聊） |
| "拉取和张三的单聊记录" | 拉取单聊消息 | `chat message list --user` | `chat message list-by-sender` | 用户明确说"单聊"时用 list --user |
| "谁@了我/查看提及我的消息" | 查询@我的消息 | `chat message list-mentions` | `chat message list-all` | 都是跨会话时间范围查询，但 list-mentions 只返回@我的消息 |
| "查看我今天的所有消息" | 全量会话消息 | `chat message list-all` | `chat message list` | 用户未指定具体会话时用 list-all（跨所有会话），指定了具体群或人时用 list |
| "搜一下消息里的changefree链接" | 消息搜索 | `chat message search-advanced`（首选） | `chat search` | 推荐首选 search-advanced，它是 search 的严格超集（keyword 可选、支持多群、可叠加发送者/at 维度） |
| "按发送者搜索/指定多个群搜索/多维度搜消息" | 多维度搜索消息 | `chat message search-advanced`（首选） | `chat message search` | 推荐首选，支持关键词、发送者、@我、多个会话等维度组合 |
| "消息发没发成功/查询消息发送状态" | 查询消息发送状态 | `chat message query-send-status` | — | 需要 send 返回的 openTaskId |
| "撤回我发的消息/撤回消息" | 撤回个人消息 | `chat message recall` | `chat message recall-by-bot` | recall 撤回个人消息，recall-by-bot 撤回机器人消息 |
| "未读消息会话/未读会话列表/我的未读会话" | 未读会话列表 | `chat message list-unread-conversations` | `chat message read-status` | list-unread-conversations 查哪些会话有未读；read-status 查具体消息的已读状态 |
| "谁看了这条消息/消息已读未读/查读状态" | 查询消息已读状态 | `chat message read-status` | `chat message list-unread-conversations` | read-status 查具体消息的已读人员；list-unread-conversations 查未读会话列表 |
| "我和风雷的共同群/我们都在哪些群" | 搜索共同群 | `chat search-common` | `chat search` | search-common 按人员搜共同群，chat search 按群名搜索 |
| "查看会话分组/自定义分组" | 获取会话分组 | `chat category list` | — | 获取用户自定义的会话分组列表 |
| "某个分组下有哪些会话" | 分组下会话列表 | `chat category list-conversations` | — | 需先通过 category list 获取分组 ID |
| "根据群号查群信息/群号转openConversationId" | 群号查群聊信息 | `chat group get-by-group-id` | `chat search` | 已知数字群号时直接查；用户发消息只给了群号时，先用此工具将群号转为 openConversationId |
| "引用消息回复/回复那条消息" | 引用回复消息 | `chat message reply` | `chat message send` | reply 引用指定消息回复；send 普通发消息不引用 |
| "转发消息/把消息转到另一个群" | 转发单条消息 | `chat message forward` | `chat message send` | forward 转发已有消息到目标会话；send 是发新消息 |
| "置顶会话/取消置顶" | 设置/取消会话置顶 | `chat set-top` | `chat list-top-conversations` | set-top 设置或取消置顶；list-top-conversations 查看置顶列表 |
| "全员禁言/群禁言" | 全员禁言或解除 | `chat group-mute` | `chat group-mute-member` | group-mute 全员禁言或解除；group-mute-member 指定成员禁言 |
| "禁言某人/指定成员禁言" | 指定成员禁言 | `chat group-mute-member` | `chat group-mute` | group-mute-member 指定成员禁言/解禁；group-mute 全员禁言 |
| "设管理员/取消管理员" | 设置群管理员 | `chat group set-admin` | `chat group invite` | set-admin 设置或取消管理员角色；invite 是邀请入群 |
| "DING消息/查DING/DING历史" | 查询 DING 消息列表 | `ding message list` | `chat message list` | ding 是独立顶层命令；ding message list 查 DING 消息；chat message list 查普通聊天消息 |
| "DING接收状态/谁收到了DING" | DING 接收状态 | `ding message receiver-status` | `chat message read-status` | ding 是独立顶层命令；receiver-status 查 DING 接收；chat message read-status 查普通消息已读 |
| "发DING/DING通知" | 发送 DING 消息 | `ding message send` | `chat message send` | DING 是钉钉的强提醒（应用内/短信/电话），独立顶层命令；普通群消息用 chat |
| "撤回DING" | 撤回 DING 消息 | `ding message recall` | `chat message recall` | DING 撤回独立命令；chat recall 是撤回普通聊天消息 |
| "列出可用的 A2A Agent / 流式问 Agent" | Agent 发现与协作通信 | `a2a` | `chat` | A2A 协议与 `dws a2a`，不是群聊会话 |
| "把最近几次关于XX的会议汇总成报告" | 按主题汇总多次听记 | #5 generate-topic-report | #7 meeting-followup | #7 是单次会议听记跟进；多次会议按主题汇总属于工作汇报 |
| "整理一下XX项目的所有讨论" | 跨源主题归档 | #5 generate-topic-report | #4 write-doc | #4 侧重单篇文档创作；按主题跨听记/群消息汇总属于工作汇报 |
| "张三在哪个部门/查一下同事工号" | 通讯录精确查询 | #8 `contact` | #5 汇报 / #4 文档 | 需要 userId、手机号、部门 ID 等精确信息时用 contact |
| "研发部的详细信息/部门信息" | 查部门详情 | `contact dept get-info` | `contact dept list-members` | 查部门属性（ID、名称、人数）用 get-info；查成员列表用 list-members |
| "研发部有多少人" | 查部门人数 | `contact dept get-info` | `contact dept list-members` | 问人数用 get-info（返回 memberCount）；问有哪些人用 list-members |
| "找一下张三/搜同事/找人" | AI搜人(首选) | `aisearch person` | `contact user search` | 搜人首选 aisearch，支持姓名/部门/职责/上下级维度；精确查 userId/手机号用 contact |
| "五道的上级是谁/谁负责XX/XX的下属有谁" | AI语义搜人 | `aisearch person` | `contact` | 涉及上下级、职责、负责人等语义维度搜索，用 aisearch |
| "222020这个工号是谁/查工号" | 按工号搜人 | `aisearch person --dimension jobNumber` | `contact` | 工号查人走 aisearch，dimension=jobNumber |
| "13800138000是谁/查手机号" | 按手机号搜人 | `aisearch person --dimension phone` | `contact` | 手机号查人走 aisearch，dimension=phone |

---

## 典型场景详解

### 1. aitable vs doc vs sheet — 数据表格 vs 文档内容 vs 电子表格

**用 `aitable` 的场景**：
- "创建一个表格记录团队成员信息" — 结构化数据，有行列
- "在表格里加一列'状态'字段" — 字段/列操作
- "查一下表格里所有优先级为高的记录" — 数据筛选和查询
- "用项目管理模板建一个表" — 模板创建
- 用户提到"多维表"、"Base"、"数据表"、"记录"

**用 `doc` 的场景**：
- "帮我写个会议纪要" — 富文本内容创作
- "看一下这个文档链接的内容" — 阅读文档
- "在知识库创建一个文件夹" — 文档空间管理
- 用户提到"文档"、"知识库"、"写文档"

**用 `sheet` 的场景**：
- "创建一个电子表格" — 创建 Excel 式在线表格
- "帮我读一下这个表格 A1 到 D10 的数据" — 按单元格区域读取
- "在 B2 写入一个 SUM 公式" — 写入公式/值到单元格
- "帮我看看这个表格有哪些工作表" — 工作表管理
- 用户提到"电子表格"、"Excel"、"工作表"、"Sheet"、"单元格"、"公式"

**三者判断关键**：
- 有字段定义/记录增删改查/数据筛选 → `aitable`
- 纯文本/Markdown/富文本编辑 → `doc`
- 单元格区域读写/公式/多工作表 → `sheet`

**易误判场景**：
- "在知识库中新建一个表格" — 指在钉钉文档空间创建表格类型节点 → `doc`（不是 `aitable`）
- "帮我建个表记录项目进度" — 指创建结构化数据表 → `aitable`

---

### 1.1 xlsx vs axls — 本地表格文件 vs 在线电子表格

alidocs 链接表面长得一样（`https://alidocs.dingtalk.com/i/nodes/{id}`），但节点类型完全不同。sheet 产品线只服务 axls（在线电子表格），xlsx / xls / xlsm / csv 等本地表格文件必须走 `dws doc download`，严禁错路由。

用 `sheet` 的场景（axls，钉钉在线电子表格）:
- `dws doc info --node <URL>` 返回 `contentType=ALIDOC` + `extension=axls`
- 用户在钉钉文档空间直接"新建电子表格"得到的节点
- 所有 sheet 子命令（`list` / `range read` / `range write` / `export` 等）仅服务这类节点

用 `dws doc download` 的场景（xlsx / xls / xlsm / csv 本地表格文件）:
- `dws doc info --node <URL>` 返回 `contentType=DOCUMENT` + `extension=xlsx` / `xls` / `xlsm` / `csv`
- 用户把本地 Excel 文件上传到文档空间得到的节点，本质是"文件 + 预览"，非在线表格
- sheet 命令直接调用会报错，必须先 `dws doc download --node <URL>` 下载到本地再解析处理

判断关键：
- 未知 alidocs URL → 必须先 `dws doc info --node <URL> --format json` 探测 `contentType` 与 `extension`
- `contentType=ALIDOC` + `extension=axls` → `sheet`
- `contentType=DOCUMENT` + `extension=xlsx` / `xls` / `xlsm` / `csv` → `dws doc download`
- 用户说"把在线表格导出为 xlsx 文件" → `dws sheet export`（axls → xlsx 的格式转换，不是读取 xlsx）

易误判场景：
- 用户粘贴一个 alidocs 链接说"读一下这个表格" — 不能直接调 `sheet range read`，必须先 probe 再按 `extension` 路由
- 用户说"读一下这个 xlsx 文件里的数据" — 走 `dws doc download` 下载后本地解析，不要走 `sheet`
- 用户说"把这个在线表格导出为 xlsx" — 走 `dws sheet export`，不要走 `dws doc download`（后者只能下载已有的 xlsx 节点，无法从 axls 生成）

详见 [url-patterns.md](./url-patterns.md) 和 [sheet.md 适用范围](./products/sheet.md)。

---

### 2. devdoc vs doc search — 两种搜索

**用 `devdoc` 的场景**：
- "API 调用报错 403 怎么解决" — 开发调试问题
- "搜一下 OAuth2 接入文档" — 开放平台技术文档
- "CLI 命令出错了怎么办" — CLI 使用错误
- 用户提到"开发"、"API"、"调用错误"

**用 `doc search` 的场景**：
- "在我的文档里搜一下'项目方案'" — 搜索文档标题和内容
- 用户明确说"我的文档"、"知识库里搜"

**判断关键**：搜开发文档→ `devdoc`；搜用户自己的文档→ `doc search`

---

### 3. drive vs doc — 文件存储 vs 文档内容

**用 `drive` 的场景**：
- "把这个 PDF 传到钉盘" — 上传文件
- "下载那个 Excel 附件" — 下载文件
- "看一下钉盘根目录有什么文件" — 浏览文件列表
- 用户提到"钉盘"、"网盘"、"上传"、"下载"

**用 `doc` 的场景**：
- "读一下这个文档的内容" — 读取文档 Markdown
- "帮我写入一段话到文档里" — 编辑文档内容
- "在知识库里搜索会议纪要" — 搜索文档
- 用户提到"文档内容"、"知识库"

**判断关键**：文件存储/传输→ `drive`；文档内容读写→ `doc`

---

### 4. conference vs calendar — 视频会议 vs 日历日程

**用 `conference` 的场景**：
- "帮我预约一个视频会议" — 需要入会链接
- 用户明确说"视频会议"

**用 `calendar` 的场景**：
- "明天下午安排个会" — 日程管理（可含会议室）
- "给自己留两个小时写方案/建个个人日程" — 个人日历事件，仍用 `calendar event create`
- "帮我约几个人开会" — 创建日程 + 添加参与者
- "看看下午有没有空闲会议室" — 会议室管理
- "帮我查一下同事有空吗" — 闲忙查询
- 用户提到"日程"、"会议室"、"约会"

**判断关键**：仅需视频会议入会链接→ `conference`；日程/参与者/会议室管理→ `calendar`

---

### 5. chat 内部 — 消息发送与撤回

**用 `chat message send` 的场景**：
- "帮我在群里发个消息提醒大家" — **个人身份**发群消息
- "发个单聊消息给某人" — 个人身份发单聊：
  - 优先获取 openDingTalkId，使用 `--open-dingtalk-id`（推荐）；获取不到时才退回 `--user`（备选）
  - 获取 openDingTalkId：若知道姓名，`dws contact user search --query "姓名"` 直接获取；若只有 userId，先 `dws contact user get --ids <userId>` 获取姓名，再 `dws contact user search --query "姓名"` 获取 openDingTalkId
  - 富媒体消息（image/file）单聊：必须用 `--open-dingtalk-id`（`--user` 不支持，MCP 接口仅接受 receiverOpenDingTalkId）
- "发张图片到群里" — `--msg-type image --media-id`
- "发个语音/录音到群里" — `--msg-type file`（音频统一走钉盘上传）
- "发个视频到群里" — `--msg-type file`（视频统一走钉盘上传）
- "发个文件到群里" — `--msg-type file --dentry-id --space-id --file-name --file-type --file-path --file-size`
- "发张图片/文件给某人" — 单聊富媒体消息，必须用 `--open-dingtalk-id`，不支持 `--user`

发送文件/媒体消息时，必须先根据文件扩展名判断 msgType，这是第一步，不可跳过：

| 文件扩展名 | msgType | 发送方式 |
|-----------|---------|---------|
| .jpg / .jpeg / .png / .gif / .bmp / .webp | image | dt_media_upload 上传 → `python scripts/extract_media_id.py <URL>` 提取 mediaId → `--msg-type image --media-id` |
| 其他所有（.mp3/.wav/.mp4/.avi/.pdf/.doc/.xls/.zip 等） | file | conversation-info 获取 spaceId → dws drive upload --space-id 上传 → drive info 获取 dentryId → `--msg-type file --dentry-id ...` |

20MB 降级规则：当图片超过 20MB 时，dt_media_upload 会失败，必须降级走「发送图片+文字消息」链路（钉盘上传 + Markdown 嵌入），具体参见下方对应章节。音频/视频/文件本身已走钉盘上传，无 20MB 限制。

**用 `chat message send-by-bot` 的场景**：
- "让机器人在群里发一条通知" — **机器人身份**发消息
- "给张三发一条机器人单聊消息" — 机器人单聊

**用 `chat message send-by-webhook` 的场景**：
- "通过 Webhook 发告警到群里" — 自定义机器人 Webhook
- 用户有 Webhook Token

**用 `chat message recall-by-bot` 的场景**：
- "撤回刚才机器人发的消息" — 需要 robot-code + processQueryKey

用 `chat message recall` 的场景：
- "撤回我刚发的消息" — 撤回以个人身份发送的消息，需要 openConversationId + openMessageId

用 `chat message query-send-status` 的场景：
- "消息发没发成功/查询消息发送状态" — 查询个人发送消息的状态，需要 send 返回的 openTaskId

用 `chat message search-advanced` 的场景（推荐首选）：
- "按发送者搜索消息/指定多个群搜索/@我的消息多维度搜" — 支持关键词、发送者、@我、@指定人、多个会话等维度组合搜索
- 替代关系：完全替代 `chat message search`（严格超集：keyword 可选 vs 必填，支持多群 vs 单群）；大部分替代 `chat message list-by-sender`（--sender-ids 覆盖按 openDingTalkId 搜索）和 `chat message list-mentions`（--at-me 覆盖核心功能）
- 不能替代：`chat message list-focused`（「特别关注人」是独立维度），以及需要按 userId（非 openDingTalkId）搜索发送者的场景
- 默认使用 search-advanced，仅在上述不适用场景才降级到具体命令

**不支持的场景**：
- "撤回我刚发的消息"（但不知道消息 ID） — 需先通过消息拉取或搜索接口（如 `chat message list`、`chat message search-advanced` 等）获取 openMessageId，再调用 `chat message recall`

判断关键：个人发→ `send`；机器人发→ `send-by-bot`；有 Webhook Token→ `send-by-webhook`；个人撤回→ `recall`；机器人撤回→ `recall-by-bot`；查发送状态→ `query-send-status`；消息搜索类意图优先路由到 `search-advanced`（推荐首选），仅在不适用时降级到具体命令

---

### 6. chat vs a2a — 群聊会话 vs Agent 协作

**用 `chat` 的场景**：
- "在群里发条通知" — 钉钉会话/群消息
- "拉取某个群/某个人单聊的聊天记录" — `chat message list`
- "某人发给我的消息" — `chat message list-by-sender`
- "@我的消息/提及我的" — `chat message list-mentions`
- "查看我最近的所有消息" — `chat message list-all`
- "特别关注人的消息/关注的人的消息/我特别关注的人最近发了什么消息/关注的人最近聊了啥" — `chat message list-focused`
- 注：判断顺序——**先**看 query 是否含动词【发/说/聊/讲】或名词【消息/聊天/动态】，含则路由到 `chat message list-focused`；**仅**当 query 终点是"人员列表"（如"我关注了谁/我特别关注的人有哪些"，无任何消息域动词）时，才路由到 `contact relation list-my-followings`。
- "搜索消息里的XX/查找包含XX的消息" — `chat message search`
- "我和XX的共同群" — `chat search-common`
- "置顶会话/我的置顶/查看置顶" — `chat list-top-conversations`
- "置顶消息" — 先 `chat list-top-conversations` 拉置顶会话列表，再用 `chat message list --group <openConversationId>` 分别拉各会话的消息
- "设置/取消会话置顶" — `chat set-top`（--off 取消置顶）
- "引用回复消息" — `chat message reply`
- "转发消息到另一个群" — `chat message forward`
- "全员禁言/解除禁言" — `chat group-mute`（--off 解除禁言）
- "禁言某人/指定成员禁言" — `chat group-mute-member`
- "设管理员/取消管理员" — `chat group set-admin`（--off 取消）
- "发DING/DING通知" — `ding message send`（顶层独立命令组）
- "撤回DING" — `ding message recall`
- "DING消息/查DING历史" — `ding message list`
- "DING接收状态/谁收到了DING" — `ding message receiver-status`
- 用户明确说"群"、"会话"、"机器人发群消息"、"Webhook"

**用 `a2a` 的场景**：
- "列出 A2A 上可用的 Agent" — `dws a2a agents`
- "向 Agent 发一条消息（同步/流式）" — `dws a2a send`
- 用户提到"A2A"、"Agent 协作"、"Agent 列表"、"调用 Agent"，不是钉钉群

**判断关键**：面向 **钉钉会话与群** → `chat`；面向 **A2A 协议 Agent 发现与通信** → `a2a`。详见 [a2a.md](./products/a2a.md)。

---

### 7. report vs doc vs todo — 日志 vs 文档 vs 待办

**用 `report` 的场景**：
- "帮我看看收到的日报" — 日志收件箱
- "帮我写/提交今天的日报（钉钉日志模版）" — 先 `report template list` / `template detail`，再 `report create`
- "有什么日志模版" — 查看模版
- "看看这个日志的已读统计" — 阅读状态
- "我发过的日志有哪些" — 已发送列表 (`report sent`)
- 用户提到"日报"、"周报"、"日志"

**用 `doc` 的场景**：
- "帮我写个项目总结文档" — 长文本创作（钉钉在线文档，非日志模版）

**用 `todo` 的场景**：
- "记一下这周要做的事" — 个人任务管理
- "创建一个待办提醒" — 仍归 `todo`，但要先说明当前只有 dueTime 截止时间，没有独立 reminder schedule

**判断关键**：钉钉日志系统(日报/周报模版，含按模版创建汇报)→ `report`；文档/知识库长文→ `doc`；任务清单→ `todo`

---

## 跨产品工作流路由

以下场景需要多个产品配合完成，注意上下文传递顺序。多步骤操作有现成脚本时优先使用脚本。

### 发邮件给同事（aisearch → contact → mail）

用户说“给张三发封邮件”，但只知道名字不知道邮箱地址：

> 有脚本: `python scripts/mail_send_with_cc.py`

```bash
# 1. 搜人获取 userId（多人同名须 contact user get 消歧，禁止默认选第一个，详见 08-directory.md「多命中」）
dws aisearch person --keyword "张三" --dimension name --format json

# 2. 用 userId 查详情获取 email
dws contact user get --ids <userId> --format json

# 3. 用搜索到的邮箱地址作为收件人发送邮件
dws mail mailbox list --format json  # 获取发件人邮箱
dws mail message send --from my@company.com --to zhangsan@company.com \
  --subject "周报" --body "内容" --format json
```

### 创建日程并邀请同事（aisearch → calendar）

用户说“约张三明天下午开会”：

> 有脚本: `python scripts/calendar_schedule_meeting.py --title "会议" --start "..." --end "..." --users userId1 --book-room`

```bash
# 手动流程（脚本不可用时）:
# 1. 搜人获取 userId（多人同名须 contact user get 消歧，禁止默认选第一个，详见 08-directory.md「多命中」）
dws aisearch person --keyword "张三" --dimension name --format json

# 2. 创建日程
dws calendar event create --title "会议" \
  --start "2026-03-15T14:00:00+08:00" --end "2026-03-15T15:00:00+08:00" --format json

# 3. 添加参与者
dws calendar participant add --event <EVENT_ID> --users <USER_ID> --format json
```

### 创建待办并指派（aisearch → todo）

用户说“给张三建个待办”：

```bash
# 1. 搜人获取 userId（多人同名须 contact user get 消歧，禁止默认选第一个，详见 08-directory.md「多命中」）
dws aisearch person --keyword "张三" --dimension name --format json

# 2. 创建待办
dws todo task create --title "任务内容" --executors <USER_ID> --format json
```

---

### 8. 纯通讯录查询 vs 跨产品（#8）

**仅查人/部门/成员/归属/组织关系**（没有「发消息、写文档、建待办」等第二动作）→ 匹配 [SKILL.md](../SKILL.md) **#8 通讯录**（行动指南 [08-directory.md](./best_practices/08-directory.md)），不要用 #5 汇报或 #4 文档。

**多轮对话**：用户先说「搜 userId」再说「要详细资料」→ 仍属 #8；第二步 **必须** 执行 `contact user get --ids`，禁止只用第一次 `user search` 的浅表字段交差。

**与 #1 消息区分**：终点是「把消息发给某人」→ #1；终点是「某人 userId/部门是什么」→ #8。可先 #8 解析 ID 再 #1。

**与发邮件、待办、日程混排**：先后顺序与口径见 [08-directory.md](./best_practices/08-directory.md#与其他场景消歧)。

**特别关注列表查询**：用户说"我关注了谁/我的特别关注列表/我的星标联系人/特别关注的人有哪些" → `dws contact relation list-my-followings`（无入参）。

- 与 `chat message list-focused` 区分：前者拉"人员列表"，后者拉"这些人发的消息"。
- **可执行判断口径（按顺序扫描）**：
  1. 扫描 query 是否含动词【发/说/聊/讲】或名词【消息/聊天/动态/最新内容】 → 含则**强制**路由到 `chat message list-focused`，**忽略**主语中的"关注/特别关注/星标"。
  2. 仅含"关注/特别关注/星标"+"人/列表/谁/有哪些/多少" → 路由到 `dws contact relation list-my-followings`。
- **反例 query（绝不路由到 list-my-followings）**：
  - "我特别关注的人最近发了什么消息" → `chat message list-focused`
  - "关注的人最近都说了啥" → `chat message list-focused`
  - "星标联系人发的群消息" → `chat message list-focused`
- **正例 query（路由到 list-my-followings）**：
  - "我特别关注的人有哪些"、"我关注了谁"、"我的星标联系人"


### 发送图片消息（纯图片，不带文本）

用户说"把这张图发到群里"或"发张图片给某某"，且**不需要附带文字说明**：

通过 dt_media_upload 工具上传图片，获得 mediaId，然后用 `--media-id` 直接发送图片消息。

```bash
# 1. 使用 dt_media_upload 工具上传图片，获得 URL

# 2. 用脚本从 URL 提取 mediaId（输出如 @lQLPD4JNnliqBq3NBQDNA8Cw）
python scripts/extract_media_id.py "<dt_media_upload 返回的 URL>"

# 3. 直接发送图片消息
dws chat message send --group <openconversation_id> --msg-type image --media-id <mediaId>
dws chat message send --open-dingtalk-id <openDingTalkId> --msg-type image --media-id <mediaId>
```

### 发送文件消息（音频/视频/文档等所有非图片文件）

用户说"发个文件到群里"、"把 PDF 发给某某"、"发个语音到群里"、"把视频发给某某"等：

> 音频、视频、文档等所有非图片文件统一走钉盘上传，msgType 统一为 `file`。上传前需先获取会话共享空间 spaceId，确保对方可以打开文件。

完整流程如下：

```bash
# 0. 获取会话共享空间 spaceId（群聊用 --group，单聊用 --open-dingtalk-id）
dws chat conversation-info --group <openConversationId> --format json
# 返回值中取 newCSpaceIdIM 作为 spaceId

# 1. 上传文件到共享空间（一条命令自动完成 upload-info → PUT → commit）— 返回 fileId、fileName、fileSize、spaceId
dws drive upload --file "report.pdf" --space-id <newCSpaceIdIM> --format json

# 2. 用 drive info 获取 dentryId（发送文件的 --dentry-id 需要的就是这个值，不是 upload 返回的 fileId）
dws drive info --file-id <fileId> --space-id <spaceId> --format json
# 返回值中取 dentryId（如 "218629198919"）

# 3. 发送文件消息（--dentry-id 传 dentryId，其余来自步骤 1）
dws chat message send --group <openConversationId> --msg-type file \
  --dentry-id <dentryId> --space-id <spaceId> --file-name "report.pdf" \
  --file-type "pdf" --file-path "/report.pdf" --file-size 234724
```

**ID 边界**：上一步得到的数字型 `dentryId` 只能传给 `chat message send --dentry-id`。它不是文件夹父节点，不能用于 `drive --parent-id`、`doc --folder` 或 `doc --node`；需要父目录时重新用 `drive list` 或 `doc list` 获取 `dentryUuid/nodeId`。

**禁止行为**：不要对非图片文件使用 dt_media_upload 上传或 --media-id 参数，那只适用于图片消息。

### 发送图片+文字消息 / 发送文件+文字消息（drive → chat）

以下场景使用钉盘上传 + Markdown 嵌入方式：
- 用户要发图片**同时带文字说明**（如"把这张图发群里，备注一下是本周数据"）
- 用户要发**文件同时带文字说明**（如"发个 PDF 到群聊，备注一下是季度报告"）
- **图片超过 20MB 时的降级**：dt_media_upload 不支持超过 20MB 的文件，此时必须走此链路（钉盘上传 + Markdown 嵌入图片链接）

先通过钉盘上传获取下载链接，再用 Markdown 语法嵌入发送。

```bash
# 1. 上传文件到钉盘（一条命令自动完成）
dws drive upload --file ./截图.png --format json

# 2. 获取下载链接
dws drive download --file-id <dentryUuid> --format json

# 3. 用 Markdown 语法发送
#    图片+文字：![图片描述](下载链接) 后跟文字内容
#    文件+文字：[文件名](下载链接) 后跟文字内容
dws chat message send --group <openconversation_id> "![本周数据](下载链接) 这是本周的数据汇总"
dws chat message send --group <openconversation_id> "[报告.pdf](下载链接) 这是季度报告"
```
