#!/bin/bash
# generate-article.sh - 从环境变量生成文章HTML
# 用法: 设置环境变量后执行，或由 publish.sh 调用
#
# 必需环境变量:
#   ARTICLE_TITLE       - 文章标题
#   ARTICLE_DATE        - 发布日期 YYYY-MM-DD
#   ARTICLE_CATEGORY    - 分类名 (机器人/AI/航天/智能硬件/OpenClaw/编程/生物/新能源)
#   ARTICLE_AUTHOR      - 作者 (默认 @MG豆豆)
#   ARTICLE_SUMMARY     - 核心摘要
#   ARTICLE_FILENAME    - 输出文件名 (如 article-robot-parkour.html)
#   ARTICLE_BODY_FILE   - 文章正文HTML内容文件路径
#
# 可选环境变量:
#   VIDEO_BV_ID         - B站视频BV号
#   VIDEO_URL           - B站视频完整URL
#   VIDEO_TITLE         - 视频标题

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE="$SKILL_DIR/assets/article-template.html"
VIDEO_TEMPLATE="$SKILL_DIR/assets/video-embed-snippet.html"

# 默认值
ARTICLE_AUTHOR="${ARTICLE_AUTHOR:-@MG豆豆}"

# 验证必需变量
for var in ARTICLE_TITLE ARTICLE_DATE ARTICLE_CATEGORY ARTICLE_SUMMARY ARTICLE_FILENAME ARTICLE_BODY_FILE REPO_DIR; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: 缺少必需环境变量 $var"
        exit 1
    fi
done

# 日期格式转换
DATE_STAMP=$(echo "$ARTICLE_DATE" | sed 's/-/./g')

# 分类映射
get_category_info() {
    local cat="$1"
    case "$cat" in
        "机器人")
            echo "🤖|text-robot|robot|#f59e0b"
            ;;
        "AI")
            echo "🧠||ai|#8b5cf6"
            ;;
        "航天")
            echo "🚀||space|#3b82f6"
            ;;
        "智能硬件")
            echo "🔧||hardware|#10b981"
            ;;
        "OpenClaw")
            echo "🦞|text-accent|accent|#ff6b35"
            ;;
        "编程")
            echo "💻||code|#6366f1"
            ;;
        "生物")
            echo "🧬||bio|#22c55e"
            ;;
        "新能源")
            echo "⚡||energy|#eab308"
            ;;
        *)
            echo "📰||custom|#6b6b6b"
            ;;
    esac
}

IFS='|' read -r EMOJI COLOR_CLASS TW_COLOR COLOR_HEX <<< "$(get_category_info "$ARTICLE_CATEGORY")"

# 生成分类标签HTML
if [ -n "$COLOR_CLASS" ]; then
    PILL_HTML="<span class=\"category-pill $COLOR_CLASS\">$EMOJI $ARTICLE_CATEGORY</span>"
else
    PILL_HTML="<span class=\"category-pill\" style=\"color: $COLOR_HEX;\">$EMOJI $ARTICLE_CATEGORY</span>"
fi

# 生成视频区域
VIDEO_SECTION=""
if [ -n "${VIDEO_BV_ID:-}" ]; then
    VIDEO_SECTION=$(cat "$VIDEO_TEMPLATE" \
        | sed "s|{{BV_ID}}|$VIDEO_BV_ID|g" \
        | sed "s|{{VIDEO_FULL_URL}}|${VIDEO_URL:-https://www.bilibili.com/video/$VIDEO_BV_ID}|g" \
        | sed "s|{{VIDEO_TITLE}}|${VIDEO_TITLE:-相关视频}|g"
    )
fi

# 读取文章正文
ARTICLE_BODY=$(cat "$ARTICLE_BODY_FILE")

# 生成最终HTML
OUTPUT="$REPO_DIR/$ARTICLE_FILENAME"

cp "$TEMPLATE" "$OUTPUT"

# 用 python 做模板替换（避免 sed 特殊字符问题）
python3 << 'PYEOF'
import os

output = os.environ['REPO_DIR'] + '/' + os.environ['ARTICLE_FILENAME']

with open(output, 'r') as f:
    content = f.read()

replacements = {
    '{{TITLE}}': os.environ['ARTICLE_TITLE'],
    '{{DATE_STAMP}}': os.environ['ARTICLE_DATE'].replace('-', '.'),
    '{{DATE_DISPLAY}}': os.environ['ARTICLE_DATE'],
    '{{AUTHOR}}': os.environ.get('ARTICLE_AUTHOR', '@MG豆豆'),
    '{{SUMMARY}}': os.environ['ARTICLE_SUMMARY'],
    '{{CATEGORY_TAILWIND_COLOR}}': os.environ.get('TW_COLOR', 'custom'),
    '{{CATEGORY_COLOR_HEX}}': os.environ.get('COLOR_HEX', '#6b6b6b'),
    '{{CATEGORY_PILL_HTML}}': os.environ.get('PILL_HTML', ''),
    '{{VIDEO_SECTION}}': os.environ.get('VIDEO_SECTION', ''),
}

for key, value in replacements.items():
    content = content.replace(key, value)

with open(output, 'w') as f:
    f.write(content)

print(f"Generated: {output}")
PYEOF

export TW_COLOR COLOR_HEX PILL_HTML VIDEO_SECTION
python3 << 'PYEOF'
import os
output = os.environ['REPO_DIR'] + '/' + os.environ['ARTICLE_FILENAME']
with open(output, 'r') as f:
    content = f.read()
replacements = {
    '{{TITLE}}': os.environ['ARTICLE_TITLE'],
    '{{DATE_STAMP}}': os.environ['ARTICLE_DATE'].replace('-', '.'),
    '{{DATE_DISPLAY}}': os.environ['ARTICLE_DATE'],
    '{{AUTHOR}}': os.environ.get('ARTICLE_AUTHOR', '@MG豆豆'),
    '{{SUMMARY}}': os.environ['ARTICLE_SUMMARY'],
    '{{CATEGORY_TAILWIND_COLOR}}': os.environ.get('TW_COLOR', 'custom'),
    '{{CATEGORY_COLOR_HEX}}': os.environ.get('COLOR_HEX', '#6b6b6b'),
    '{{CATEGORY_PILL_HTML}}': os.environ.get('PILL_HTML', ''),
    '{{VIDEO_SECTION}}': os.environ.get('VIDEO_SECTION', ''),
}
for key, value in replacements.items():
    content = content.replace(key, value)
with open(output, 'w') as f:
    f.write(content)
print(f"Generated: {output}")
PYEOF

echo "✅ 文章生成完成: $OUTPUT"
