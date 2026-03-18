---
name: go-web-starter
description: This skill should be used when the user asks to "create a Go web project", "init Go web service", "bootstrap Gin project", "create Go API server", "setup Go backend with SQLite", or needs to set up a production-ready Go web application with Gin, SQLite, CLI flags, slog logging, and graceful shutdown.
version: 1.0.0
---

# Go Web Starter

创建一个生产级 Go Web 服务项目。

## 使用场景

当用户需要创建新的 Go Web 项目时，使用此 skill 生成标准化的项目结构。

## 必需参数

- `module`: Go module 路径，如 github.com/user/project
- `name`: 项目名称

## 必须包含的组件

### 1. CLI 配置 (urfave/cli/v2)
- host/port/db/debug/log-level/admin-key 等 flags
- 支持从环境变量读取（EnvVars）
- 必须的 flag 标记 Required

### 2. 日志系统 (log/slog)
- slog.NewTextHandler 输出到 stdout
- 支持 log-level 参数（debug/info/warn/error）
- slog.SetDefault 设置为全局 logger

### 3. Gin 配置
- gin.ReleaseMode / gin.DebugMode 根据 debug flag 切换
- 中间件顺序：Recovery → CORS → Logging
- 非 debug 模式禁用控制台颜色

### 4. 数据库 (modernc.org/sqlite + xorm)
- database.Init(dbPath, debug) 初始化
- Engine 全局变量导出
- SyncModels() 自动同步表结构
- defer database.Close() 优雅关闭

### 5. 中间件
- CORS(): 允许 *，支持 OPTIONS 预检，返回 204
- Logging(): 使用 slog 记录请求（method, path, status, latency, client_ip, user_agent）
- AuthMiddleware(): 从 Header 读取 X-Admin-Key 认证

### 6. 优雅关闭
- signal.Notify 监听 SIGINT/SIGTERM
- 关闭顺序：server stop → database.Close()

### 7. 项目结构
```
{{name}}/
├── main.go              # CLI、依赖注入、优雅关闭
├── go.mod
├── .env.example
├── middleware/
│   ├── cors.go
│   ├── logging.go
│   └── auth.go
├── handlers/            # HTTP 处理器层
├── internal/
│   ├── config/          # 配置管理
│   ├── database/        # SQLite 连接
│   ├── repository/      # 数据模型 + CRUD
│   └── services/        # 业务逻辑
└── ui/                  # 前端静态资源（可选）
```

### 8. 分层依赖
- Handler → Service → Repository → database.Engine
- 单向依赖，禁止跨层调用

参考模板的代码风格和结构，确保一致性。
