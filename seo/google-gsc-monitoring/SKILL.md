---
name: google-gsc-monitoring
description: |
  GSC 四大报告监控（P3）。当需要定位未索引原因、跟踪收录趋势、发现抓取异常时使用。
  触发信号："GSC 报告怎么看"、"页面索引报告"、"为什么还没收录"、"覆盖率报告"。
  这是诊断中枢：任何索引问题先来这里拿证据，再路由到具体修复技能。
tags: [seo, google, gsc, monitoring]
---

# GSC 监控

## 前置：资源类型选择

| 类型 | 添加方式 | 覆盖范围 |
|---|---|---|
| **网域资源（推荐）** | 添加 `example.com`，DNS TXT 验证 | 所有子域名 + http/https，加一次全覆盖 |
| 网址前缀资源 | 添加 `https://sub.example.com`，文件/meta 验证 | 仅该精确前缀，子域名需逐个添加 |

决策建议：
- 首选网域资源（`pingfury.top` → 自动含 me./fenshen. 等所有子域名）
- 重要子域名可**额外**加网址前缀资源：sitemap 提交、报告筛选更聚焦，且「请求编入索引」配额按资源独立计算

## 做什么

定期查看四个报告：

| 报告 | 看什么 |
|---|---|
| 网址检查 | 单个 URL 的抓取/索引状态、Google 选择的规范网址、引荐页面 |
| 页面索引 | 全站收录趋势、未索引原因分类（noindex / 已抓取未索引 / 重复等） |
| 站点地图 | sitemap 提交状态、已发现网址数 |
| 链接 | 外链数量、引荐网站、内链分布 |

## 合格标准

- **每个未索引页面都有明确原因**，而不是"不知道为什么"。
- 未索引原因按类别归档，对应到具体修复技能。
- 每周至少看一次页面索引趋势。

## 常见坑

- **提交完就不管了**——不监控就不知道问题出在哪一环。
- 只看总数不看原因分类，无法针对性修复。
- 把"已发现 - 尚未编入索引"和"已抓取 - 尚未编入索引"混为一谈：
  - 已发现未索引 → 抓取配额/内链问题（→ google-internal-links）
  - 已抓取未索引 → 内容质量问题（→ google-content-value）
- GSC 数据有 2–3 天延迟，别拿今天的数据下结论。

## 常见未索引原因 → 路由表

| GSC 提示 | 路由到 |
|---|---|
| 被 robots.txt 屏蔽 | google-crawlability |
| 被 noindex 排除 | google-index-directives |
| 网页重定向 / 404 | google-http-status |
| 重复网页，Google 选择了不同规范 | google-canonical |
| 已发现 - 尚未编入索引 | google-internal-links |
| 已抓取 - 尚未编入索引 | google-content-value |
