# Wails Icon Skill

处理 Wails 应用的图标：裁剪为正方形、缩放至 1024x1024、添加 macOS 圆角、生成多平台图标。

## 用法

```
skill: wails-icon <input-image> [project-path]
```

## 参数

- `input-image`: 输入图片路径（支持任意尺寸）
- `project-path`: Wails 项目路径（可选，默认为当前目录）

## 输出

| 文件 | 规格 | 用途 |
|------|------|------|
| `build/appicon.png` | 1024x1024, 圆角, 透明背景 | macOS Dock/App/App Store |
| `build/windows/icon.ico` | 256/128/64/48/32/16 | Windows 图标 |

> **注意**: 1024x1024 是 macOS App Store 提交的必要尺寸。

## 依赖

- ImageMagick (`magick` 命令)

```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick
```

## 示例

```bash
# 处理当前目录的图标
skill: wails-icon ~/Downloads/my-logo.png

# 指定项目路径
skill: wails-icon ~/Downloads/my-logo.png ~/projects/my-wails-app
```
