---
name: google-index-directives
description: |
  管理索引指令（P0）：meta robots、X-Robots-Tag。当页面被抓取但标记"已排除 noindex"、或桌面版收录移动版不收时使用。
  触发信号："noindex 排除了"、"已抓取尚未编入索引"、"移动版不收录"。
tags: [seo, google, noindex, robots-meta]
---

# 索引指令管理

## 做什么

1. 检查页面 HTML 中的 `<meta name="robots" content="...">`。
2. 检查 HTTP 响应头中的 `X-Robots-Tag`。
3. **移动版和桌面版分别检查**（响应式站点查一次即可；独立移动站 m.xxx.com 必须单独查）。

## 合格标准

- 无 `noindex`、`none` 指令。
- 移动版与桌面版指令一致，都没有 noindex。
- 响应头无 `X-Robots-Tag: noindex`。

## 常见坑

- **桌面版正常，移动版被 noindex**——移动优先索引下，等于全站不索引。
- CMS/SEO 插件默认"劝阻搜索引擎"勾选（WordPress 常见）。
- 预发环境的 noindex 配置被带到生产。
- CDN/边缘规则注入了 X-Robots-Tag 头，HTML 里看不到。

## 快速命令

```bash
curl -s https://example.com/page | grep -i 'name="robots"'
curl -sI https://example.com/page | grep -i x-robots-tag
```

> 注意：如果页面被 robots.txt 屏蔽，Google 反而看不到 noindex 标签，页面可能以"仅 URL"形式被索引。两者不要同时用。
