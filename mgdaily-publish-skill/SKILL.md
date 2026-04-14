# MG Maker Daily - 每日发布 Skill

> **Skill ID**: `mgdaily-publish`
> **版本**: v2.2 (更新项目配置)
> **维护者**: hardihuang
> **适用平台**: OpenClaw Agent

---

## 项目配置信息

| 配置项 | 值 |
|--------|-----|
| GitHub仓库 | `https://github.com/hardihuang/MGMakerDaily` |
| 网站域名 | `https://mgdaily.mgspace.net/` |
| 飞书表格 | `https://sisy9sdzrms.feishu.cn/base/GpMvbgnQta9ISpsywtrca6lTnvb` |
| app_token | `GpMvbgnQta9ISpsywtrca6lTnvb` |
| table_id | `tbl5cLUFMdhl6b0U` |
| 本地仓库路径 | `/Users/doudou/Documents/mgmakerdaily/github` |

---

## 1. Skill 概述与适用场景

### 这个 Skill 做什么？

自动化完成 MG Maker Daily 网站的每日内容更新，包括：
- 根据飞书表格中"已通过"状态的文章，生成标准 HTML 文章详情页
- 更新首页 `index.html` 的文章卡片列表（最新置顶）
- 同步首页筛选标签（确保新分类自动出现）
- 更新首页日期戳和热点区块
- **分页系统自动处理（新增）**
- 提交 Git 并推送部署

### 什么时候触发？

- **定时触发**: 每天早上 7:00 检查飞书表格
- **手动触发**: 用户说"发布文章"或"更新网站"
- **飞书状态变更**: 文章状态从"待审核"→"已通过"时

### 前置条件

- 飞书表格中至少有 1 篇状态为"已通过"的文章
- 文章的所有必填字段已填写完整
- Git 仓库可推送（有 SSH key 或 token）

---

## 2. 分页系统说明（新增功能）

### 分页机制

首页采用 **JavaScript 动态分页**，无需手动维护分页代码：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| 每页文章数 | **8篇** | 移动端体验最佳 |
| 分页触发 | 自动 | 新卡片插入后分页自动重算 |
| 筛选联动 | 支持 | 分类筛选后分页自动更新 |
| URL参数 | 支持 | `?page=2&filter=机器人` |

### 分页工作原理

```
新增卡片插入 #cardsContainer 最前面
    ↓
JavaScript 自动计算总页数 = ceil(文章总数 / 8)
    ↓
新卡片自动进入第1页（显示最新8篇）
    ↓
原第1页末尾卡片移至第2页
    ↓
分页导航自动更新页码显示
```

### 重要规则

1. **卡片位置**：新卡片**必须**插入到 `#cardsContainer` **最前面**（第一个子元素）
2. **无需修改分页**：分页由 `paginationState` JavaScript对象自动管理
3. **筛选联动**：`data-category` 值必须与筛选按钮 `data-filter` 一致，否则分页筛选不工作
4. **URL同步**：分页状态会自动同步到URL参数，支持分享链接

### 分页相关代码位置

在 `index.html` 底部 `<script>` 标签内：

```javascript
// 分页状态管理对象
const paginationState = {
    currentPage: 1,
    itemsPerPage: 8,      // 每页显示数量
    currentFilter: 'all',
    allCards: [],
    filteredCards: [],
    totalPages: 1,
    animating: false
};

// 关键函数
- initPagination()         // 初始化，读取URL参数
- applyFilterAndPaginate() // 筛选+分页联动
- goToPage(pageNum)        // 切换页面
- updatePaginationUI()     // 更新分页导航UI
```

### 分页导航HTML结构

```html
<div id="pagination" class="mt-12 flex items-center justify-center gap-4 flex-wrap">
    <button id="prevPage" class="hand-drawn bg-white px-4 py-2 font-mono text-sm">
        ← 上一页
    </button>
    <div id="pageNumbers" class="flex gap-2">
        <!-- 动态生成页码按钮 -->
    </div>
    <span id="pageInfo" class="font-mono text-sm text-muted">第 1 页，共 3 页</span>
    <button id="nextPage" class="hand-drawn bg-white px-4 py-2 font-mono text-sm">
        下一页 →
    </button>
</div>
```

