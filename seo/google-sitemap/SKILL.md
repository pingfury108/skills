---
name: google-sitemap
description: |
  制作并提交 sitemap（P1）。当新站/子域名/新栏目需要让 Google 发现页面，或 GSC 站点地图报告报错时使用。
  触发信号："提交 sitemap"、"sitemap 无法读取"、"子域名 sitemap"、"已发现未编入索引"。
tags: [seo, google, sitemap, gsc]
---

# Sitemap 提交

## 做什么

1. 生成 `sitemap.xml`：只放**返回 200、可索引、canonical 指向自身**的 URL。
2. 每个**子域名单独做 sitemap**（放各自域名下，如 `sub.example.com/sitemap.xml`）。
3. GSC →「站点地图」→ 提交 sitemap URL。
4. 填写准确的 `lastmod`（内容真实修改时间）。

## 合格标准

- GSC 站点地图报告：状态「成功」，已发现网址数符合预期。
- `lastmod` 与实际修改一致，不虚报。
- 超过 5 万 URL 时用 sitemap index 拆分。

## 常见坑

- **只提交主域名 sitemap，子域名没提交**——子域名页面发现极慢。
- sitemap 里混入 404、被 noindex、canonical 指向别处的 URL，拉低整体信任度。
- `lastmod` 全填当天，Google 会忽略该字段。
- sitemap 提交了但内链为零——sitemap 是辅助，内链才是主要发现渠道（→ google-internal-links）。

## 最小模板

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://sub.example.com/page-a</loc>
    <lastmod>2025-01-15</lastmod>
  </url>
</urlset>
```
