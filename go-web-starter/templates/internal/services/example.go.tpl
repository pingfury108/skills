package services

import (
	"errors"
	"log/slog"

	"{{module}}/internal/repository"
)

// ExampleService 示例业务服务
type ExampleService struct{}

// NewExampleService 创建服务实例
func NewExampleService() *ExampleService {
	return &ExampleService{}
}

// Create 创建示例
func (s *ExampleService) Create(name, description string) (*repository.Example, error) {
	example := &repository.Example{
		Name:        name,
		Description: description,
		Status:      "active",
	}

	if err := repository.CreateExample(example); err != nil {
		return nil, err
	}

	slog.Info("Example created", "id", example.ID)
	return example, nil
}

// GetByID 根据 ID 获取
func (s *ExampleService) GetByID(id int) (*repository.Example, error) {
	return repository.GetExampleByID(id)
}

// GetList 分页获取列表
func (s *ExampleService) GetList(search, status string, page, pageSize int) ([]*repository.Example, int64, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	filter := &repository.ExampleFilter{
		Search: search,
		Status: status,
		Page:   page,
		Limit:  pageSize,
	}
	return repository.ListExamples(filter)
}

// Update 更新
func (s *ExampleService) Update(id int, name, description, status string) error {
	example, err := repository.GetExampleByID(id)
	if err != nil {
		return err
	}
	if example == nil {
		return errors.New("example not found")
	}

	example.Name = name
	example.Description = description
	example.Status = status

	return repository.UpdateExample(example)
}

// Delete 删除
func (s *ExampleService) Delete(id int) error {
	return repository.DeleteExample(id)
}
