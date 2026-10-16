---
name: google-mobile-first
description: |
  移动优先索引适配（P1）。当桌面版收录但站点整体收录差、独立移动站（m.xxx.com）、或移动版内容被裁减时使用。
  触发信号："移动优先索引"、"移动版内容少"、"m. 域名不收录"、"smartphone googlebot"。
tags: [seo, google, mobile-first, rendering]
---

# 移动优先适配

## 做什么

1. 对比移动版与桌面版的：正文内容、内链、结构化数据、robots 标签、canonical。
2. GSC「测试实际网址」默认用 **Smartphone Googlebot**，以它的渲染结果为准。
3. 确认移动版无资源（CSS/JS/图片）被 robots.txt 屏蔽。

## 合格标准

- 移动版内容 = 桌面版内容（响应式设计天然满足）。
- 移动版 robots meta 无 noindex，与桌面版一致。
- 移动版可正常渲染：GSC 实测截图完整、无空白。

## 常见坑

- **移动版内容比桌面版少**（为"简洁"砍掉了正文/内链）——移动优先索引下，砍掉的内容等于不存在。
- 独立移动站 m.xxx.com 的 robots.txt 屏蔽了资源目录。
- 移动版用 JS 延迟加载核心内容，首抓渲染不出来。
- 弹窗/插页广告遮挡移动端首屏，影响可用性评估。

## 验证

```bash
# 模拟 Smartphone Googlebot 抓取
curl -s -A "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" https://example.com/page | wc -c
```
