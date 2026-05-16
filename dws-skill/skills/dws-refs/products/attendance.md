# 考勤 (attendance) 命令参考

## 命令总览


### 查询打卡结果
```
Usage:
  dws attendance check result [flags]
Example:
  dws attendance check result --users userId1,userId2 --from 2026-04-01 --to 2026-04-30 --limit 50
Flags:
      --from string   起始日期, 格式 YYYY-MM-DD (必填)
      --limit int     分页大小, 默认 100, 范围 1-1000 (可选)
      --offset int    分页偏移量, 默认 0 (可选)
      --to string     结束日期, 格式 YYYY-MM-DD, 不超过 1 个月 (必填)
      --users string  用户 ID 列表, 逗号分隔, 最多 100 个 (必填)
```

返回每条记录含：用户 ID、工作日期、时间结果（Normal/Late/Early/Absenteeism/NotSigned）、位置结果、计划打卡时间、实际打卡时间、打卡流水 ID。时间跨度不超过 1 个月，最多 100 人。

### 查询打卡流水
```
Usage:
  dws attendance check record [flags]
Example:
  dws attendance check record --users userId1 --from 2026-04-01 --to 2026-04-30
Flags:
      --from string   起始日期, 格式 YYYY-MM-DD (必填)
      --to string     结束日期, 格式 YYYY-MM-DD, 不超过 1 个月 (必填)
      --users string  用户 ID 列表, 逗号分隔 (必填)
```

返回每条记录含：用户 ID、实际打卡时间、打卡地址、打卡经纬度、打卡类型（OnDuty/OffDuty）、定位方式（Map/Wifi/etc）。时间跨度不超过 1 个月。

### 查询审批单
```
Usage:
  dws attendance approve list [flags]
Example:
  dws attendance approve list --users userId1 --types overtime,leave --from 2026-04-01 --to 2026-04-30
Flags:
      --from string   起始日期, 格式 YYYY-MM-DD (必填)
      --to string     结束日期, 格式 YYYY-MM-DD (必填)
      --types string  审批类型, 逗号分隔: overtime/trip/leave/patch (必填)
      --users string  用户 ID 列表, 逗号分隔 (必填)
```

审批类型映射：overtime=加班, trip=出差, leave=请假, patch=补卡。返回每条记录含：用户 ID、审批标签、审批子类型、审批类型、生效时间、时长、时长单位、流程实例 ID。

### 导入排班记录（排班 = 为员工安排工作日期和班次）
```
Usage:
  dws attendance schedule import [flags]
Example:
  dws attendance schedule import --group-id 123456 \
    --schedules '[{"userId":"user001","classId":123,"workDate":"2026-04-22","checkBeginTime":"09:00","checkEndTime":"18:00"}]' \
    --yes
Flags:
      --group-id string   考勤组ID（必填）
      --schedules string  排班记录 JSON 数组（必填）
      --yes               跳过确认提示
```

为排班制考勤组导入排班记录。`--schedules` 为 JSON 数组，每条记录包含：
- `userId`: 员工ID
- `classId`: 班次ID
- `workDate`: 工作日期（YYYY-MM-DD）
- `checkBeginTime`: 开始打卡时间
- `checkEndTime`: 结束打卡时间
- `isRest`: 是否休息日 Y/N（可选）

### 获取排班记录
```
Usage:
  dws attendance schedule get [flags]
Example:
  dws attendance schedule get --users user001,user002 --start 2026-04-01 --end 2026-04-30
Flags:
      --end string     结束日期, 格式 YYYY-MM-DD（必填）
      --start string   开始日期, 格式 YYYY-MM-DD（必填）
      --users string   用户ID列表, 逗号分隔（必填）
```

获取指定用户在一段时间内的排班记录。返回每条记录包含：userId、classId、workDate、className、checkBeginTime、checkEndTime、isRest 等字段。

