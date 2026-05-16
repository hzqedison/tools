# dws-skill for Claude Code

让 Claude Code 直接操作钉钉——发消息、读文档、查日程、审批 OA、管理待办……

## 前置条件

安装 [Wukong（悟空）桌面端](https://wukong.dingtalk.com)，`dws.exe` 已随 Wukong 内置，无需单独安装。

## 一键安装

在 PowerShell 中运行：

```powershell
irm https://raw.githubusercontent.com/hzqedison/dws-skill/main/install.ps1 | iex
```

脚本会自动下载并安装到 `~/.claude/skills/`。

## 手动安装

将 `skills/` 目录下的三个文件/文件夹复制到 `~/.claude/skills/`：

```
~/.claude/skills/
├── dws.md
├── dws-refs/
└── dws-scripts/
```

## 首次使用

安装完成后重启 Claude Code，直接说钉钉相关的话即可触发，例如：

- "帮我搜一下钉钉里的会议纪要"
- "给张三发条钉钉消息"
- "查一下我今天的日程"

**首次运行时**，若提示未登录，按提示执行：

```powershell
dws auth login
```

扫码完成一次性授权，后续无需重复操作。

## 能力覆盖

| 产品 | 功能 |
|---|---|
| 消息/群聊 | 发消息、建群、拉人、机器人群发、Webhook |
| 日历 | 查日程、约会议、订会议室、查闲忙 |
| 文档 | 读文档、写文档、搜文档、知识库 |
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
