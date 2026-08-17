---
name: x-download
description: |
  下载 X/Twitter 推文中的图片和视频。当用户给出 x.com / twitter.com / t.co 链接想保存媒体，
  或说"下载推特视频"、"保存 X 上的图片"、"twitter 视频下载"时使用。
  不适用：批量爬取账号内容、抓取纯文本推文、需要绕过付费/关注限制的内容。
tags: [twitter, x, download, video, image, yt-dlp]
---

# X/Twitter 媒体下载

使用 `yt-dlp` 下载推文媒体。

## 工具准备

1. 检查 `yt-dlp`：`command -v yt-dlp`
2. 未安装时优先用 uv 安装：`uv tool install yt-dlp`
3. **uv 也未安装时先装 uv**：`curl -LsSf https://astral.sh/uv/install.sh | sh`，再回到第 2 步
4. 已安装但版本较旧（超过一个月）时升级：`uv tool upgrade yt-dlp`
   （X 的接口经常变动，下载失败首先考虑升级 yt-dlp）

## 下载流程

1. **规范化 URL**
   - 支持 `x.com`、`twitter.com`、`mobile.twitter.com`，统一视为同一推文
   - 去掉 `?s=...&t=...` 等追踪参数
   - `t.co` 短链先用 `curl -sIL -o /dev/null -w '%{url_effective}' <url>` 展开

2. **执行下载**

```bash
# 默认最高画质，保存到当前目录
yt-dlp "https://x.com/username/status/1234567890"

# 指定输出目录和命名
yt-dlp -o "~/Downloads/x/%(uploader_id)s_%(id)s.%(ext)s" "<url>"

# 同时保存推文元数据（文案、时间等）
yt-dlp --write-info-json -o "~/Downloads/x/%(uploader_id)s_%(id)s.%(ext)s" "<url>"
```

3. **验证结果**
   - 确认输出文件存在且大小非 0
   - 视频可用 `ffprobe` 检查时长/编码是否正常
   - 多图/多视频推文应产出多个文件，数量与推文媒体数一致

## 失败排查

| 现象 | 原因 | 处理 |
|------|------|------|
| 提示需要登录 / 403 | 年龄限制或仅登录可见 | 加 `--cookies-from-browser chrome`（或 safari/firefox） |
| 解析失败、无格式 | yt-dlp 版本过旧 | `uv tool upgrade yt-dlp` 后重试 |
| 只下载到 1 张图但推文有多图 | yt-dlp 对多图支持有限 | 检查 `--write-info-json` 中的条目；必要时告知用户手动保存 |
| 403 / 频率限制 | IP 被限流 | 等待后重试，或换网络 |

## 注意

- 仅用于个人用途，尊重内容版权
