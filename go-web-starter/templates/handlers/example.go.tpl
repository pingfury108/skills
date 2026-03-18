package handlers

import (
	"log/slog"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"{{module}}/internal/services"
)

// ExampleHandler 示例处理器
type ExampleHandler struct {
	service *services.ExampleService
}

// NewExampleHandler 创建处理器
func NewExampleHandler(service *services.ExampleService) *ExampleHandler {
	return &ExampleHandler{service: service}
}

// CreateExampleRequest 创建请求
type CreateExampleRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
}

// UpdateExampleRequest 更新请求
type UpdateExampleRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Status      string `json:"status" binding:"required"`
}

// Create 创建
func (h *ExampleHandler) Create(c *gin.Context) {
	var req CreateExampleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		slog.Warn("Invalid request", "error", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	example, err := h.service.Create(req.Name, req.Description)
	if err != nil {
		slog.Error("Failed to create", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create"})
		return
	}

	c.JSON(http.StatusCreated, example)
}

// GetList 获取列表
func (h *ExampleHandler) GetList(c *gin.Context) {
	search := c.DefaultQuery("search", "")
	status := c.DefaultQuery("status", "")

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))

	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	examples, total, err := h.service.GetList(search, status, page, pageSize)
	if err != nil {
		slog.Error("Failed to get list", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get list"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"data":      examples,
		"total":     total,
		"page":      page,
		"page_size": pageSize,
	})
}

// Get 获取单个
func (h *ExampleHandler) Get(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	example, err := h.service.GetByID(id)
	if err != nil {
		slog.Error("Failed to get", "error", err)
		c.JSON(http.StatusNotFound, gin.H{"error": "Not found"})
		return
	}

	c.JSON(http.StatusOK, example)
}

// Update 更新
func (h *ExampleHandler) Update(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var req UpdateExampleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		slog.Warn("Invalid request", "error", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := h.service.Update(id, req.Name, req.Description, req.Status); err != nil {
		slog.Error("Failed to update", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Updated"})
}

// Delete 删除
func (h *ExampleHandler) Delete(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	if err := h.service.Delete(id); err != nil {
		slog.Error("Failed to delete", "error", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Deleted"})
}