### 查询当前用户可管理的所有班次详情
```
Usage:
  dws attendance class search [flags]
Example:
  dws attendance class search
  dws attendance class search --name "早班" --filter-type MINE_OWN
  dws attendance class search --page-index 1 --page-size 50
Flags:
      --filter-type string   班次类型: ALL 全部班次 / MINE_OWN 我负责的 (可选)
      --name string          班次名称关键字, 模糊搜索 (可选)
      --page-index int       页码, 从 1 开始 (可选, 默认 1)
      --page-size int        每页条数, 最大 200 (可选, 默认 20)
```

### 查询班次详情
```
Usage:
  dws attendance class get [flags]
Example:
  dws attendance class get --class-id 1170996821
Flags:
      --class-id int   班次 ID (必填)
```

根据班次 ID 查询该班次的完整详细信息。班次 ID 可从 `class search` 返回结果中提取，也有可能来源于用户手动输入。

### 分页查询补卡规则，支持按名称搜素
```
Usage:
  dws attendance adjustment search [flags]
Example:
  dws attendance adjustment search --current-page 1 --limit 20
  dws attendance adjustment search --name "标准" --current-page 1 --limit 50
Flags:
      --current-page int   页码, 从 1 开始 (必填, 默认 1)
      --name string        补卡规则名称关键字, 模糊搜索 (可选)
      --limit int          每页条数, 200 以内 (必填, 默认 20)
```

### 查询补卡规则详情
```
Usage:
  dws attendance adjustment get [flags]
Example:
  dws attendance adjustment get --adjustment-id 12345
Flags:
      --adjustment-id int   补卡规则主键 ID (必填)
```

根据补卡规则主键 ID 查询对应的补卡规则详情。主键 ID 可从 `adjustment search` 返回结果中提取，也有可能来源于用户手动输入。**注意：已被删除或被更新覆盖的补卡规则无法查询到。**

### 分页查询加班规则，支持按名称搜素
```
Usage:
  dws attendance overtime search [flags]
Example:
  dws attendance overtime search --current-page 1 --limit 20
  dws attendance overtime search --name "节假日" --current-page 1 --limit 50
Flags:
      --current-page int   页码, 从 1 开始 (必填, 默认 1)
      --name string        加班规则名称关键字, 模糊搜索 (可选)
      --limit int          每页条数, 200 以内 (必填, 默认 20)
```

### 查询加班规则详情
```
Usage:
  dws attendance overtime get [flags]
Example:
  dws attendance overtime get --overtime-id 12345
Flags:
      --overtime-id int   加班规则主键 ID (必填)
```

根据加班规则主键 ID 查询对应的加班规则详情。主键 ID 可从 `overtime search` 返回结果中提取，也有可能来源于用户手动输入。**已被删除或更新覆盖的加班规则也可以查到。**

### 查询考勤组列表
```
Usage:
  dws attendance group search [flags]
Example:
  dws attendance group search --name "研发"
  dws attendance group search --type FIXED --limit 50
  dws attendance group search --page-index 1 --limit 20
Flags:
      --name string          考勤组名称关键字, 模糊搜索 (可选)
      --page-index int       页码, 从 1 开始 (必填, 默认 1)
      --limit int            每页条数, 200 以内 (必填, 默认 20)
      --query-ble            是否查询蓝牙设备列表 (可选, 默认 false)
      --query-position       是否查询地理定位和 Wifi 名称 (可选, 默认 false)
      --type string          考勤组类型: FIXED 固定班制 / TURN 排班制 / NONE 自由工时 (可选)
```

### 查询考勤组全量信息
```
Usage:
  dws attendance group get [flags]
Example:
  dws attendance group get --group-id 123456
Flags:
      --group-id int   考勤组 ID (必填)
```

