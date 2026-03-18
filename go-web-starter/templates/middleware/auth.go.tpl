package middleware

import (
	"log/slog"
	"net/http"

	"github.com/gin-gonic/gin"
	"{{module}}/internal/services"
)

// AuthMiddleware 管理员认证中间件
func AuthMiddleware(authService *services.AuthService) gin.HandlerFunc {
	return func(c *gin.Context) {
		adminKey := c.GetHeader("X-Admin-Key")

		if !authService.ValidateAdminKey(adminKey) {
			slog.Warn("Unauthorized access attempt", "path", c.Request.URL.Path)
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
			c.Abort()
			return
		}

		c.Next()
	}
}
