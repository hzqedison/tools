# dws-skill for Claude Code

让 Claude Code 直接操作钉钉——读文档、发消息、查日程、审批 OA、管理待办……

## 前置条件

**安装并运行 [Wukong（悟空）桌面端](https://wukong.dingtalk.com)**，登录钉钉账号保持在线即可。无需额外配置，认证由 Wukong 自动管理。

> Wukong 未运行时，Claude 会提示你先启动它。

## 一键安装

在 PowerShell 中运行：

```powershell
irm https://raw.githubusercontent.com/hzqedison/tools/main/dws-skill/install.ps1 | iex
```

脚本自动完成：
- skill 文件 → `~/.claude/skills/`
- `/dws` 斜杠命令 → `~/.claude/commands/`

## 手动安装

将以下文件复制到对应目录：

```
~/.claude/
├── skills/
│   ├── dws.md          ← 主 skill 文件
│   ├── dws-refs/       ← 钉钉产品参考文档
│   └── dws-scripts/    ← 辅助脚本
└── commands/
    └── dws.md          ← /dws 斜杠命令
```

## 使用方式

重启 Claude Code 后有两种触发方式：

**方式一：自然语言（自动触发）**

直接描述钉钉相关任务，skill 自动识别并执行：

```
帮我搜一下钉钉里的会议纪要
给张三发条消息：明天下午3点开会
查一下我今天的日程安排
列出我所有未完成的待办
```

**方式二：`/dws` 斜杠命令（显式触发）**

```
/dws 读取这个文档 https://alidocs.dingtalk.com/i/nodes/xxx
/dws 查我本周的考勤记录
/dws 列出研发群最近50条消息
/dws 帮我审批一下待处理的 OA
```

## 能力覆盖

| 产品 | 功能 |
|---|---|
| 消息/群聊 | 发消息、建群、拉人、机器人群发、Webhook |
| 日历 | 查日程、约会议、订会议室、查闲忙 |
| 文档 | 读文档、写文档、搜文档、知识库管理 |
| 通讯录 | 搜同事、查部门、找负责人、查工号/手机号 |
| 待办 | 创建/查询/完成 TODO |
| 邮件 | 发邮件、查收件箱 |
| OA 审批 | 查待审、同意/拒绝 |
| AI 表格 | 建表、查记录、写数据 |
| 电子表格 | 单元格读写、公式、导出 |
| 考勤 | 查打卡记录、排班 |
| AI 听记 | 查摘要、转写、关键词 |
| 日志 | 写日报/周报、查收件箱 |
| 钉盘 | 上传/下载/浏览文件 |
| 更多 | DING 消息、视频会议、直播、AI 应用… |

## 工作原理

```
Claude Code
    ↓ 自然语言任务
wukong-cli ←→ Wukong 守护进程（\\.\pipe\real-daemon）
    ↓ 内部调用 dws 工具
钉钉 API
```

认证由 Wukong 桌面端全程托管，Claude Code 无需单独登录。