根据考勤组 ID 查询该考勤组的全量信息。考勤组 ID 可从 `group search` 返回结果中提取，也有可能来源于用户手动输入。如果只需查询成员、打卡地址、蓝牙、Wifi 子集，请使用 `group filtered-get` 以节省查询成本。
返回结果中如含成员 userId 列表，必须调用 `dws contact user get --ids <userId1>,<userId2>,...`（支持逗号分隔传多个 ID），将 userId 转换为员工姓名后再输出；不得直接输出裸 userId

### 按需查询考勤组部分信息
```
Usage:
  dws attendance group filtered-get [flags]
Example:
  dws attendance group filtered-get --group-id 123456 --member
  dws attendance group filtered-get --group-id 123456 --position --wifi
Flags:
      --group-id int     考勤组 ID (必填)
      --member           是否查询考勤组成员信息 (可选, 默认 false)
      --position         是否查询打卡地址 (可选, 默认 false)
      --wifi             是否查询打卡 Wifi (可选, 默认 false)
      --bles             是否查询打卡蓝牙 (可选, 默认 false)
```

强烈建议在仅需查询成员、打卡地址、蓝牙、Wifi 时调用该命令，避免全量查询带来的性能开销。考勤组 ID 可从 `group search` 返回结果中提取，也有可能来源于用户手动输入。
返回结果中如含成员 userId 列表，必须调用 `dws contact user get --ids <userId1>,<userId2>,...`（支持逗号分隔传多个 ID），将 userId 转换为员工姓名后再输出；不得直接输出裸 userId

### 查询某个人的考勤统计摘要
```
Usage:
  dws attendance summary [flags]
Example:
  dws attendance summary --user USER_ID --date "2026-03-12 15:00:00"
Flags:
      --date string   工作日期, 格式 yyyy-MM-dd HH:mm:ss (必填)
      --user string   钉钉用户 ID (必填)
```

### 查询考勤组与考勤规则
```
Usage:
  dws attendance rules [flags]
Example:
  dws attendance rules --date 2026-03-14
  dws attendance rules --date "2026-03-14 09:00:00"
Flags:
      --date string   考勤日期, 格式 YYYY-MM-DD 或 yyyy-MM-dd HH:mm:ss (必填)
```

查询考勤组/考勤规则。例如：我属于哪个考勤组、打卡范围是什么、弹性工时怎么算。


### 获取企业考勤字段列表（仅管理员）
```
Usage:
  dws attendance report columns
Example:
  dws attendance report columns
```

根据操作者的列权限，过滤并返回其有权查看的考勤字段列表。操作者必须是管理员，否则返回权限错误。

### 根据字段查询考勤数据（仅管理员）
```
Usage:
  dws attendance report query-data [flags]
Example:
  dws attendance report query-data \
    --users userId1,userId2 --columns 1001,1002 --start "2026-03-01 00:00:00" --end "2026-03-31 23:59:59"
Flags:
      --columns string   字段 ID 列表, 逗号分隔, 可通过 report columns 获取（必填）
      --end string       结束日期, 格式 yyyy-MM-dd HH:mm:ss（必填）
      --start string     开始日期, 格式 yyyy-MM-dd HH:mm:ss（必填）
      --users string     目标用户 ID 列表, 逗号分隔, 最多 20 人（必填）
```

根据字段查询考勤数据，含列权限过滤和用户查看权限校验。--users 最多 20 人，--start 到 --end 不超过 32 天。

### 查询用户假期数据（仅管理员）
```
Usage:
  dws attendance report query-leave [flags]
Example:
  dws attendance report query-leave \
    --users userId1,userId2 --leave-names 年假,病假 --start "2026-03-01 00:00:00" --end "2026-03-31 23:59:59"
Flags:
      --end string          结束日期, 格式 yyyy-MM-dd HH:mm:ss（必填）
      --leave-names string  假期类型名称列表, 逗号分隔, 不填则查询所有假期类型（选填）
      --start string        开始日期, 格式 yyyy-MM-dd HH:mm:ss（必填）
      --users string        目标用户 ID 列表, 逗号分隔, 最多 20 人（必填）
```