---

## 2. 执行步骤（Step-by-Step）

### Step 1: 获取待发布文章

从飞书多维表格获取所有状态为"已通过"的记录。

```
飞书表格信息:
- app_token: GpMvbgnQta9ISpsywtrca6lTnvb
- table_id: tbl5cLUFMdhl6b0U
- 筛选条件: 状态 == "已通过"
```

**校验**: 每条记录必须包含以下必填字段，缺失则跳过并报警：
- 文章标题、发布日期(YYYY-MM-DD)、文章分类、作者
- 核心摘要、前沿聚焦、技术原理、应用场景
- 科技关键词、关键词解释
- ICC问题1/2/3、思考问题
- 原文链接、原文标题、原文来源、文章正文

### Step 2: 生成文章详情页 HTML

对每篇文章，使用 `assets/article-template.html` 模板生成文件。

**文件命名规则**:
```
article-[主题]-[关键词].html
```
- 全小写，用连字符分隔
- 例: `article-robot-parkour.html`, `article-qwen-ai-glasses.html`

**模板替换清单** (共 18 处必须替换):

| 占位符 | 替换为 | 示例 |
|-------|--------|------|
| `{{TITLE}}` | 文章标题 | 亚马逊收购配送机器人... |
| `{{DATE_DISPLAY}}` | 发布日期(显示格式) | 2026-03-20 |
| `{{DATE_STAMP}}` | 头部日期戳 | 2026.03.20 |
| `{{AUTHOR}}` | 作者 | @MG豆豆 |
| `{{CATEGORY_EMOJI}}` | 分类emoji | 参见分类映射表 |
| `{{CATEGORY_NAME}}` | 分类名称 | 机器人 |
| `{{CATEGORY_COLOR_CLASS}}` | 分类颜色class | 参见分类映射表 |
| `{{CATEGORY_TAILWIND_COLOR}}` | tailwind自定义颜色名 | 参见分类映射表 |
| `{{SUMMARY}}` | 核心摘要 | 2-3句话 |
| `{{VIDEO_SECTION}}` | 视频嵌入区域 | 有视频时插入，无则留空 |
| `{{FRONTLINE_FOCUS}}` | 前沿聚焦正文 | 三段式HTML |
| `{{KEYWORD_SECTION}}` | 关键词区域 | keyword-box HTML |
| `{{ICC_QUESTIONS}}` | ICC赛事思维问题 | 3个li |
| `{{THINKING_QUESTION}}` | 科技向善问题 | question-box HTML |
| `{{SOURCE_URL}}` | 原文链接 | https://... |
| `{{SOURCE_TITLE}}` | 原文标题(中文) | 原文中文翻译 |
| `{{SOURCE_DESC}}` | 原文简述 | 原文标题 |
| `{{SOURCE_SITE}}` | 原文来源 | IT之家 |

**分类映射表**:

| 分类 | emoji | color_class | tailwind自定义色 | style写法 |
|------|-------|-------------|----------------|-----------|
| 机器人 | `🤖` | `text-robot` | `'robot': '#f59e0b'` | - |
| AI | `🧠` | - | `'ai': '#8b5cf6'` | `style="color: #8b5cf6;"` |
| 航天 | `🚀` | - | `'space': '#3b82f6'` | `style="color: #3b82f6;"` |
| 智能硬件 | `🔧` | `text-hardware` | `'hardware': '#10b981'` | `style="color: #10b981;"` |
| OpenClaw | `🦞` | `text-accent` | - (用accent) | - |
| 编程 | `💻` | - | `'code': '#6366f1'` | `style="color: #6366f1;"` |
| 生物 | `🧬` | - | `'bio': '#22c55e'` | `style="color: #22c55e;"` |
| 新能源 | `⚡` | - | `'energy': '#eab308'` | `style="color: #eab308;"` |

**视频嵌入规则**:
- 如果有视频链接(B站)，使用 `assets/video-embed-snippet.html` 模板
- 视频位置：文章标题摘要之后、正文之前
- 如果没有视频链接，`{{VIDEO_SECTION}}` 替换为空字符串

### Step 3: 更新首页 index.html

#### 3a. 插入新文章卡片（重要：分页联动）

