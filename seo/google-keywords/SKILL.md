---
name: google-keywords
description: |
  Google SEO 关键词与搜索意图总入口。当需要做关键词研究、规划内容选题、分析搜索意图、制定关键词地图时使用。
  触发信号："关键词研究"、"用户会搜什么词"、"关键词怎么布局"、"搜索意图分析"、"内容选题规划"、"关键词地图"。
  本 skill 是路由器：先走 6 步执行法，再按需进入 7 个原子技能。
tags: [seo, google, keywords, search-intent]
related_skills:
  - slug: google-keyword-business-context
    relation: routes-to
  - slug: google-keyword-seeds
    relation: routes-to
  - slug: google-keyword-expansion
    relation: routes-to
  - slug: google-keyword-intent
    relation: routes-to
  - slug: google-keyword-scoring
    relation: routes-to
  - slug: google-keyword-mapping
    relation: routes-to
  - slug: google-keyword-map-output
    relation: routes-to
  - slug: google-index
    relation: composes-with
---

# Google 关键词与意图

## 核心心智模型

> 用用户真正会搜的话，找到他们真正想要的东西，然后安排到对应页面。

不是"堆关键词"，而是三件事：**找词 → 判意图 → 做映射**。

## 6 步执行法

1. 业务定位：写清产品、用户、地区、竞品（→ google-keyword-business-context）
2. 列种子词：产品/痛点/场景/地区/竞品词（→ google-keyword-seeds）
3. 扩展关键词：下拉框/相关搜索/PAA/GSC/竞品/AI（→ google-keyword-expansion）
4. 判断意图：信息/导航/商业调查/交易/本地（→ google-keyword-intent）
5. 筛选评分：相关性/搜索量/竞争度/商业价值 → P0-P3（→ google-keyword-scoring）
6. 分组映射：一页一主词，输出关键词地图（→ google-keyword-mapping → google-keyword-map-output）

## AI 协作原则

- **AI 擅长**：扩展、分类、整理、生成大纲
- **AI 不擅长**：给准确搜索量——必须用 Google Keyword Planner、GSC、Ahrefs、5118 验证
- 让 AI 干活的公式：**给背景 + 给种子词 + 要求分类意图 + 要求输出表格 + 要求不编造搜索量**

## 关键词研究 Prompt 模板

```text
你是 SEO 关键词研究专家。请帮我做关键词与搜索意图分析。

【业务背景】
- 网站/产品：
- 目标用户：
- 地区/语言：
- 核心服务/产品：
- 竞品：
- 种子词：
- 已有页面：

【任务】
1. 围绕种子词扩展关键词，覆盖：
   - 信息型：是什么、为什么、怎么做、教程、指南
   - 商业调查型：推荐、最佳、对比、评测、排名
   - 交易型：购买、价格、预约、优惠、下载
   - 本地型：附近、城市+服务、地址、电话
   - 导航型：品牌名、官网、登录
2. 每个关键词标注：
   - 搜索意图
   - 用户真正想解决的问题
   - 商业价值：高/中/低
   - 竞争难度：高/中/低（不确定就写"需验证"）
   - 建议优先级：P0/P1/P2/P3
   - 建议页面：首页/栏目页/详情页/博客页
3. 按主题分组，每组给出：建议页面标题、H1、内容大纲
4. 输出 Markdown 表格：
   关键词 | 意图 | 用户想要什么 | 商业价值 | 竞争难度 | 优先级 | 建议页面 | 建议标题
5. 不要编造搜索量；无法确定时标注"需用工具验证"
6. 最后列出"优先做的前 10 个关键词"和理由
```

## 输出示例

| 关键词 | 意图 | 商业价值 | 优先级 | 建议页面 | 建议标题 |
|---|---|---|---|---|---|
| 西安高新区安静咖啡店 | 本地交易 | 高 | P0 | 区域落地页 | 西安高新区安静咖啡店推荐 |
| 西安咖啡店推荐 | 商业调查 | 中 | P1 | 推荐列表页 | 西安咖啡店推荐排行榜 |
| 手冲咖啡怎么做 | 信息型 | 低 | P3 | 博客教程 | 手冲咖啡新手教程 |

## 小白避坑

1. AI 给的关键词要验证：搜索量、竞争度必须用工具查
2. 不要只看大词：大词难做，长尾词更容易出效果
3. 意图比搜索量更重要：搜索量高但意图不对，转化差
4. 一个页面一个主词：不要所有词都堆首页（关键词蚕食）
5. 先做 P0/P1：高相关、高商业价值的词优先
