# dws — 钉钉全产品操作 Skill

凡是涉及钉钉的操作一律使用此 skill。能力覆盖：发消息/建群/拉人进群/机器人群发/Webhook/单聊/撤回消息、约会议/查日程/订会议室/查闲忙/加参会人、建表/查记录/写数据/AI表格/多维表、搜同事/查部门/通讯录/找人/查上级/查下级/谁负责/负责人是谁/团队成员/查工号/查手机号、写文档/读文档/知识库/上传文件到文档、创建待办/TODO/任务提醒、发邮件/查邮件、听记/会议录音/AI摘要、创建应用/生成系统/做工具/管理后台、审批/OA/同意/拒绝、写日报/提交周报/查日志、上传下载文件/钉盘、查考勤/打卡/排班、DING紧急消息、预约视频会议、查直播、搜索技能/安装技能/发布技能/技能市场/企业技能库。

## CLI 定位（每次会话首次使用前执行一次）

`dws.exe` 随 Wukong 安装，路径因机器/版本而异，**必须动态探测**，禁止硬编码路径。

按以下顺序探测，找到即停止：

**步骤 1：直接调用**
```powershell
dws --version
```
成功则直接用 `dws`。

**步骤 2：PowerShell 注册表查找**
```powershell
$p = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -ErrorAction SilentlyContinue |
  Get-ItemProperty | Where-Object { $_.DisplayName -like "*Wukong*" -or $_.DisplayName -like "*悟空*" } |
  Select-Object -ExpandProperty InstallLocation -First 1
if ($p) { Get-ChildItem $p -Recurse -Filter "dws.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName }
```

**步骤 3：文件系统扫描**
```powershell
Get-ChildItem "$env:ProgramFiles","${env:ProgramFiles(x86)}","$env:LOCALAPPDATA","$env:APPDATA" -Recurse -Filter "dws.exe" -ErrorAction SilentlyContinue |
  Where-Object { $_.DirectoryName -like "*Wukong*" } |
  Select-Object -First 1 -ExpandProperty FullName
```

找到路径后，后续所有命令用该路径（含空格时加引号）。若三步均失败，告知用户安装 Wukong 或确认 dws.exe 位置。

## 认证说明

若收到 `not_authenticated` 错误，告知用户运行以下命令完成一次性登录（`<dws>` 替换为上面探测到的实际路径）：
```
"<dws>" auth login
```
登录后 token 自动保存，无需重复操作。若遇 `AUTH_TOKEN_EXPIRED` / `USER_TOKEN_ILLEGAL` 错误，直接重试命令（最多两次），系统自动刷新。

## 参考文档位置（动态解析）

`dws-refs/` 和 `dws-scripts/` 与本 skill 文件同级。每次会话首次使用时，用以下 PowerShell 命令定位 skill 目录，后续路径均基于此：

```powershell
# 优先查全局 skill 目录，其次查项目级
$skillDir = $null
$candidates = @(
    (Join-Path $env:USERPROFILE ".claude\skills"),
    (Join-Path $PWD ".claude\skills")
)
foreach ($c in $candidates) {
    if (Test-Path (Join-Path $c "dws.md")) { $skillDir = $c; break }
}
$dwsRefs    = Join-Path $skillDir "dws-refs"
$dwsScripts = Join-Path $skillDir "dws-scripts"
```

