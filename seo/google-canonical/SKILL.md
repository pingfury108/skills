---
name: google-canonical
description: |
  Canonical 标签管理（P1）。当页面被判定"重复内容"、子域名被主域名吞并收录、或 GSC 显示"Google 选择的规范网址与用户不同"时使用。
  触发信号："canonical 指向错误"、"重复网页"、"google 选择的规范网址"、"子域名被忽略"。
tags: [seo, google, canonical, duplicate]
---

# Canonical 自引用

## 做什么

1. 每个可索引页面加：`<link rel="canonical" href="当前页面自身URL">`。
2. GSC 网址检查 → 查看「Google 选择的规范网址」，确认与预期一致。
3. 多参数/多版本页面（http/https、带不带 www、跟踪参数）统一 canonical 到主版本。

## 合格标准

- canonical = 当前 URL（自引用）。
- GSC 中「Google 选择的规范网址」与用户声明一致。
- 全站协议、域名、大小写、尾斜杠统一。

## 常见坑

- **子域名页面 canonical 错误指向主域名**——Google 会认为子域名页是副本，直接忽略子域名。
- canonical 指向 404 或被 noindex 的页面。
- canonical 与 sitemap、内链指向的 URL 版本不一致（三方信号打架，Google 自行选择）。
- 分页页 canonical 全部指向第一页（错误用法，分页应自引用）。

## 验证

```bash
curl -s https://sub.example.com/page | grep -i 'rel="canonical"'
```
