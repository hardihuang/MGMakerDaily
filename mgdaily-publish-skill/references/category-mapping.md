# MG Maker Daily 分类映射表

## 完整映射

| 分类名 | data-category/filter | emoji | 卡片 pill HTML | tailwind颜色配置 | 详情页 pill HTML |
|--------|---------------------|-------|--------------|---------------|----------------|
| 机器人 | `机器人` | `🤖` | `<span class="category-pill text-robot">🤖 机器人</span>` | `'robot': '#f59e0b'` | 同左 |
| AI | `AI` | `🧠` | `<span class="category-pill" style="color: #8b5cf6;">🧠 AI</span>` | `'ai': '#8b5cf6'` | 同左 |
| 航天 | `航天` | `🚀` | `<span class="category-pill" style="color: #3b82f6;">🚀 航天</span>` | `'space': '#3b82f6'` | 同左 |
| 智能硬件 | `智能硬件` | `🔧` | `<span class="category-pill" style="color: #10b981;">🔧 智能硬件</span>` | `'hardware': '#10b981'` | 同左 |
| OpenClaw | `OpenClaw` | `🦞` | `<span class="category-pill text-accent">🦞 OpenClaw</span>` | 使用 accent (#ff6b35) | 同左 |
| 编程 | `编程` | `💻` | `<span class="category-pill" style="color: #6366f1;">💻 编程</span>` | `'code': '#6366f1'` | 同左 |
| 生物 | `生物` | `🧬` | `<span class="category-pill" style="color: #22c55e;">🧬 生物</span>` | `'bio': '#22c55e'` | 同左 |
| 新能源 | `新能源` | `⚡` | `<span class="category-pill" style="color: #eab308;">⚡ 新能源</span>` | `'energy': '#eab308'` | 同左 |

## 导航栏按钮格式

```html
<button class="nav-pill" data-filter="{{分类名}}">{{emoji}} {{分类名}}</button>
```

示例:
```html
<button class="nav-pill active" data-filter="all">📋 全部</button>
<button class="nav-pill" data-filter="机器人">🤖 机器人</button>
<button class="nav-pill" data-filter="AI">🧠 AI</button>
<button class="nav-pill" data-filter="航天">🚀 航天</button>
<button class="nav-pill" data-filter="智能硬件">🔧 智能硬件</button>
<button class="nav-pill" data-filter="OpenClaw">🦞 OpenClaw</button>
```

## 重要规则

1. `data-category` (卡片上) 和 `data-filter` (按钮上) 的值必须**完全一致**，否则筛选不工作
2. 新增分类时，必须同时:
   - 在 tailwind.config 的 colors 中添加新颜色
   - 在 nav-scroll 中添加新 button
   - 在卡片中使用对应 data-category
3. "全部" 按钮的 `data-filter="all"` 是特殊值，匹配所有卡片
4. 首次加载时 "全部" 按钮带 `active` class

## Tailwind Config 模板

文章详情页需要根据分类调整 tailwind.config 中的自定义颜色:

```javascript
tailwind.config = {
    theme: {
        extend: {
            fontFamily: {
                'display': ['Space Grotesk', 'Noto Sans SC', 'sans-serif'],
                'body': ['Inter', 'Noto Sans SC', 'sans-serif'],
                'mono': ['Courier Prime', 'monospace'],
            },
            colors: {
                'paper': '#fafaf8',
                'ink': '#1a1a1a',
                'accent': '#ff6b35',
                'muted': '#6b6b6b',
                // 根据文章分类添加对应颜色，例如:
                // 'robot': '#f59e0b',    // 机器人
                // 'ai': '#8b5cf6',       // AI
                // 'space': '#3b82f6',    // 航天
                // 'hardware': '#10b981', // 智能硬件
            }
        }
    }
}
```
