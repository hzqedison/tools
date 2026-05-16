# 全局参考

## 认证

认证由客户端自动管理，无需手动操作。Token 过期时系统会自动刷新。

如遇到认证相关错误(`AUTH_TOKEN_EXPIRED` / `USER_TOKEN_ILLEGAL` / "Token验证失败")，直接重试命令即可（最多重试两次），系统会自动重新授权。

## 全局标志

| 标志 | 短名 | 说明 | 默认 |
|------|:---:|------|------|
| `--format` | `-f` | 输出格式: json / table / raw | table |
| `--verbose` | `-v` | 详细日志 | false |
| `--debug` | | 调试日志 | false |
| `--yes` | `-y` | 跳过确认提示 | false |
| `--dry-run` | | 预览操作不执行 | false |
| `--timeout` | | HTTP 超时 (秒) | 30 |
| `--mock` | | Mock 数据 (开发用) | false |

## 输出格式

### --format json (机器可读, Agent 必须使用)

```json
{"success": true, "body": {...}}
```

### --format table (人类可读, 默认)

```
已创建 AI 表格 "项目管理" (UUID: abc123)

下一步:
  dws aitable base get --base-id abc123
```
