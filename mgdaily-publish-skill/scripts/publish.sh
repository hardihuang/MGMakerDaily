#!/bin/bash
# publish.sh - 一键发布：生成文章 + 更新首页 + Git提交推送
# 用法: ./publish.sh
#
# 前置: 设置好所有环境变量（参见 generate-article.sh 和 update-index.sh）
# 额外必需:
#   REPO_DIR              - 仓库根目录 (如 /path/to/MGMakerDaily)
#   ARTICLE_BODY_FILE     - 文章正文HTML文件路径
#   THINKING_QUESTION     - 科技向善问题 (卡片和详情页共用)
#
# 示例:
#   export REPO_DIR=/Users/hardihuang/Documents/mgdaily-openclaw/github/MGMakerDaily
#   export ARTICLE_TITLE="机器狗的跑酷进化"
#   export ARTICLE_DATE="2026-03-21"
#   export ARTICLE_CATEGORY="机器人"
#   export ARTICLE_FILENAME="article-robot-parkour-v2.html"
#   export ARTICLE_SUMMARY="科学家给机器狗装上AI大脑..."
#   export ARTICLE_BODY_FILE="/tmp/article-body.html"
#   export THINKING_QUESTION="如果你设计救援机器人..."
#   export VIDEO_BV_ID="BV1pMPQzCEfw"
#   export VIDEO_URL="https://www.bilibili.com/video/BV1pMPQzCEfw"
#   export VIDEO_TITLE="机器狗演示视频"
#   export VIDEO_LINK_TEXT="机器狗演示视频"
#   ./publish.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 MG Maker Daily 发布流程开始"
echo "================================"
echo "文章: $ARTICLE_TITLE"
echo "分类: $ARTICLE_CATEGORY"
echo "日期: $ARTICLE_DATE"
echo "文件: $ARTICLE_FILENAME"
echo "================================"

# Step 1: 生成文章HTML
echo ""
echo "📄 Step 1: 生成文章详情页..."
bash "$SCRIPT_DIR/generate-article.sh"

# Step 2: 更新首页
echo ""
echo "🏠 Step 2: 更新首页..."
bash "$SCRIPT_DIR/update-index.sh"

# Step 3: Git 提交推送
echo ""
echo "📦 Step 3: Git 提交推送..."
cd "$REPO_DIR"

# 检查是否有变更
if git diff --quiet HEAD -- "$ARTICLE_FILENAME" index.html 2>/dev/null; then
    echo "⚠️ 没有检测到变更，跳过提交"
else
    git add "$ARTICLE_FILENAME" index.html
    git commit -m "Add article: $ARTICLE_TITLE"
    echo "✅ Git commit 完成"

    echo "📤 推送到远程..."
    git push origin master
    echo "✅ Git push 完成"
fi

# Step 4: 验证提示
echo ""
echo "================================"
echo "🎉 发布完成！"
echo ""
echo "请在 1-2 分钟后验证:"
echo "  🌐 首页: http://mgdaily.mgspace.net/"
echo "  📖 文章: http://mgdaily.mgspace.net/$ARTICLE_FILENAME"
echo ""
echo "验证清单:"
echo "  [ ] 首页是否显示新卡片？"
echo "  [ ] 文章详情页是否可访问？"
echo "  [ ] 筛选标签是否工作？"
echo "  [ ] 视频是否能播放？（如有）"
echo "================================"