目录结构：
- `$dwsRefs\products\*.md` — 各产品命令详细用法
- `$dwsRefs\global-reference.md` — 全局标志说明
- `$dwsRefs\capability-limits.md` — 已知不支持的操作
- `$dwsRefs\url-patterns.md` — URL 模板规范
- `$dwsRefs\field-rules.md` — 字段规则
- `$dwsRefs\intent-guide.md` — 易混淆意图指南
- `$dwsRefs\best_practices\` — 多步操作行动指南
- `$dwsScripts\*.py` — 辅助脚本（支持 `--dry-run` 和 `--format json`）

## 严格要求 (MUST DO)

- 执行 `dws` 前必须用参考文档确认命令；产品参考已覆盖时直接执行，缺失或不确定时必须先用 `--help` 查证
- 多步/汇总类先匹配「行动指南」(`best_practices/`)；单产品操作匹配「产品路由表」
- 进入产品后读取对应 `dws-refs/products/*.md`，以其中 `Usage` / `Example` / `Flags` 为命令依据
- 产品参考缺失、路径/flag 不确定，或报 `unknown command` / `unknown flag` 时，必须先运行 `dws <path> --help` 查证后再执行
- 所有命令必须加 `--format json` 以获取可解析输出
- 危险操作必须先向用户确认，用户同意后才加 `--yes` 执行
- 单次批量操作不超过 30 条记录
- URL 必须从产品参考或 `url-patterns.md` 中查找模板，或使用命令返回的完整链接，无法获取时告知用户
- Email/手机号必须从命令返回中提取或由用户明确提供，无法获取时主动询问
- 拿到多个 ID 后，所有按 ID 查详情的命令**必须合并到同一批次并行调用**（`&` + `wait`），严禁逐条串行
- **脚本优先**：recipe 步骤中标注「优先」的脚本用 `python "$dwsScripts\<name>.py"` 调用（`$dwsScripts` 为上面动态解析的路径）

## 严格禁止 (NEVER DO)

- 不要使用 dws 命令以外的方式操作（禁止 curl、HTTP API、浏览器）
- 不要编造 UUID、ID 等标识符，必须从命令返回中提取
- 不要编造 URL、Email、手机号等结构化信息，禁止猜测
- 不要猜测字段名/参数值，操作前必须先查询确认
- 禁止编造命令路径、子命令或 flag

## 产品路由表

> 若用户意图涉及汇总/整理/归纳/分析/报告/多步操作，**先匹配行动指南** (`best_practices/`)；仅当行动指南无匹配且明确是单一产品单步操作时，按触发关键词匹配本表。

| 产品 | 用途 | 参考文件 |
|---|---|---|
| `aitable` | AI表格：表格/数据表/字段/记录增删改查 | `products/aitable.md` |
| `calendar` | 日历：日程/参与者/会议室/闲忙查询 | `products/calendar.md` |
| `contact` | 通讯录：精确查询/部门查询 | `products/contact.md` |
| `doc` | 文档：搜索/浏览/读取/创建/更新/块级编辑 | `products/doc.md` |
| `sheet` | 电子表格：单元格数据读写/追加/公式 | `products/sheet.md` |
| `chat` | 群聊：群管理/消息/机器人/Webhook | `products/chat.md` |
| `todo` | 待办：创建/查询/修改/完成/删除 | `products/todo.md` |
| `mail` | 邮箱：查询/搜索/查看/发送 | `products/mail.md` |
| `minutes` | AI听记：列表/摘要/转写/关键字 | `products/minutes.md` |
| `report` | 日志：日报/周报/模版/收件箱 | `products/report.md` |
| `drive` | 钉盘：浏览/下载/创建/上传 | `products/drive.md` |
| `ding` | DING消息：发送/撤回 | `products/ding.md` |
| `oa` | OA审批：待处理/同意/拒绝/撤销 | `products/oa.md` |
| `attendance` | 考勤：打卡记录/排班查询 | `products/attendance.md` |
| `wiki` | 知识库：创建/查询/搜索空间 | `products/wiki.md` |
| `aisearch` | 搜人首选：找同事/谁负责/上下级/查工号/手机号 | `products/aisearch.md` |
| `aiapp` | AI应用：创建/查询/修改 | `products/aiapp.md` |
| `conference` | 视频会议：预约会议 | `products/simple.md` |
| `live` | 直播：查看直播列表 | `products/simple.md` |
| `skill` | 技能管理：搜索/安装/发布 | `products/simple.md` |
| `devdoc` | 开放平台文档：搜索开发文档 | `products/simple.md` |

**关键区分**：
- `aisearch`（搜人首选）vs `contact`（精确按 userId 查）vs `mail`（查邮箱地址）
- `aitable`（数据表格）vs `doc`（文档编辑）vs `sheet`（电子表格/单元格读写）
- `report`（钉钉日志/日报）vs `doc`（文档）vs `todo`（待办任务）
- `drive`（钉盘文件存储）vs `doc`（钉钉文档内容读写）
- `conference`（视频会议预约）vs `calendar`（日历日程管理）

## 危险操作确认

以下操作执行前**必须展示摘要并获得用户同意，同意后才加 `--yes`**：

| 产品 | 命令 | 说明 |
|---|---|---|
| `aitable` | `base delete` | 删除整个 AI 表格 |
| `aitable` | `table delete` | 删除数据表 |
| `aitable` | `field delete` | 删除字段（不可恢复） |
| `doc` | `delete` | 删除文档/文件夹 |
| `chat` | `group dismiss` | 解散群组 |
| `todo` | `task delete` | 删除待办 |
| `drive` | `delete` | 删除钉盘文件/文件夹 |
| `oa` | `approval approve/reject` | 审批通过/拒绝 |
| `ding` | `send` | 发送 DING 紧急消息 |
