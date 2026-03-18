---
name: wails-icon
description: This skill should be used when the user asks to "process Wails icon", "convert image to ICO", "create app icon for Wails", "generate ICO file", "prepare desktop app icons", "crop image to square with rounded corners", or needs to prepare application icons for Wails desktop applications with multiple sizes.
version: 1.0.0
---

# Wails Icon

处理 Wails 应用图标，支持裁剪、圆角和格式转换。

## 使用场景

当用户需要处理 Wails 项目的应用图标时：
- 裁剪图片为正方形
- 添加圆角效果
- 生成 Windows ICO 文件
- 生成 macOS icns 文件

## 参数

- `input-image`: 输入图片路径（必需）
- `project-path`: Wails 项目目录路径（可选，默认为当前目录）

## 工作流程

1. 读取输入图片
2. 裁剪为正方形（以中心为基准）
3. 添加圆角遮罩
4. 生成多尺寸 ICO 文件（16x16, 32x32, 48x48, 128x128, 256x256）
5. 保存到 Wails 项目的 build 目录

## 依赖工具

- ImageMagick 或类似图片处理工具
- ico 转换工具
