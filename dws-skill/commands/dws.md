---
name: "dws"
description: 钉钉全产品操作 — 发消息、读文档、查日程、审批OA、管理待办等所有钉钉相关操作
---

使用 dws skill 执行钉钉操作。

**输入**：`/dws` 后面跟用户想做的事，例如：
- `/dws 读取这个文档 https://alidocs.dingtalk.com/...`
- `/dws 查我今天的日程`
- `/dws 给张三发消息：明天上午开会`
- `/dws 列出我未完成的待办`

**执行步骤**：

1. 读取 skill 文件获取完整执行规范：
   ```
   ~/.claude/skills/dws.md
   ```

2. 按 skill 文件中的「工具定位」步骤找到 `wukong-cli.exe` 路径，检查 `\\.\pipe\real-daemon` 管道是否存在。

3. 若管道不存在，告知用户：「请先启动 Wukong（悟空）桌面端并登录钉钉账号」。

4. 根据用户输入（`$ARGUMENTS`），参照 skill 文件中的「产品路由表」判断涉及哪个钉钉产品，然后构造清晰的任务描述，使用标准模板执行：
   ```powershell
   $result = & $wkcli --socket "\\.\pipe\real-daemon" `
       -p "<任务描述>" `
       --output-format json `
       --max-turns <N> `
       2>&1 | Select-Object -First 20
   ($result | ConvertFrom-Json).output_text
   ```

5. 将结果整理后呈现给用户。危险操作（删除/DING/审批）必须先确认。

**如果没有输入**（用户只输入了 `/dws`），询问用户想做什么钉钉操作。
