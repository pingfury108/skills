# {{name}}

基于 Go + Gin + SQLite 的 Web 服务。

## 技术栈

- **Web 框架**: [Gin](https://github.com/gin-gonic/gin)
- **ORM**: [XORM](https://xorm.io/)
- **数据库**: SQLite (modernc.org/sqlite)
- **CLI**: urfave/cli/v2
- **日志**: log/slog

## 项目结构

```
{{name}}/
├── main.go              # 入口、CLI、依赖注入
├── middleware/          # Gin 中间件
│   ├── cors.go          # 跨域
│   ├── logging.go       # 请求日志
│   └── auth.go          # 认证
├── handlers/            # HTTP 处理器
│   ├── auth.go
│   └── example.go
├── internal/
│   ├── services/        # 业务逻辑
│   ├── repository/      # 数据模型
│   └── database/        # 数据库连接
└── ui/dist/             # 前端静态文件
```

## 快速开始

### 1. 安装依赖

```bash
go mod download
```

### 2. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 设置 ADMIN_KEY
```

### 3. 运行

```bash
# 开发模式
go run . --admin-key=your-key --debug

# 或使用 .env
go run .
```

### 4. 访问

- API: http://localhost:8080/api
- UI: http://localhost:8080

## API 接口

### 认证

- `POST /api/auth/validate` - 验证密钥

### 示例资源（需认证）

- `GET /api/examples` - 列表
- `POST /api/examples` - 创建
- `GET /api/examples/:id` - 详情
- `PUT /api/examples/:id` - 更新
- `DELETE /api/examples/:id` - 删除

认证头: `X-Admin-Key: your-admin-key`

## 构建

```bash
go build -o {{name}}
```

## 命令行参数

```bash
./{{name}} --help

Flags:
   --host value      Server host (default: "0.0.0.0") [$HOST]
   --port value      Server port (default: 8080) [$PORT]
   --admin-key       Admin authentication key [$ADMIN_KEY]
   --db              SQLite database path (default: "{{name}}.db") [$DB_PATH]
   --debug           Enable debug mode [$DEBUG]
   --log-level       Log level (default: "info") [$LOG_LEVEL]
```

## 分层架构

```
HTTP Request
    ↓
Handlers (解析请求，返回响应)
    ↓
Services (业务逻辑)
    ↓
Repository (数据访问)
    ↓
Database (SQLite)
```

## 日志

使用结构化日志 slog，默认输出格式：

```
time=2026-03-18T10:00:00 level=INFO msg="HTTP request" method=GET path=/api/examples status=200 latency=2.5ms client_ip=127.0.0.1
```
