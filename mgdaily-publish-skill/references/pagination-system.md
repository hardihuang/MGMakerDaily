# MG Maker Daily 分页系统规范

## 概述

首页采用纯前端JavaScript动态分页，兼容GitHub Pages静态托管。

## 配置参数

| 参数 | 值 | 说明 |
|------|-----|------|
| `itemsPerPage` | `8` | 每页显示文章数 |
| `maxVisiblePages` | `5` | 页码按钮最大显示数 |
| 动画时长 | `350ms` | 卡片切换动画 |

## JavaScript 状态对象

```javascript
const paginationState = {
    currentPage: 1,        // 当前页码
    itemsPerPage: 8,       // 每页文章数
    currentFilter: 'all',  // 当前筛选分类
    allCards: [],          // 所有卡片DOM引用
    filteredCards: [],     // 筛选后的卡片
    totalPages: 1,         // 总页数
    animating: false       // 动画锁
};
```

## 核心函数

### initPagination()
- 页面加载时初始化
- 从URL读取 `?page=` 和 `?filter=` 参数
- 设置初始筛选按钮状态

### applyFilterAndPaginate(targetPage)
- 筛选分类并计算分页
- 参数: `targetPage` - 目标页码
- 流程: 筛选 → 计算总页数 → 显示对应页卡片 → 更新UI

### goToPage(pageNum)
- 切换到指定页面
- 参数校验: 1 ≤ pageNum ≤ totalPages
- 调用 applyFilterAndPaginate()

### updatePaginationUI()
- 更新分页导航显示
- 包括: 页码信息、按钮状态、页码按钮

### renderPageNumbers()
- 渲染页码数字按钮
- 最多显示5个页码
- 当前页高亮显示

## 筛选联动逻辑

```
用户点击筛选按钮
    ↓
更新 currentFilter
    ↓
重置 currentPage = 1
    ↓
调用 applyFilterAndPaginate(1)
    ↓
filteredCards = allCards.filter(匹配分类)
    ↓
totalPages = ceil(filteredCards.length / 8)
    ↓
显示第1页的8篇文章
    ↓
更新分页导航UI
    ↓
同步URL参数
```

## URL参数同步

```javascript
// 更新URL
function updateURL() {
    const params = new URLSearchParams();
    if (paginationState.currentPage > 1) {
        params.set('page', paginationState.currentPage);
    }
    if (paginationState.currentFilter !== 'all') {
        params.set('filter', paginationState.currentFilter);
    }
    const newURL = params.toString()
        ? `${window.location.pathname}?${params.toString()}`
        : window.location.pathname;
    history.replaceState(null, '', newURL);
}
```

示例URL:
- 第2页: `index.html?page=2`
- 筛选机器人第1页: `index.html?filter=机器人`
- 筛选AI第2页: `index.html?page=2&filter=AI`

## HTML结构

### 分页导航
```html
<div id="pagination" class="mt-12 flex items-center justify-center gap-4 flex-wrap">
    <button id="prevPage" class="hand-drawn bg-white px-4 py-2 font-mono text-sm disabled:opacity-50">
        ← 上一页
    </button>
    <div id="pageNumbers" class="flex gap-2">
        <!-- 动态生成页码按钮 -->
    </div>
    <span id="pageInfo" class="font-mono text-sm text-muted">第 1 页，共 3 页</span>
    <button id="nextPage" class="hand-drawn bg-white px-4 py-2 font-mono text-sm disabled:opacity-50">
        下一页 →
    </button>
</div>
```

### 卡片容器
```html
<div id="cardsContainer">
    <!-- 所有文章卡片，按时间倒序排列 -->
    <div class="card-link" data-category="机器人">...</div>
    <div class="card-link" data-category="AI">...</div>
    ...
</div>
```

## CSS动画类

分页切换使用现有筛选动画类：

| CSS类 | 作用 |
|-------|------|
| `.card-fade-out` | 淡出动画（opacity 0） |
| `.card-collapsed` | 折叠状态（max-height 0） |
| `.card-fade-in` | 淡入动画初始状态 |

## 新增文章时的分页行为

```
新卡片插入 #cardsContainer 最前面
    ↓
allCards 数组自动包含新卡片（DOM顺序）
    ↓
刷新页面或触发筛选时重新计算
    ↓
新卡片进入第1页（显示最新8篇）
    ↓
原第1页末尾卡片移至第2页
    ↓
总页数可能增加（如果超过8*原页数）
```

## 禁止操作

1. **不要修改** `paginationState` 的 `itemsPerPage` 值（固定8篇）
2. **不要手动修改** 分页导航HTML内容
3. **不要删除** 分页相关的JavaScript代码
4. **不要将新卡片插入末尾**（必须最前面）

## 验证方法

```javascript
// 在浏览器控制台测试
// 1. 检查状态
console.log(paginationState);

// 2. 手动切换页
goToPage(2);

// 3. 筛选测试
// 点击导航栏筛选按钮，观察分页变化

// 4. URL测试
// 直接访问 index.html?page=2&filter=机器人
```

## 常见问题

### Q: 新文章没出现在第1页？
A: 检查卡片是否插入到 `#cardsContainer` **第一个位置**

### Q: 筛选后分页显示错误？
A: 检查卡片 `data-category` 值是否与按钮 `data-filter` 完全一致

### Q: 页码不更新？
A: 刷新页面，分页在页面加载时初始化

### Q: 动画卡顿？
A: 检查 `paginationState.animating` 是否正确释放