在 `index.html` 中找到 `<div id="cardsContainer">` 标记，在其后**紧接着**插入新卡片。
新文章**必须**插入到**最前面**（第一个子元素），这是分页系统正常工作的关键。

使用 `assets/index-card-snippet.html` 模板，替换对应变量。

**卡片模板替换清单**:

| 占位符 | 说明 |
|--------|------|
| `{{ARTICLE_FILENAME}}` | 文章HTML文件名 |
| `{{CATEGORY_NAME}}` | 分类名(用于 data-category 筛选) |
| `{{CATEGORY_PILL_HTML}}` | 分类标签完整HTML |
| `{{DATE_DISPLAY}}` | 发布日期 YYYY-MM-DD |
| `{{TITLE}}` | 文章标题 |
| `{{SUMMARY}}` | 核心摘要 |
| `{{THINKING_QUESTION}}` | 科技向善问题(卡片底部) |
| `{{VIDEO_LINK_HTML}}` | 视频链接按钮(可选) |

**⚠️ 分页关键规则**:
- 新卡片插入 `#cardsContainer` 第一个位置
- `data-category` 值必须与导航按钮 `data-filter` **完全一致**
- 分页系统会自动将新卡片放入第1页
- **不要修改**分页导航HTML或JavaScript

#### 3b. 同步筛选标签

检查新文章的分类是否已存在于导航栏。如果是新分类：
1. 在 `<div class="nav-scroll" id="categoryNav">` 中 `</div>` 之前插入新按钮
2. 格式: `<button class="nav-pill" data-filter="{{分类名}}">{{emoji}} {{分类名}}</button>`

**当前已有标签**: 全部、机器人、AI、航天、智能硬件、OpenClaw

#### 3c. 更新日期戳

将 header 中的 `<div class="date-stamp">` 内容更新为今天的日期 `YYYY.MM.DD` 格式。

#### 3d. 更新"今天有什么好玩的？"

更新热点区块，将 `<div>` 改为 `<a>` 链接标签，指向最新文章：

```html
<a href="{{ARTICLE_FILENAME}}" class="block hand-drawn bg-white p-6 hover:text-accent transition-colors">
    <h2 class="font-display font-bold text-xl mb-3 flex items-center gap-2">
        <span>🎯</span>
        <span>今天有什么好玩的？</span>
        <span class="font-mono text-sm text-muted ml-auto">点击阅读 →</span>
    </h2>
    <p class="text-muted leading-relaxed">
        今日热点：[新文章摘要]...
    </p>
</a>
```

#### 3e. 分页自动处理（无需操作）

以下操作由JavaScript自动完成，**无需手动修改**：
- 计算总页数
- 更新页码显示
- 处理筛选联动
- 同步URL参数

### Step 4: Git 提交并推送

```bash
cd /path/to/MGMakerDaily
git add article-新文章.html index.html
git commit -m "Add article: 文章标题"
git push origin master
```

- 每篇文章单独一个 commit
- commit message 格式: `Add article: [中文标题简写]`
- **禁止** `git push --force`
- **禁止** `git add .`（只 add 相关文件）

### Step 5: 更新飞书状态

将已发布文章在飞书表格中的状态改为"已发布"。

### Step 6: 验证

- 等待 1-2 分钟 GitHub Pages 部署
- 检查 https://mgdaily.mgspace.net/ 首页是否显示新卡片
- 检查文章详情页是否可访问
- 检查筛选标签是否工作正常
- 检查视频是否能播放（如有）
- 检查分页功能是否正常

---

## 3. 输出标准（Quality Checklist）

### 文章详情页 HTML

- [ ] 文件命名 `article-[主题]-[关键词].html`，全小写连字符
- [ ] `<title>` 包含文章标题 + " — MG Maker Daily"
- [ ] 导航栏只有 `← 返回首页` 按钮，**无分类标签**
- [ ] 日期戳显示今天日期 `YYYY.MM.DD`
- [ ] header 中 M logo 和标题链接回 `index.html`
- [ ] 分类标签 (category-pill) 颜色与分类映射表一致
- [ ] 文章日期格式 `YYYY-MM-DD`
- [ ] 作者显示 `文章整理：@MG豆豆`
- [ ] 包含完整 5 个模块: 前沿聚焦、关键词、ICC问题、科技向善、原文出处
- [ ] 前沿聚焦为三段式（背景痛点→技术突破→应用价值）
- [ ] 关键词有中英文对照
- [ ] ICC 问题 2-3 个，对应定义调研/创新差异/测试迭代
- [ ] 底部有 `← 返回首页，查看更多科技新闻` 链接
- [ ] footer 与首页一致

