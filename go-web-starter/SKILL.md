---
name: go-web-starter
description: This skill should be used when the user asks to "create a Go web project", "init Go web service", "bootstrap Gin project", "create Go API server", "setup Go backend with SQLite", or needs to set up a production-ready Go web application with Gin, SQLite, CLI flags, slog logging, and graceful shutdown.
version: 1.1.0
---

# Go Web Starter

创建一个生产级 Go Web 服务项目。

## 使用场景

当用户需要创建新的 Go Web 项目时，使用此 skill 生成标准化的项目结构。

## 必需参数

- `module`: Go module 路径，如 github.com/user/project
- `name`: 项目名称

## 可选参数

- `ui-type`: 前端类型，可选值：
  - `none`（默认）：纯 Go 后端，不含前端
  - `react`：集成 React + Vite + DaisyUI + TanStack Query 前端

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

#### ui-type=none（默认）
```
{{name}}/
├── main.go
├── go.mod
├── .env.example
├── middleware/
│   ├── cors.go
│   ├── logging.go
│   └── auth.go
├── handlers/
├── internal/
│   ├── database/
│   ├── repository/
│   └── services/
```

#### ui-type=react
```
{{name}}/
├── main.go              # 含 embed ui/dist
├── go.mod
├── .env.example
├── middleware/
├── handlers/
├── internal/
│   ├── database/
│   ├── repository/
│   └── services/
└── ui/                  # React 前端
    ├── package.json
    ├── vite.config.js
    ├── index.html
    └── src/
        ├── main.jsx
        ├── App.jsx
        ├── app.css
        ├── api.js
        └── pages/
            ├── Login.jsx
            └── Home.jsx
```

### 8. ui-type=react 时的前端规范
- 技术栈：React 19 + Vite 6 + Tailwind CSS v4 + DaisyUI v5 + TanStack Query v5 + React Router v7
- 包管理器：pnpm
- `app.css` 仅含：`@import "tailwindcss";` 和 `@plugin "daisyui";`
- `vite.config.js` 配置 `/api` 代理到后端端口
- `api.js` 封装带 X-Admin-Key header 的 fetch 工具函数
- `App.jsx` 包含路由、auth 校验逻辑（调用 /api/auth/validate）
- `Login.jsx` 使用 DaisyUI card/input/btn 组件
- `Home.jsx` 使用 useQuery 获取数据，使用 DaisyUI 展示

### 9. 分层依赖
- Handler → Service → Repository → database.Engine
- 单向依赖，禁止跨层调用

参考模板的代码风格和结构，确保一致性。
