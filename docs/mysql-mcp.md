# MySQL MCP 工具说明

本项目通过 [Model Context Protocol](https://modelcontextprotocol.io/) 连接本地 MySQL，供 Cursor Agent 执行查询、建库与初始化脚本。

## 配置位置

| 范围 | 文件 |
|------|------|
| 全局（推荐） | `%USERPROFILE%\.cursor\mcp.json` 中的 `mysql` 节点 |
| 本项目 | `.cursor/mcp.json` |

修改连接信息后，在 Cursor 中 **Settings → MCP** 对 `mysql` 服务器点击 **Refresh** 或重启 Cursor。

## 环境变量

与 `config/application.yml.example` 默认一致：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `MYSQL_HOST` | `127.0.0.1` | 主机 |
| `MYSQL_PORT` | `3306` | 端口 |
| `MYSQL_USER` | `root` | 用户名 |
| `MYSQL_PASS` | `root` | 密码（请按本机实际修改） |
| `MYSQL_DB` | `davinci0.3` | 系统库名 |
| `ALLOW_INSERT_OPERATION` | `true` | 允许 INSERT |
| `ALLOW_UPDATE_OPERATION` | `true` | 允许 UPDATE |
| `ALLOW_DELETE_OPERATION` | `true` | 允许 DELETE |
| `ALLOW_DDL_OPERATION` | `true` | 允许 DDL |
| `MYSQL_DISABLE_READ_ONLY_TRANSACTIONS` | `true` | 允许建表/导入（开发环境） |

生产环境建议关闭写操作与 DDL，仅保留只读查询。

## 提供的工具

由 npm 包 `@benborla29/mcp-server-mysql` 提供，主要包括：

- **mysql_query**：执行 SQL（在环境变量允许范围内）

## 典型用法（Agent）

1. 建库（若不存在）：
   ```sql
   CREATE DATABASE IF NOT EXISTS davinci0.3 DEFAULT CHARACTER SET utf8mb4;
   ```
2. 导入初始化脚本：在对话中说明执行 `bin/davinci.sql` 中的语句，或分段执行关键 DDL/DML。
3. 验证：`SHOW TABLES;`、`SELECT COUNT(*) FROM user;`

## 与 mssql MCP 对比

| | MySQL (`mysql`) | SQL Server (`mssql`) |
|--|-----------------|----------------------|
| 包 | `@benborla29/mcp-server-mysql` | `mssql-mcp` |
| 连接变量 | `MYSQL_*` | `DB_*` |
| Davinci 脚本 | `bin/davinci.sql` | `bin/davinci.sqlserver.sql` |

## 故障排查

- MCP 列表中无 `mysql`：检查 `mcp.json` JSON 格式，并刷新 MCP。
- 连接失败：确认本机 3306 已监听（`netstat -an | findstr 3306`），用户名密码与 `config/application.yml` 一致。
- 拒绝写操作：确认 `ALLOW_*` 与 `MYSQL_DISABLE_READ_ONLY_TRANSACTIONS` 为 `true`（仅开发）。