查询用户假期数据，含用户查看权限校验。--users 最多 20 人，--start 到 --end 不超过 32 天。

### 查询当前用户假期规则列表
```
Usage:
  dws attendance vacation types
Example:
  dws attendance vacation types
Flags:
  无
```

调用 MCP 工具 get_leave_types 查询当前用户可用的假期规则列表。例如：年假、事假、病假等假期类型及对应规则。请求体封装在 McpLeaveTypeRequest 中，认证信息（corpId、opUserId）由系统自动注入，无需手动传入。

### 查询指定员工假期余额
```
Usage:
  dws attendance vacation balance [flags]
Example:
  dws attendance vacation balance --users userId1,userId2 --leave-code XXXX
Flags:
      --users string       目标员工 ID 列表, 逗号分隔 (必填)
      --leave-code string  假期规则 code (必填, 不传则无法查询)
```

调用 MCP 工具 get_leave_balance_quota 查询指定员工的假期余额。例如：查询某员工年假还剩多少、病假额度等。`--leave-code` 可通过 `vacation types` 获取。认证信息（corpId、opUserId）由系统自动注入。

### 查询指定员工假期余额变更记录
```
Usage:
  dws attendance vacation records [flags]
Example:
  dws attendance vacation records --user USER_ID --leave-code XXXX --start 2026-04-01 --end 2026-04-22
Flags:
      --user string        指定查询员工 ID (必填)
      --leave-code string  假期规则 code (必填, 不传则无法查询)
      --start string       查询开始日期, 格式 YYYY-MM-DD (必填)
      --end string         查询结束日期, 格式 YYYY-MM-DD (必填)
```

调用 MCP 工具 get_leave_balance_records 查询指定员工的假期余额变更记录。例如：查询某员工年假变更历史、请假扣减记录等。`--leave-code` 可通过 `vacation types` 获取。认证信息（corpId、opUserId）由系统自动注入。

### 查询指定员工的签到记录
```
Usage:
  dws attendance checkin records [flags]
Example:
  dws attendance checkin records \
    --operator-staff-id op001 --staff-ids user001,user002 --start "2026-04-01 00:00:00" --end "2026-04-07 00:00:00"
Flags:
      --end string                结束时间, 格式 yyyy-MM-dd HH:mm:ss（必填）
      --operator-corp-id string   操作者企业 ID（必填）
      --operator-staff-id string  操作者员userID（必填）
      --staff-ids string          目标员工userID 列表, 逗号分隔（必填），员工数最多100个人
      --start string              开始时间, 格式 yyyy-MM-dd HH:mm:ss（必填），开始到结束时间限制在7天
```

调用 MCP 工具 get_checkin_record 查询指定员工在一段时间内的签到记录。权限说明：Boss/超级管理员可查看全公司员工，子管理员可查看管理范围内员工，部门主管可查看所管理部门员工，普通员工只能查询自己。接口单次最多返回100条签到记录。

## 意图判断

