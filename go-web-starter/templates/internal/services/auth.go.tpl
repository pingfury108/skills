package services

import (
	"crypto/subtle"
)

// AuthService 认证服务
type AuthService struct {
	adminKey string
}

// NewAuthService 创建认证服务
func NewAuthService(adminKey string) *AuthService {
	return &AuthService{adminKey: adminKey}
}

// ValidateAdminKey 验证管理员密钥（常数时间比较防时序攻击）
func (s *AuthService) ValidateAdminKey(key string) bool {
	if s.adminKey == "" || key == "" {
		return false
	}
	return subtle.ConstantTimeCompare([]byte(s.adminKey), []byte(key)) == 1
}
