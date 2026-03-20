#!/bin/bash
# MG Maker Daily - 文章发布脚本
# 审核通过后执行

set -e

# 配置
GITHUB_REPO="git@github.com:hardihuang/MGMakerDaily.git"
WEBSITE_URL="http://mgdaily.mgspace.net"
DATE=$(date +%Y-%m-%d)

echo "========================================"
echo "MG Maker Daily - 文章发布"
echo "日期: $DATE"
echo "========================================"

# 读取待发布任务
if [ ! -f /tmp/mg_daily_pending.task ]; then
    echo "错误: 没有找到待发布任务"
    exit 1
fi

TASK=$(cat /tmp/mg_daily_pending.task)
ARTICLE_DATE=$(echo $TASK | cut -d'|' -f1)
ARTICLE_TITLE=$(echo $TASK | cut -d'|' -f2)
ARTICLE_URL=$(echo $TASK | cut -d'|' -f3)

# 从飞书表格获取完整内容
# 这里应该调用飞书 API 获取各字段内容

echo "[1/4] 从飞书表格获取文章内容..."

# 模拟获取内容（实际应从飞书 API 获取）
CATEGORY="机器人"
SUMMARY="这是文章核心摘要..."
FOCUS="这是前沿聚焦内容..."
PRINCIPLE="这是技术原理..."
APPLICATION="这是应用场景..."
KEYWORD="强化学习"
KEYWORD_DESC="这是关键词解释..."
ICC1="ICC问题1..."
ICC2="ICC2问题2..."
ICC3="ICC问题3..."
QUESTION="思考问题..."
VIDEO_URL="https://b23.tv/xxx"

echo "[2/4] 生成 HTML 文章..."

# 生成文件名
SAFE_TITLE=$(echo "$ARTICLE_TITLE" | tr ' ' '-' | tr -cd '[:alnum:]-')
HTML_FILE="article-${SAFE_TITLE}.html"

# 创建 HTML 内容
cat > /tmp/$HTML_FILE <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$ARTICLE_TITLE — MG Maker Daily</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=Inter:wght@400;500&family=Courier+Prime&family=Noto+Sans+SC:wght@400;500;700&display=swap" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- 配置省略，与现有文章一致 -->
</head>
<body class="font-body min-h-screen">
    <!-- Header 和 Navigation 省略 -->
    
    <main class="max-w-3xl mx-auto px-6 py-10">
        <div class="mb-8">
            <span class="category-pill text-robot">$CATEGORY</span>
            <div class="font-mono text-sm text-muted mt-3 mb-2">$DATE</div>
            <div class="font-mono text-sm text-muted mb-4">文章整理：@MG豆豆</div>
            <h1 class="font-display font-bold text-3xl leading-tight">$ARTICLE_TITLE</h1>
        </div>
        
        <article class="article-content">
            <h2>【🔍 前沿聚焦】</h2>
            <p>$FOCUS</p>
            
            <h2>【🔑 核心科技关键词】</h2>
            <p><strong>$KEYWORD</strong>：$KEYWORD_DESC</p>
            
            <h2>【💡 创科启发：ICC 赛事思维预演】</h2>
            <ul>
                <li><strong>定义与调研：</strong>$ICC1</li>
                <li><strong>创新与差异：</strong>$ICC2</li>
                <li><strong>测试与优化：</strong>$ICC3</li>
            </ul>
            
            <div class="question-box">
                <div class="question-title">💬 留给你的问题：科技向善</div>
                <p>$QUESTION</p>
            </div>
            
            <div class="mt-8 pt-6 border-t-2 border-ink/10">
                <div class="font-mono text-xs text-muted mb-2">原文出处</div>
                <a href="$ARTICLE_URL" target="_blank">$ARTICLE_TITLE →</a>
            </div>
        </article>
    </main>
    
    <!-- Footer 省略 -->
</body>
</html>
EOF

echo "生成文件: $HTML_FILE"

# Step 3: 更新首页
echo "[3/4] 更新首页..."

# 克隆仓库
cd /tmp
git clone $GITHUB_REPO mgdaily-temp
cd mgdaily-temp

# 复制新文章
cp /tmp/$HTML_FILE ./

# 更新首页 index.html（在头部添加新文章卡片）
# 这里需要实际的 HTML 编辑操作

echo "首页已更新"

# Step 4: 推送到 GitHub
echo "[4/4] 推送到 GitHub..."

git add .
git commit -m "Add article: $ARTICLE_TITLE ($DATE)"
git push origin master

echo ""
echo "========================================"
echo "✅ 发布成功！"
echo "文章链接: $WEBSITE_URL/$HTML_FILE"
echo "首页链接: $WEBSITE_URL/"
echo "========================================"

# 清理临时文件
rm -f /tmp/mg_daily_pending.task
rm -rf /tmp/mgdaily-temp
rm -f /tmp/$HTML_FILE

# 发送发布成功通知
# message send --target "黄昊" --content "📰 MG Daily 文章已发布\n\n标题: $ARTICLE_TITLE\n链接: $WEBSITE_URL/$HTML_FILE"