用户说"打卡记录/出勤/考勤" → `check record`
用户说"指定用户打卡结果/考勤结果/迟到早退/缺卡异常" → `check result`
用户说"指定用户打卡流水/打卡详情/打卡时间地点/打卡记录详情" → `check record`
用户说"审批单/请假记录/加班记录/出差记录/补卡记录" → `approve list`
用户说"班次/当班/打卡安排" → `schedule get`
用户说"导入排班/设置排班/安排排班" → `schedule import`
用户说"查询排班记录/获取排班详情" → `schedule get`
用户说"班次定义/班次列表/有哪些班次/我负责的班次" → `class search`（返回结果已包含全量属性，无需再调 get）
用户说"班次详情/某个班次的具体信息" → `class search --name "..."`（search 直出，直接返回详情）。`class get` 仅在需要按已知 classId 精确查询时使用
用户说"补卡规则/补卡设置" → `adjustment search`（返回结果已包含全量属性，无需再调 get）
用户说"补卡规则详情/某条补卡规则的具体信息" → `adjustment search --name "..."`（search 直出）。`adjustment get` 仅在需要按已知 adjustmentId 精确查询时使用
用户说"加班规则/加班设置/加班计算" → `overtime search`（返回结果已包含全量属性，无需再调 get）
用户说"加班规则详情/某条加班规则的具体信息" → `overtime search --name "..."`（search 直出）。如需查已删除/被覆盖的历史记录 → `overtime get`
用户说"考勤组列表/有哪些考勤组" → `group search`
用户说"考勤组详情/全量考勤组信息" → `group get`,若返回结果中含成员 userId 列表，则对每个 userId 调用 `dws contact user get --user-ids <userId>`（或等价通讯录查询），在最终输出中展示员工姓名而非裸 userId
用户说"考勤组成员/打卡地址/打卡wifi/打卡蓝牙" → `group filtered-get`（按需查询，节省成本）,若返回结果中含成员 userId 列表，则对每个 userId 调用 `dws contact user get --user-ids <userId>`（或等价通讯录查询），在最终输出中展示员工姓名而非裸 userId
用户说"考勤组/考勤规则/打卡规则" → `rules`
用户说"考勤字段/考勤列" → `report columns`
用户说"考勤数据/查询考勤报表数据" → `report query-data`（单次查询场景，非导出）
  **导出考勤/导出报表/生成考勤报表/出勤汇总导出/考勤明细导出/迟到早退统计导出/全员考勤数据导出/月度考勤报表/考勤表格/考勤 Excel** → **必须先 `read_file` 读取 [attendance-report.md](./attendance-report.md) 后按其中的工作流执行**。
  - **严禁**绕过 `attendance-report.md` 直接调用 `python scripts/attendance_report_*.py` 任何脚本
  - **严禁**仅凭脚本 `--help` 或本文件"自动化脚本"表格里的脚本路径就推断参数自行组装命令
  - 该文档定义了：报表类型默认值、列选择策略（`--column-keywords`）、阶段 1 人员获取流程、错误处理、输出摘要规范，缺一不可
  - 违反约束的后果：报表数据不全、列错位、人员遗漏、用户得到错误结果
用户说"假期数据/年假/病假/请假记录" → `report query-leave`
用户说"假期/我的假期/假期规则" → `vacation types`
用户说"假期余额/年假余额/剩余假期" → `vacation balance`
用户说"假期变更/假期记录/请假扣减" → `vacation records`
用户说"签到/签到记录" → `checkin records`

## 核心工作流

