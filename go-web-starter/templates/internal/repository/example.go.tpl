package repository

import (
	"time"

	"{{module}}/internal/database"
)

// Example 示例模型
type Example struct {
	ID          int       `xorm:"'id' pk autoincr"`
	Name        string    `xorm:"'name' notnull"`
	Description string    `xorm:"'description'"`
	Status      string    `xorm:"'status' default 'active'"`
	CreatedAt   time.Time `xorm:"'created_at' created"`
	UpdatedAt   time.Time `xorm:"'updated_at' updated"`
}

// TableName 指定表名
func (Example) TableName() string {
	return "examples"
}

// ExampleFilter 查询过滤器
type ExampleFilter struct {
	Search string
	Status string
	Page   int
	Limit  int
}

// Create 创建记录
func CreateExample(example *Example) error {
	_, err := database.Engine.Insert(example)
	return err
}

// GetByID 根据 ID 查询
func GetExampleByID(id int) (*Example, error) {
	example := &Example{}
	has, err := database.Engine.ID(id).Get(example)
	if err != nil {
		return nil, err
	}
	if !has {
		return nil, nil
	}
	return example, nil
}

// List 分页查询
func ListExamples(filter *ExampleFilter) ([]*Example, int64, error) {
	session := database.Engine.NewSession()
	defer session.Close()

	if filter.Search != "" {
		searchPattern := "%" + filter.Search + "%"
		session = session.Where("name LIKE ? OR description LIKE ?", searchPattern, searchPattern)
	}

	if filter.Status != "" {
		session = session.And("status = ?", filter.Status)
	}

	total, err := session.Count(&Example{})
	if err != nil {
		return nil, 0, err
	}

	if total == 0 {
		return []*Example{}, 0, nil
	}

	var examples []*Example
	err = session.Desc("created_at").Limit(filter.Limit, (filter.Page-1)*filter.Limit).Find(&examples)
	if err != nil {
		return nil, 0, err
	}

	return examples, total, nil
}

// Update 更新记录
func UpdateExample(example *Example) error {
	_, err := database.Engine.ID(example.ID).Update(example)
	return err
}

// Delete 删除记录
func DeleteExample(id int) error {
	_, err := database.Engine.ID(id).Delete(&Example{})
	return err
}
