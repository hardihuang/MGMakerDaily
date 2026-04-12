# MG Maker Daily - 每日创客科技

> 专为 MG 创客学习者打造的每日科技新闻推送平台

## 🎯 项目定位

MG Maker Daily 是一个面向创客教育学习者的每日科技新闻聚合平台，每天精选科技新闻，以"心性升级"的理念引导学习者独立思考。

## 🔄 自动化流程

```
OpenClaw定时任务(每天7点) → 搜索科技新闻 → 同步飞书多维表格 → 用户审核确认 → 整理HTML文章 → Push GitHub → GitHub Pages更新
```

### OpenClaw Skills

| Skill | 功能 | 触发词 |
|-------|------|--------|
| `daily-report-feishu` | 每日工作日报发送到飞书 | 日报、daily report |
| `publish-article` | 文章发布到网站 | 发布文章、publish article |

---

## ✨ 核心特色

### 1. 精选内容
- 覆盖 AI、硬件、航天、机器人等领域
- 聚焦对创客有启发的技术突破

### 2. 独立思考引导
每条新闻配有启发性问题，引导学习者：
- 思考技术背后的本质
- 联系自身实际场景
- 培养创新思维

### 3. 简洁设计
- 手绘风格卡片布局
- 分类标签筛选系统
- **自动分页（每页8篇）**
- 响应式设计，支持多端访问

---

## 📁 项目结构

```
MGMakerDaily/
├── github/                      # 网站源码（GitHub Pages）
│   ├── index.html               # 首页（含分页功能）
│   ├── article-*.html           # 文章页面（19篇）
│   ├── template-article.html    # 文章模板
│   ├── ARTICLE-CHECKLIST.md     # 整理检查清单
│   ├── publish-article.sh       # 发布脚本
│   └── cron-morning-news.sh     # 定时任务脚本
│
├── daily-report-feishu/         # OpenClaw日报Skill
│   ├── SKILL.md
│   └── scripts/daily-report.js
│
├── publish-article-skill/       # OpenClaw发布Skill
│   └── SKILL.md
│
└── .learnings/                  # 项目学习记录
```

---

## 📝 文章发布流程

详见 `publish-article-skill/SKILL.md` 和 `github/ARTICLE-CHECKLIST.md`

### 快速步骤

1. 从飞书表格获取审核通过的文章
2. 使用 `template-article.html` 生成HTML
3. 在 `index.html` 添加卡片（最前面）
4. Git commit & push

### 分页自动处理

首页分页由JavaScript自动处理：
- 每页显示8篇文章
- 新卡片自动进入第1页
- 分类筛选后分页联动
- 无需手动修改分页代码

---

## 🎨 配色方案

| 分类 | 颜色 | Emoji |
|------|------|-------|
| 机器人 | `#f59e0b` 琥珀色 | 🤖 |
| AI | `#8b5cf6` 紫色 | 🧠 |
| 航天 | `#3b82f6` 蓝色 | 🚀 |
| 智能硬件 | `#10b981` 绿色 | 🔧 |
| OpenClaw | `#ff6b35` 橙色 | 🦞 |
| AI创作 | `#ec4899` 粉色 | 🎬 |

---

## 🚀 本地预览

```bash
cd /Users/doudou/Documents/mgmakerdaily/github
open index.html
```

---

## 📄 许可证

MIT License

---

Made with 🦞 by OpenClaw + MG豆豆 for MG 创客学习者