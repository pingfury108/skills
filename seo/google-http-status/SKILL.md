---
name: google-http-status
description: |
  管理页面 HTTP 状态码（P0）。当页面返回非 200、旧链接迁移、整站 404/500 影响收录时使用。
  触发信号："404 太多"、"301 跳转"、"页面返回 500"、"抓取错误"。
tags: [seo, google, http-status, redirect]
---

# HTTP 状态码管理

## 做什么

1. 批量检查目标页面返回码。
2. 旧链接永久迁移 → 配置 **301** 指向对应新页面（一对一）。
3. 修掉 404（误删的恢复）和 500（服务端错误）。

## 合格标准

- 所有目标可索引页返回 `200`。
- 301 指向**内容对应**的新页面。
- 404/500 清零（或只剩确认废弃的页面）。

## 常见坑

- **整站旧链接 301 到首页**：Google 会判为 soft 404，权重不传递。必须一对一跳转。
- 用 302（临时）做永久迁移，权重传递不稳定。
- 链式跳转 A→B→C，应压平为 A→C。
- JS 跳转不算重定向，爬虫不跟随。

## 快速命令

```bash
curl -sI https://example.com/old-page | head -1
# 批量检查
while read u; do echo "$u $(curl -s -o /dev/null -w '%{http_code}' "$u")"; done < urls.txt
```
