---
name: google-url-structure
description: |
  URL 结构优化（P2）。当站点 URL 混乱、参数超长、层级无逻辑影响抓取和收录时使用。
  触发信号："url 太长"、"url 结构规划"、"参数 url 不收录"、"目录结构怎么设计"。
tags: [seo, google, url, architecture]
---

# 网址结构

## 做什么

1. URL 保持**逻辑清晰、可读**：`/category/topic/page` 体现主题分组。
2. 参数尽量简短，非必要参数不进 URL（跟踪参数用 `#` 或排除）。
3. 同主题内容归入同一目录/子域名，形成主题簇。

## 合格标准

- URL 可读：人能大致猜出页面内容。
- 层级合理：重要页面距首页 ≤ 3 次点击。
- 参数少且固定顺序；同一内容只有一个 URL 版本。

## 常见坑

- **超长参数、会话 ID 进 URL**：`?sid=a3f9...&utm=...`，产生无限 URL 空间浪费抓取配额。
- 混乱目录：同一主题散落在 `/a/`、`/b/`、根目录各处。
- 频繁改 URL 结构而不做 301（→ google-http-status）。
- 大小写、尾斜杠混用产生重复 URL（配合 google-canonical 处理）。

## 反例与正例

```
差: /p?id=12345&cat=9&ref=xx
好: /seo/google-indexing-guide
```
