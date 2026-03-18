package main

import (
	"embed"
	"fmt"
	"io/fs"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/urfave/cli/v2"

	"{{module}}/handlers"
	"{{module}}/internal/database"
	"{{module}}/internal/repository"
	"{{module}}/internal/services"
	"{{module}}/middleware"
)

//go:embed ui/dist/*
var uiFS embed.FS

func main() {
	if err := godotenv.Load(); err != nil {
		slog.Debug("No .env file found, using environment variables")
	}

	app := &cli.App{
		Name:  "{{name}}",
		Usage: "{{name}} service",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "host",
				Usage:   "Server host",
				Value:   "0.0.0.0",
				EnvVars: []string{"HOST"},
			},
			&cli.IntFlag{
				Name:    "port",
				Usage:   "Server port",
				Value:   8080,
				EnvVars: []string{"PORT"},
			},
			&cli.StringFlag{
				Name:     "admin-key",
				Usage:    "Admin authentication key",
				EnvVars:  []string{"ADMIN_KEY"},
				Required: true,
			},
			&cli.StringFlag{
				Name:    "db",
				Usage:   "SQLite database path",
				Value:   "{{name}}.db",
				EnvVars: []string{"DB_PATH"},
			},
			&cli.BoolFlag{
				Name:    "debug",
				Usage:   "Enable debug mode",
				Value:   false,
				EnvVars: []string{"DEBUG"},
			},
			&cli.StringFlag{
				Name:    "log-level",
				Usage:   "Log level (debug, info, warn, error)",
				Value:   "info",
				EnvVars: []string{"LOG_LEVEL"},
			},
		},
		Action: runServer,
	}

	if err := app.Run(os.Args); err != nil {
		slog.Error("Failed to start server", "error", err)
		os.Exit(1)
	}
}

func runServer(c *cli.Context) error {
	// 配置日志
	logLevel := c.String("log-level")
	level := slog.LevelInfo
	switch logLevel {
	case "debug":
		level = slog.LevelDebug
	case "warn":
		level = slog.LevelWarn
	case "error":
		level = slog.LevelError
	}
	opts := &slog.HandlerOptions{Level: level}
	logger := slog.New(slog.NewTextHandler(os.Stdout, opts))
	slog.SetDefault(logger)

	// 配置 Gin
	debug := c.Bool("debug")
	if !debug {
		gin.SetMode(gin.ReleaseMode)
		gin.DefaultWriter = os.Stdout
		gin.DisableConsoleColor()
	}

	// 初始化数据库
	dbPath := c.String("db")
	if err := database.Init(dbPath, debug); err != nil {
		slog.Error("Failed to initialize database", "error", err)
		return err
	}
	defer database.Close()

	// 同步数据库表结构
	if err := database.SyncModels(new(repository.Example)); err != nil {
		slog.Error("Failed to sync database models", "error", err)
		return err
	}

	// 依赖注入
	adminKey := c.String("admin-key")
	authService := services.NewAuthService(adminKey)
	exampleService := services.NewExampleService()

	authHandler := handlers.NewAuthHandler(authService)
	exampleHandler := handlers.NewExampleHandler(exampleService)

	// 设置路由
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(middleware.CORS())
	r.Use(middleware.Logging())

	api := r.Group("/api")
	{
		api.POST("/auth/validate", authHandler.Validate)

		examples := api.Group("/examples")
		examples.Use(middleware.AuthMiddleware(authService))
		{
			examples.GET("", exampleHandler.GetList)
			examples.POST("", exampleHandler.Create)
			examples.GET("/:id", exampleHandler.Get)
			examples.PUT("/:id", exampleHandler.Update)
			examples.DELETE("/:id", exampleHandler.Delete)
		}
	}

	// 静态文件服务
	uiDistFS, err := fs.Sub(uiFS, "ui/dist")
	if err != nil {
		return err
	}
	fileServer := http.FileServer(http.FS(uiDistFS))
	r.GET("/", func(c *gin.Context) {
		c.Header("Content-Type", "text/html; charset=utf-8")
		data, err := uiFS.ReadFile("ui/dist/index.html")
		if err != nil {
			c.String(http.StatusInternalServerError, "Error loading index.html")
			return
		}
		c.Data(http.StatusOK, "text/html; charset=utf-8", data)
	})
	r.NoRoute(gin.WrapH(fileServer))

	// 启动服务
	host := c.String("host")
	port := c.Int("port")
	addr := fmt.Sprintf("%s:%d", host, port)
	slog.Info("Starting server", "addr", addr, "debug", debug, "db", dbPath)

	go func() {
		if err := r.Run(addr); err != nil {
			slog.Error("Server error", "error", err)
		}
	}()

	// 优雅关闭
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("Shutting down server")
	return nil
}
