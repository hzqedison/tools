# dws — 钉钉全产品操作 Skill

凡是涉及钉钉的操作一律使用此 skill。能力覆盖：发消息/建群/拉人进群/机器人群发/Webhook/单聊/撤回消息、约会议/查日程/订会议室/查闲忙/加参会人、建表/查记录/写数据/AI表格/多维表、搜同事/查部门/通讯录/找人/查上级/查下级/谁负责/负责人是谁/团队成员/查工号/查手机号、写文档/读文档/知识库/上传文件到文档、创建待办/TODO/任务提醒、发邮件/查邮件、听记/会议录音/AI摘要、创建应用/生成系统/做工具/管理后台、审批/OA/同意/拒绝、写日报/提交周报/查日志、上传下载文件/钉盘、查考勤/打卡/排班、DING紧急消息、预约视频会议、查直播、搜索技能/安装技能/发布技能/技能市场/企业技能库。

## 执行架构

```
Claude Code
    ↓  自然语言任务描述
wukong-cli.exe  ←→  \\.\pipe\real-daemon（Wukong 守护进程）
    ↓  内部调用 dws 工具
钉钉 API
```

dws 的认证由 Wukong 守护进程自动管理，**不需要也不要直接调用 dws.exe**。所有钉钉操作通过 `wukong-cli` 下发自然语言任务完成。

## 前置条件

**Wukong（悟空）桌面端必须处于运行状态**，守护进程管道 `\\.\pipe\real-daemon` 才存在。

检查是否就绪：
```powershell
[System.IO.Directory]::GetFiles("\\.\pipe\") | Where-Object { $_ -match "real-daemon" }
```
有输出则就绪；无输出则告知用户启动 Wukong 桌面端并登录钉钉账号。

## 工具定位（每次会话首次使用前执行一次）

`wukong-cli.exe` 随 Wukong 安装，路径因机器/版本而异，**必须动态探测**。

```powershell
# 步骤1：直接调用
$wkcli = $null
if (Get-Command wukong-cli -ErrorAction SilentlyContinue) { $wkcli = "wukong-cli" }

# 步骤2：注册表查找
if (-not $wkcli) {
    $installDir = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                               "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" `
        -ErrorAction SilentlyContinue | Get-ItemProperty |
        Where-Object { $_.DisplayName -like "*Wukong*" -or $_.DisplayName -like "*悟空*" } |
        Select-Object -ExpandProperty InstallLocation -First 1
    if ($installDir) {
        $found = Get-ChildItem $installDir -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
                 Select-Object -First 1 -ExpandProperty FullName
        if ($found) { $wkcli = $found }
    }
}