### 首页卡片

- [ ] 新卡片插入到 `#cardsContainer` 最前面
- [ ] `data-category` 属性值与分类名完全一致（用于筛选）
- [ ] `onclick` 正确链接到文章文件名
- [ ] 包含: 分类标签、日期、作者、标题、摘要、思考问题、阅读全文
- [ ] 视频链接按钮 `onclick="event.stopPropagation();"` 防止冒泡
- [ ] 卡片格式与现有卡片完全一致

### 筛选标签同步

- [ ] 新分类的 `data-filter` 值与卡片 `data-category` 完全一致
- [ ] 标签带对应 emoji
- [ ] 筛选动画（渐隐渐现）对新标签有效

### 分页系统验证（新增）

- [ ] 新卡片插入到 `#cardsContainer` **第一个位置**
- [ ] 首页默认显示最新 8 篇文章
- [ ] 点击"下一页"正确显示第 9-16 篇
- [ ] 分类筛选后分页自动重算
- [ ] 分页导航显示正确的总页数
- [ ] URL参数 `?page=2` 可直接跳转到第2页
- [ ] 页码按钮高亮状态正确

---

## 4. 关键约束（Must NOT Do）

1. **禁止修改现有文章**的内容（除非明确要求）
2. **禁止删除已有卡片**
3. **禁止使用 `git push --force`**
4. **禁止使用 `git add .` 或 `git add -A`**
5. **禁止在文章页导航栏添加分类标签**（只保留返回首页按钮）
6. **禁止使用"魔法""打怪升级"等低幼化词汇**
7. **禁止发布政治敏感或纯商业广告内容**
8. 文章详情页的 nav 只有一个返回按钮，**不要加任何分类 pill**
9. 不要修改 CSS 样式或 JS 逻辑，除非发现明确 bug
10. **禁止修改分页导航HTML结构**（由JavaScript自动管理）
11. **禁止将新卡片插入到 `#cardsContainer` 末尾**（必须插在最前面）
12. **禁止手动修改页码显示**（分页系统自动计算）

---

## 5. 目录结构

```
mgdaily-publish-skill/
├── SKILL.md                          # 本文件：完整 Skill 文档
├── references/
│   ├── style-guide.md                # 颜色/字体/组件样式规范
│   ├── content-standard.md           # 内容写作规范 & AI提示词
│   ├── category-mapping.md           # 分类→emoji/颜色完整映射表
│   └── pagination-system.md          # 分页系统技术规范（新增）
├── scripts/
│   ├── generate-article.sh           # 从变量生成文章HTML
│   ├── update-index.sh               # 更新首页卡片和标签
│   └── publish.sh                    # 一键发布（生成+更新+提交）
└── assets/
    ├── article-template.html         # 文章详情页完整模板
    ├── index-card-snippet.html       # 首页卡片代码片段
    └── video-embed-snippet.html      # 视频嵌入代码片段
```

---

## 6. 快速参考

### 项目链接
- **网站**: https://mgdaily.mgspace.net/
- **GitHub**: https://github.com/hardihuang/MGMakerDaily
- **飞书表格**: https://sisy9sdzrms.feishu.cn/base/GpMvbgnQta9ISpsywtrca6lTnvb

### 分页关键点
- 每页 **8篇** 文章
- 新卡片 **必须** 插入 `#cardsContainer` 最前面
- `data-category` 与 `data-filter` 必须 **完全一致**
- 分页系统 **自动处理**，无需手动修改

### 文件位置
- 首页: `/Users/doudou/Documents/mgmakerdaily/github/index.html`
- 文章模板: `/Users/doudou/Documents/mgmakerdaily/github/article-*.html`
- Skill目录: `/Users/doudou/Documents/mgmakerdaily/mgdaily-publish-skill/`
