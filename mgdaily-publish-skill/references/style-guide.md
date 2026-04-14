# MG Maker Daily 样式规范

## 颜色规范

| 用途 | 色值 | CSS变量/类 | 说明 |
|------|------|-----------|------|
| 主背景 | `#fafaf8` | `bg-paper` | 米白色纸张质感 |
| 主文字 | `#1a1a1a` | `text-ink` | 深黑色墨水 |
| 强调色 | `#ff6b35` | `text-accent` / `bg-accent` | 橙色，按钮/链接/标签 |
| 次要文字 | `#6b6b6b` | `text-muted` | 灰色，日期/作者 |
| 机器人分类 | `#f59e0b` | `text-robot` | 琥珀色 |
| AI分类 | `#8b5cf6` | inline style | 紫色 |
| 航天分类 | `#3b82f6` | inline style | 蓝色 |
| 智能硬件分类 | `#10b981` | inline style | 绿色 |
| 视频链接 | `#ff3b30` | `.video-link` | 红色 |

## 字体规范

| 用途 | 字体族 | Tailwind类 |
|------|--------|-----------|
| 标题 | Space Grotesk + Noto Sans SC | `font-display` |
| 正文 | Inter + Noto Sans SC | `font-body` |
| 等宽(日期/按钮/标签) | Courier Prime | `font-mono` |

Google Fonts 加载:
```html
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=Inter:wght@400;500&family=Courier+Prime&family=Noto+Sans+SC:wght@400;500;700&display=swap" rel="stylesheet">
```

## 组件样式

### 手绘边框卡片 `.hand-drawn`
```css
border: 2px solid #1a1a1a;
box-shadow: 3px 3px 0 #1a1a1a;
transition: all 0.15s ease;
/* hover */
transform: translate(-1px, -1px);
box-shadow: 4px 4px 0 #1a1a1a;
```

### 分类标签 `.category-pill`
```css
border: 1.5px solid currentColor;
padding: 2px 10px;
font-family: 'Courier Prime', monospace;
font-size: 0.75rem;
text-transform: uppercase;
letter-spacing: 0.05em;
display: inline-block;
```

### 日期戳 `.date-stamp`
```css
font-family: 'Courier Prime', monospace;
border: 2px solid #1a1a1a;
padding: 8px 16px;
display: inline-block;
transform: rotate(-2deg);
background: #fff;
```

### 导航按钮 `.nav-pill`
```css
border: 2px solid #1a1a1a;
background: #fff;
padding: 8px 16px;
font-family: 'Courier Prime', monospace;
font-size: 0.85rem;
/* active / hover */
background: #1a1a1a;
color: #fff;
```

### 思考问题框 `.thinking-box` (首页卡片内)
```css
border-left: 3px solid #ff6b35;
background: linear-gradient(135deg, rgba(255, 107, 53, 0.05) 0%, rgba(255, 107, 53, 0.02) 100%);
padding: 14px 18px;
margin-top: 14px;
```

### 关键词框 `.keyword-box` (文章详情页)
```css
background: #fff;
border: 2px solid #1a1a1a;
padding: 1.5rem;
margin: 1.5rem 0;
box-shadow: 3px 3px 0 #1a1a1a;
```

### 科技向善问题框 `.question-box` (文章详情页)
```css
background: linear-gradient(135deg, rgba(255, 107, 53, 0.1) 0%, rgba(255, 107, 53, 0.05) 100%);
border: 2px solid #ff6b35;
padding: 1.5rem;
margin: 1.5rem 0;
```

## 文章详情页导航栏规范

**只保留返回首页按钮，不要添加任何分类标签**:
```html
<nav class="border-b-2 border-ink sticky top-0 bg-paper z-50">
    <div class="w-full px-6 py-4">
        <a href="index.html" class="nav-pill">← 返回首页</a>
    </div>
</nav>
```

## 首页筛选动画

首页卡片切换使用渐隐/渐现 + 平滑位移动画:
- 隐藏: opacity 0 → max-height 0 (0.35s + 0.45s)
- 显示: max-height 恢复 → opacity 1
- 容器使用 minHeight 锁定防止页码/footer跳动
