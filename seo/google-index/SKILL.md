---
name: google-index
description: |
  Google 索引总入口。当用户的网站/页面未被 Google 收录、收录慢、收录后消失，或想系统性提升 Google 索引率时使用。
  触发信号："google 不收录"、"页面没被索引"、"怎么让 google 收录"、"GSC 显示已发现未索引"、"subdomain 不收录"。
  本 skill 是路由器：先走最小 7 步快速排查，再按优先级路由到 P0/P1/P2/P3 子技能。
tags: [seo, google, indexing, gsc]
related_skills:
  - slug: google-crawlability
    relation: routes-to
  - slug: google-http-status
    relation: routes-to
  - slug: google-index-directives
    relation: routes-to
  - slug: google-sitemap
    relation: routes-to
  - slug: google-internal-links
    relation: routes-to
  - slug: google-request-indexing
    relation: routes-to
  - slug: google-mobile-first
    relation: routes-to
  - slug: google-canonical
    relation: routes-to
  - slug: google-content-value
    relation: routes-to
  - slug: google-backlinks
    relation: routes-to
  - slug: google-url-structure
    relation: routes-to
  - slug: google-gsc-monitoring
    relation: routes-to
  - slug: google-index-iteration
    relation: routes-to
---

# Google 索引技能树

## 核心心智模型

> 技术放行是入场券，内容、外链、移动端和规范是通行证，GSC 监控和耐心迭代是加速器。

索引因果链：**能被抓取 → 被发现 → 被判定值得索引 → 持续被保留**。
任何一环断裂，按优先级从 P0 开始排查，不要跳级。

## 最小可执行路径（7 步快速排查）

遇到"页面不收录"先按顺序走完这 7 步，80% 的问题在前 3 步：

1. GSC「测试实际网址」→ 看抓取是否允许（→ google-crawlability）
2. 修 robots.txt / noindex（→ google-index-directives）
3. 确认页面返回 200（→ google-http-status）
4. 提交（子域名）sitemap（→ google-sitemap）
5. 从已索引页面加内链指向目标页（→ google-internal-links）
6. GSC「请求编入索引」（→ google-request-indexing）
7. 持续更新内容 + 等抓取（→ google-index-iteration）

## 技能树路由

### P0 基础放行（不做一定不索引）
| 技能 | 解决什么 |
|---|---|
| google-crawlability | 可抓取性诊断：robots.txt、无痕测试、GSC 实测 |
| google-http-status | 状态码管理：200 / 301 / 修 404/500 |
| google-index-directives | 索引指令：meta robots、X-Robots-Tag、移动版 noindex |

### P1 发现与提交 + 移动与规范
| 技能 | 解决什么 |
|---|---|
| google-sitemap | sitemap 制作与 GSC 提交（含子域名） |
| google-internal-links | 内链发现：让爬虫顺着链接爬到新页 |
| google-request-indexing | GSC 请求编入索引（配额管理） |
| google-mobile-first | 移动优先：移动/桌面内容与指令一致性 |
| google-canonical | canonical 自引用，避免子域名被忽略 |

### P2 内容与权威
| 技能 | 解决什么 |
|---|---|
| google-content-value | 内容独特价值，避免与主域名/全网重复 |
| google-backlinks | 自然外链建设 |
| google-url-structure | URL 结构与主题分组 |

### P3 监控与迭代
| 技能 | 解决什么 |
|---|---|
| google-gsc-monitoring | GSC 四大报告监控，定位未索引原因 |
| google-index-iteration | 耐心迭代节奏与预期管理 |

## 自动化检查脚本

排查前先运行（覆盖 P0/P1 可自动化的 7 项，纯标准库无依赖）：

```bash
python3 <skill目录>/scripts/check_index.py https://目标页面URL
```

脚本每项输出 ✅/❌，失败项直接标注路由到哪个子 skill。GSC 相关步骤需手动完成（脚本末尾有清单）。

## 使用原则

- **按优先级排查**：P0 不通，P1/P2 做再多也无效。
- **子域名是独立站点**：robots.txt、sitemap、外链、GSC 资源都要单独处理。
- **每个未索引页都要有明确原因**：不知道原因就去 google-gsc-monitoring 查。
