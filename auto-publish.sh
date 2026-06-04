#!/bin/bash
# MG Maker Daily 自动新闻发布脚本
# 每3天由 cron 触发，自动搜索科技新闻、生成文章、部署到 GitHub Pages
# 用法: bash /Users/doudou/Documents/mgmakerdaily/auto-publish.sh

set -e

SITE_DIR="/Users/doudou/Documents/mgmakerdaily"
WORKSPACE="/Users/doudou/.openclaw/workspace"
LOG_FILE="$WORKSPACE/memory/$(date +%Y-%m-%d).md"
TAVILY_KEY="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"

echo "[$(date '+%Y-%m-%d %H:%M')] MG Daily 自动发布开始..."

# Step 1: 搜索最新科技新闻
echo "🔍 搜索最新科技新闻..."
SEARCH_RESULTS=$(python3 -c "
from tavily import TavilyClient
import json
client = TavilyClient(api_key='$TAVILY_KEY')
results = client.search(
    query='humanoid robot OR AI breakthrough OR open source robot OR 3D printing innovation 2026',
    search_depth='advanced',
    max_results=10,
    topic='news',
    time_range='week'
)
# Filter for kid-friendly topics
keywords = ['robot', 'AI', 'humanoid', '3D print', 'open source', 'space', 'drone', 'maker', 'coding', 'education']
filtered = []
for r in results.get('results', []):
    title = r.get('title', '').lower()
    content = r.get('content', '').lower()
    if any(k.lower() in title or k.lower() in content for k in keywords):
        filtered.append({
            'title': r['title'],
            'url': r['url'],
            'score': r.get('score', 0),
            'content': r.get('content', '')[:500]
        })
print(json.dumps(filtered[:5], ensure_ascii=False))
" 2>/dev/null)

if [ -z "$SEARCH_RESULTS" ] || [ "$SEARCH_RESULTS" = "[]" ]; then
    echo "❌ 未找到合适的新闻，跳过发布"
    exit 0
fi

echo "📰 找到新闻: $SEARCH_RESULTS"

# Step 2: 触发 Jarvis 处理（通过 openclaw send）
# 让 Jarvis 来完成文章生成、B站视频搜索、HTML创建、首页更新、git部署
# 这样可以利用 Jarvis 的完整能力
echo "📤 发送任务给 Jarvis..."

# 写入待处理文件，供 Jarvis heartbeat 检查
cat > "$WORKSPACE/temp/mg-daily-pending.json" << EOF
{
  "action": "mg_daily_auto_publish",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "search_results": $SEARCH_RESULTS,
  "status": "pending"
}
EOF

echo "✅ 任务已写入 $WORKSPACE/temp/mg-daily-pending.json"
echo "⏳ 等待 Jarvis 处理..."