```bash
# 导入排班记录
dws attendance schedule import --group-id 123456 \
  --schedules '[{"userId":"user001","classId":123,"workDate":"2026-04-22","checkBeginTime":"09:00","checkEndTime":"18:00"}]' \
  --yes --format json

# 获取排班记录
dws attendance schedule get --users user001,user002 \
  --start 2026-04-01 --end 2026-04-30 --format json

# 查询可管理的班次列表
dws attendance class search --format json
dws attendance class search --name "早班" --filter-type MINE_OWN --format json

# 查询班次详情
dws attendance class get --class-id 1170996821 --format json

# 查询补卡规则
dws attendance adjustment search --current-page 1 --limit 20 --format json
dws attendance adjustment search --name "标准" --current-page 1 --limit 20 --format json

# 查询补卡规则详情
dws attendance adjustment get --adjustment-id 12345 --format json

# 查询加班规则
dws attendance overtime search --current-page 1 --limit 20 --format json

# 查询加班规则详情
dws attendance overtime get --overtime-id 12345 --format json

# 查询考勤组列表
dws attendance group search --name "研发" --page-index 1 --limit 20 --format json
dws attendance group search --type FIXED --page-index 1 --limit 20 --format json

# 查询考勤组全量信息
dws attendance group get --group-id 123456 --format json

# 按需查询考勤组成员/地址/蓝牙/Wifi
dws attendance group filtered-get --group-id 123456 --member --format json
dws attendance group filtered-get --group-id 123456 --position --wifi --format json

# 查看考勤统计摘要
dws attendance summary --user <USER_ID> --date "2026-03-12 15:00:00" --format json

# 查看考勤组和规则
dws attendance rules --date 2026-03-14 --format json

# 获取考勤字段列表（管理员）
dws attendance report columns --format json

# 根据字段查询考勤数据（管理员）
dws attendance report query-data --users userId1,userId2 \
  --columns 1001,1002 --start "2026-03-01 00:00:00" --end "2026-03-31 23:59:59" --format json

# 查询用户假期数据（管理员）
dws attendance report query-leave --users userId1,userId2 \
  --leave-names 年假,病假 --start "2026-03-01 00:00:00" --end "2026-03-31 23:59:59" --format json

# 查看假期规则列表
dws attendance vacation types --format json

# 查看指定员工假期余额
dws attendance vacation balance --users userId1,userId2 --format json

# 查看指定员工某类假期余额
dws attendance vacation balance --users userId1 --leave-code XXXX --format json

# 查看指定员工假期余额变更记录
dws attendance vacation records --user USER_ID --start 2026-04-01 --end 2026-04-22 --format json

# 查询签到记录
dws attendance checkin records --operator-staff-id op001 --staff-ids user001,user002 \
  --start "2026-04-01 00:00:00" --end "2026-04-07 00:00:00" --format json

```

## 上下文传递表
| 操作 | 提取 | 用于 |
|------|------|------|
| `contact user get-self` | `userId` | summary 的 --user |
| `rules` | `groupId` | schedule import 的 --group-id |
| `schedule import` | `classId` | schedule import 的 schedules 中的 classId |
| `contact user search` | `userId` | schedule import/get 的 userId |

| `contact user get-self` | `userId` | summary 的 --user, vacation records 的 --user |
| `vacation types` | `leaveCode` | vacation balance 的 --leave-code, vacation records 的 --leave-code |
## 注意事项
- `schedule import` 导入排班记录，`--schedules` 为 JSON 数组字符串
- `schedule get` 获取排班记录，`--start/--end` 使用 YYYY-MM-DD 格式
- `class search` 所有参数均为可选，不填时返回全部可管理班次（默认第 1 页，每页 20 条）
- **概念区分**：班次是员工当天打卡安排；排班是为排班制考勤组导入的排班记录；班次定义是考勤管理员创建的工作时间规则
- `class get` 的 `--class-id` 必填，班次 ID 可从 `class search` 结果中提取
- `class search` 返回结果已包含全量属性，无需再调用 `class get`；`class get` 仅在需要按已知 classId 精确查询时使用
- `adjustment search` 返回结果已包含全量属性，无需再调用 `adjustment get`；`adjustment get` 仅在需要按已知 adjustmentId 精确查询时使用
- `overtime search` 返回结果已包含全量属性，无需再调用 `overtime get`；`overtime get` 仅在需要按已知 overtimeId 查询时使用（包括已删除/被覆盖的历史记录）
- `adjustment search` / `overtime search` 分页字段为 `--current-page`（非 `--page-index`），`--current-page` 和 `--limit` 必填，默认分别为 1 / 20
- `group search` 的 `--page-index` 和 `--limit` 必填，不传时自动使用默认值 1 / 20
- `group get` 的 `--group-id` 必填，返回考勤组全量字段；如仅需成员/地址/蓝牙/Wifi，优先使用 `group filtered-get` 节省成本。**返回结果中如含成员 userId 列表，必须调用 `dws contact user get --ids <userId1>,<userId2>,...`（支持逗号分隔传多个 ID），将 userId 转换为员工姓名后再输出；不得直接输出裸 userId。**
- `group filtered-get` 的 `--group-id` 必填，`--member/--position/--wifi/--bles` 均可选，默认 false。**返回结果中如含成员 userId 列表，必须调用 `dws contact user get --ids <userId1>,<userId2>,...`（支持逗号分隔传多个 ID），将 userId 转换为员工姓名后再输出；不得直接输出裸 userId。**
- `summary` 的 `--date` 格式: yyyy-MM-dd HH:mm:ss（如 `2026-03-12 15:00:00`）
- `rules` 的 `--date` 支持 YYYY-MM-DD 或 yyyy-MM-dd HH:mm:ss 两种格式
- `report columns` 无需额外参数，corpId 和 operatorId 由系统自动传入
- `report query-data` 和 `report query-leave` 的 `--start/--end` 格式: yyyy-MM-dd HH:mm:ss，间隔不超过 32 天，最多 20 人
- report 系列接口仅对管理员开放
- 用户 ID 需从 `contact user get-self` 或 `aisearch person` 获取
- 考勤组 ID 需从 `rules` 命令返回结果中获取
- `vacation types` 无需任何参数，认证信息自动注入
- `vacation balance` 的 `--users` 为目标员工 ID 列表，逗号分隔；`--leave-code` 选填，可通过 `vacation types` 获取
- `vacation records` 的 `--start/--end` 使用 YYYY-MM-DD 格式，CLI 自动转换为毫秒时间戳；`--leave-code` 选填
- `vacation balance` 和 `vacation records` 的认证参数（corpId、opUserId）由系统自动注入，无需手动传入

