# 文档知识

> lite recipe 见 [SKILL.md 速查表](../../../../SKILL.md#常用-recipe-速查表lite-recipe--可直接执行无需读行动指南文件)。

| Recipe | 行动指南（固定路线） |
|--------|-------------------|
| write-doc | 1. 按[「多源并行采集」](../_common/conventions.md#多源并行采集公共模式)执行<br>2. **先把内容写入临时文件**（Linux/Mac `/tmp/<name>.md`，Windows `%TEMP%\<name>.md`）—— 含多行/表格/长文本必须走文件，不要把 markdown 直接作为命令行字符串<br>3. **单步创建**（< 200KB）：`doc create --name "<文档名>" --content-file <tmp> [--folder <DOC_FOLDER_NODE_ID>] [--workspace <WS_ID>]`（`--folder` 只传文档文件夹 nodeId / alidocs 文件夹 URL，不传数字 dentryId）<br>4. **超长兜底**（> 200KB）：`doc create --name "<文档名>" [--folder/--workspace]` → `nodeId` → 按段落切 ≤200KB 片段（不断表格） → 每片 `doc update --node <nodeId> --content-file <part> --mode append`<br>备选（仅短内容 <2KB 且无换行/表格）：`doc create --name "..." --content "..."` |
| search-docs-and-share | 1. `doc search --query "<关键词>"` → 取 `nodeId` + 标题建索引（不读全文）<br>2. `doc read --node <nodeId>`（追问按需，最多 2 篇） |
| create-knowledge-base | 1. 创建知识库空间取 `WS_ID`<br>2. `doc create --name "<文档名>" --workspace <WS_ID>` → 取 `nodeId`<br>3. `doc list --workspace <WS_ID>` 确认 |
| migrate-doc | 1. `doc read --node <源nodeId>` → 取正文并写入临时文件 `<tmp>.md`<br>2. `doc create --name "<文档名>" --folder <DOC_FOLDER_NODE_ID> --content-file <tmp>.md` → 取新 `nodeId`（`--folder` 只传文档文件夹 nodeId / alidocs 文件夹 URL，不传数字 dentryId；正文 <200KB 单步到位）<br>2a. 若正文 >200KB：`doc create --name "<文档名>" --folder <DOC_FOLDER_NODE_ID>` → `nodeId` → 按段落切片 → 每片 `doc update --node <nodeId> --content-file <part> --mode append`<br>3. `doc read --node <nodeId>` 校验 |
| update-doc-section | 1. `doc search --query "<关键词>"` → 取 `nodeId`<br>2. `doc read --node <nodeId>` 定位目标章节<br>3. `doc update --node <nodeId> --content "<替换内容>" --mode overwrite`<br>**overwrite 须用户确认** |
| doc-to-message | 1. `doc read --node <nodeId>` → 取正文（大文档只摘要+链接）<br>2. `contact user search --query "<姓名>"` → 取 `openDingTalkId`（推荐）；或 `chat search --query "<群名>"` → 取 `openConversationId`<br>3. `chat message send --open-dingtalk-id <openDingTalkId> --text "<内容>"`（推荐）或 `--group <openConversationId> --text "<内容>"` 发送。仅当无法获取 openDingTalkId 时才用 `--user <userId>`（备选） |