# 步骤3：文件系统扫描
if (-not $wkcli) {
    $wkcli = Get-ChildItem "$env:ProgramFiles", "${env:ProgramFiles(x86)}", "$env:LOCALAPPDATA" `
        -Recurse -Filter "wukong-cli.exe" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -like "*Wukong*" } |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not $wkcli) { Write-Host "未找到 wukong-cli.exe，请确认已安装 Wukong 桌面端" }
```

找到后，变量 `$wkcli` 即为后续所有调用的入口。

## 执行命令（标准模板）

所有钉钉操作统一使用以下模板：

```powershell
$result = & $wkcli --socket "\\.\pipe\real-daemon" `
    -p "<任务描述>" `
    --output-format json `
    --max-turns <N> `
    2>&1 | Select-Object -First 20
$output = ($result | ConvertFrom-Json).output_text
```

**参数说明：**
- `-p "<任务描述>"` — 用清晰的中文描述任务，包含所有关键参数（节点ID、关键词、时间范围等）
- `--max-turns <N>` — 单步查询用 `3`，多步/汇总操作用 `5`，复杂批量操作用 `8`
- `| Select-Object -First 20` — 必须加，防止大量输出时流阻塞

**任务描述写法示例：**
```
# 读文档
-p "读取钉钉文档节点ID为Obva6QBXJw0yzeOdC24g0zol8n4qY5Pr的完整内容"

# 搜索
-p "在钉钉文档中搜索关键词'会议纪要'，返回最近10条结果的标题和链接"

# 发消息
-p "向钉钉用户ID为xxx的人发送消息：今天下午3点开会"

# 查日程
-p "查询我今天的所有日历日程，返回标题、时间、参与人"

# 查待办
-p "列出我所有未完成的待办任务，按截止时间排序"
```

**结果处理：**
- `$output` 是自然语言描述的结果，直接呈现给用户或继续解析
- 若需要 ID 等结构化数据，在任务描述中明确要求返回 JSON 格式
- 若 `status` 为 `finished` 且 `output_text` 有内容，表示成功

## 参考文档位置（动态解析）

`dws-refs/` 与本 skill 文件同级，用于了解各产品能力边界。

```powershell
$skillDir = $null
$candidates = @(
    (Join-Path $env:USERPROFILE ".claude\skills"),
    (Join-Path $PWD ".claude\skills")
)
foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c "dws.md")) { $skillDir = $c; break }
}
$dwsRefs = Join-Path $skillDir "dws-refs"
```

参考文档用途（只读，不用于构造命令）：
- `$dwsRefs\products\*.md` — 了解各产品支持哪些操作，帮助写出精准的任务描述
- `$dwsRefs\capability-limits.md` — 确认某操作是否在能力范围内
- `$dwsRefs\intent-guide.md` — 易混淆场景区分

## 严格要求 (MUST DO)

- 执行前先检查 `\\.\pipe\real-daemon` 是否存在
- 任务描述必须具体，包含所有必要的 ID / 关键词 / 时间范围
- 需要 ID 时，先执行查询步骤获取，再执行操作步骤；禁止编造 ID
- 危险操作（删除/发送 DING/审批）必须先向用户展示摘要并获得确认
- 单次批量操作描述不超过 30 条记录
- 不确定某产品是否支持某操作时，查阅 `$dwsRefs\capability-limits.md`

## 严格禁止 (NEVER DO)

- 不要直接调用 `dws.exe`（认证不通）
- 不要编造 UUID、ID、URL、Email、手机号
- 不要在 Wukong 未运行时尝试操作（管道不存在会报错）
- 不要省略 `| Select-Object -First 20`（会导致流阻塞）
- 不要把 `output_text` 中的内容当作精确 JSON 直接解析（它是自然语言）

## 产品路由表

> 用于帮助写出准确的任务描述，匹配后参考对应文档了解该产品能做什么。

| 产品 | 关键词 | 参考文件 |
|---|---|---|
| 文档 | 读文档/写文档/知识库/文件夹 | `products/doc.md` |
| 群聊 | 发消息/建群/拉人/机器人/Webhook | `products/chat.md` |
| 日历 | 日程/会议室/闲忙/约会 | `products/calendar.md` |
| 通讯录 | 搜同事/查部门/找负责人/查工号 | `products/aisearch.md` + `products/contact.md` |
| 待办 | TODO/任务/提醒 | `products/todo.md` |
| 邮件 | 发邮件/查收件箱 | `products/mail.md` |
| OA审批 | 审批/待处理/同意/拒绝 | `products/oa.md` |
| AI表格 | 数据表/字段/记录 | `products/aitable.md` |
| 电子表格 | 单元格/公式/Sheet | `products/sheet.md` |
| 考勤 | 打卡/排班/出勤 | `products/attendance.md` |
| AI听记 | 会议录音/摘要/转写 | `products/minutes.md` |
| 日志 | 日报/周报/模版 | `products/report.md` |
| 钉盘 | 上传/下载/文件存储 | `products/drive.md` |
| 知识库 | Wiki/知识库空间 | `products/wiki.md` |
| DING消息 | 紧急通知/DING | `products/ding.md` |
| 视频会议 | 预约会议/视频 | `products/simple.md` |

## 危险操作确认

以下操作在任务描述中出现时，**必须先向用户展示操作摘要并获得明确同意**，确认后再执行：

| 操作 | 说明 |
|---|---|
| 删除文档/文件夹 | 不可恢复 |
| 删除 AI 表格/数据表/字段 | 数据不可恢复 |
| 解散群组 | 不可恢复 |
| 发送 DING 消息 | 会打扰对方（电话/短信） |
| 审批同意/拒绝 | 影响业务流程 |
| 删除钉盘文件 | 不可恢复 |
