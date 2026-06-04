# MG Maker Daily 文章格式规范

> 每篇文章必须严格遵循以下格式框架，保证一致性。

## 文章 HTML 结构（必须按此顺序）

### 1. 头部信息
```html
<span class="category-pill" style="color: #f59e0b;">🤖 机器人</span>
<div class="font-mono text-sm text-muted mt-3 mb-2">2026-06-04</div>
<div class="font-mono text-sm text-muted mb-4">文章整理：@MG豆豆 · 来源：AP News</div>
<h1>标题</h1>
<p class="text-muted text-lg leading-relaxed">摘要</p>
```

### 2. 视频（必须在文章正文前）
```html
<div class="mb-8">
    <div class="hand-drawn bg-white p-2">
        <iframe src="https://player.bilibili.com/player.html?bvid=XXX&page=1&high_quality=1&danmaku=0&autoplay=0"
            width="100%" height="400" frameborder="0" allowfullscreen style="border-radius: 4px; display: block;">
        </iframe>
    </div>
    <p class="text-sm text-muted mt-3 text-center">
        📺 视频：<a href="https://www.bilibili.com/video/XXX" target="_blank" class="external-link">视频标题 - 哔哩哔哩</a>
    </p>
    <div style="background: #fffbe6; border: 2px dashed #f59e0b; padding: 12px; margin-top: 12px; font-size: 0.9rem;">
        <strong>👀 看视频时注意这3个问题：</strong><br>
        ① 问题1<br>
        ② 问题2<br>
        ③ 问题3
    </div>
</div>
```

### 3. 正文段落（用 `<article class="article-content">` 包裹）

#### 前沿聚焦
```html
<h2>【🔍 前沿聚焦】</h2>
```
文章核心内容，2-3段，介绍新闻背景和关键事实。

#### 其他段落标题
用 `<h2>【emoji 标题】</h2>` 格式，如：
- `<h2>【🇨🇳 中国品牌为什么抢了风头？】</h2>`
- `<h2>【🏭 日本的强项：精致与可靠】</h2>`

### 4. 核心科技关键词（必须！不能只罗列关键词）
```html
<div class="keyword-box">
    <div class="keyword-title">🔑 核心科技关键词</div>
    <p><strong>关键词1 (English Term)</strong></p>
    <p>解释段落，用通俗易懂的语言解释这个概念，配合文章内容。</p>
    <p><strong>关键词2 (English Term)</strong></p>
    <p>解释段落。</p>
    <p><strong>关键词3 (English Term)</strong></p>
    <p>解释段落。</p>
</div>
```
**⚠️ 每个关键词必须有：1) 中英文标题 2) 通俗解释段落，不能只罗列！**

### 5. ICC 赛事思维预演（必须！）
```html
<h2>【💡 创科启发：ICC 赛事思维预演】</h2>
<ul>
    <li><strong>定义与调研：</strong>问题内容</li>
    <li><strong>创新与差异：</strong>问题内容</li>
    <li><strong>测试与迭代：</strong>问题内容</li>
</ul>
```
**⚠️ 必须包含三个维度：定义与调研 / 创新与差异 / 测试与迭代**

### 6. 思考问题（必须！）
```html
<div class="question-box">
    <div class="question-title">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
        💬 留给你的问题：科技向善
    </div>
    <p>问题内容</p>
</div>
```
**⚠️ 标题格式固定为 "💬 留给你的问题：科技向善"**

### 7. 原文出处
```html
<div class="mt-8 pt-6 border-t-2 border-ink/10">
    <div class="font-mono text-xs text-muted mb-2">原文出处</div>
    <a href="URL" target="_blank" class="text-ink hover:text-accent transition-colors font-medium block mb-1">英文标题 →</a>
    <div class="text-sm text-muted">中文标题</div>
    <div class="font-mono text-xs text-muted mt-2">来源</div>
</div>
```

## 首页 index.html 更新清单

1. 更新日期戳 `<div class="date-stamp">2026.06.04</div>`
2. 更新 Daily Summary（指向新文章链接+热点摘要）
3. 在 `cardsContainer` 顶部插入新文章卡片
4. 新文章卡片包含：分类标签、日期、作者、标题、摘要、思考问题、视频按钮

## 自动发布 Cron 任务检查项

- [ ] 文章HTML格式符合以上规范
- [ ] 关键词框：每个关键词有标题+解释（非罗列）
- [ ] ICC三维度问题完整
- [ ] 视频带3个引导问题
- [ ] 思考问题标题为"💬 留给你的问题：科技向善"
- [ ] 原文出处信息完整
- [ ] 首页日期/Summary/卡片已更新
- [ ] git push 部署完成
