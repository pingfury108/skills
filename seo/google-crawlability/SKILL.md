---
name: google-crawlability
description: |
  诊断 Google 是否能抓取页面（P0）。当页面不被收录、怀疑被 robots.txt 屏蔽、或子域名不抓时使用。
  触发信号："抓取被 robots.txt 屏蔽"、"googlebot 抓不到"、"测试实际网址"。
  不适用：页面能抓取但不索引（去 google-content-value 或 google-gsc-monitoring）。
tags: [seo, google, crawl, robots]
---

# 可抓取性诊断

## 做什么

1. 用**无痕窗口**打开目标页面，确认无登录墙、无地域拦截、能正常渲染。
2. GSC →「网址检查」→「**测试实际网址**」，看实时抓取结果。
3. 检查 robots.txt：`https://<host>/robots.txt`，确认没有整站 `Disallow: /`。

## 合格标准

- GSC 实测结果：「抓取允许 = 是」「网页抓取 = 成功」。
- robots.txt 无针对 Googlebot 的整站/整目录屏蔽。
- **子域名的 robots.txt 单独检查**——子域名不继承主域名规则。

## 常见坑

- 子域名 robots.txt 单独屏蔽了 Googlebot（主域名正常 ≠ 子域名正常）。
- 测试了缓存版本而非「实际网址」，看到过期结果。
- CDN/WAF（如 Cloudflare）按 UA 拦截了 Googlebot，无痕窗口看不出来，必须以 GSC 实测为准。

## 快速命令

```bash
curl -s https://sub.example.com/robots.txt
curl -s -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" -o /dev/null -w "%{http_code}" https://sub.example.com/page
```