## 自动化脚本

| 脚本 | 场景 | 用法 |
|------|------|------|
| [attendance_my_record.py](../../scripts/attendance_my_record.py) | 查看我今天/指定日期的考勤记录 | `python attendance_my_record.py today` |
| [attendance_team_shift.py](../../scripts/attendance_team_shift.py) | 查询团队成员本周排班 | `python attendance_team_shift.py --users userId1,userId2` |
| [attendance_report_common.py](../../scripts/attendance_report_common.py) | 考勤报表导出公共模块（不可单独执行） | — |
| attendance_report_detail.py | 考勤报表 — **明细粒度** |  **禁止直接调用**，必须先读 [attendance-report.md](./attendance-report.md) 按工作流执行 |
| attendance_report_monthly.py | 考勤报表 — **月度汇总** |  **禁止直接调用**，必须先读 [attendance-report.md](./attendance-report.md) 按工作流执行 |
| attendance_report_daily.py | 考勤报表 — **每日统计** |  **禁止直接调用**，必须先读 [attendance-report.md](./attendance-report.md) 按工作流执行 |

> 说明：
> - `attendance_report_*.py` 三个脚本由 [attendance-report.md](./attendance-report.md) 工作流编排使用，自动处理 `--users` 超过 20 人分批、`--start/--end` 超过 32 天按月切片，输出 `attendance_report_<startDate>_<endDate>_<粒度>.xlsx`

## 严格约束
- 不要凭历史记忆复用 userId / classId / leaveCode / groupId / instanceId 等任何 ID，每次必须从当次命令返回值中提取
- 不要猜测命令，先查询明确命令
- 制定 plan 并自我审查，严格按 plan 执行
- 涉及超过 3 条记录的聚合（求和、分组、计数、排序、跨字段计算）时必须落 Python 脚本处理，禁止用大模型口算或目测。脚本里如果用到 mcp，先提前看下 mcp 返回的结构，避免执行异常
- 遇到时长字段时，注意区分单位是秒、分钟还是小时
- 遇到意图不清晰的场景不要猜测，主动询问用户明确意图
- 如果查询结果很多时，不要自作主张省略，必须明确告知用户或者用表格或展示所有。