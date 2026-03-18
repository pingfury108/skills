package database

import (
	"log/slog"
	"os"

	_ "modernc.org/sqlite"
	"xorm.io/xorm"
)

// Engine 全局数据库引擎
var Engine *xorm.Engine

// Init 初始化数据库连接
func Init(dbPath string, debug bool) error {
	var err error
	Engine, err = xorm.NewEngine("sqlite", dbPath)
	if err != nil {
		return err
	}

	if err = Engine.Ping(); err != nil {
		return err
	}

	if debug {
		Engine.ShowSQL(true)
	}

	slog.Info("Database initialized", "path", dbPath)
	return nil
}

// SyncModels 同步数据库表结构
func SyncModels(models ...interface{}) error {
	return Engine.Sync2(models...)
}

// Close 关闭数据库连接
func Close() error {
	if Engine != nil {
		return Engine.Close()
	}
	return nil
}

// RemoveDB 删除数据库文件（测试用）
func RemoveDB(dbPath string) error {
	if _, err := os.Stat(dbPath); err == nil {
		return os.Remove(dbPath)
	}
	return nil
}
