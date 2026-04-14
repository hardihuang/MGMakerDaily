#!/bin/bash
# update-index.sh - 更新首页卡片和筛选标签
# 用法: 由 publish.sh 调用，或手动执行
#
# 必需环境变量:
#   REPO_DIR            - 仓库根目录
#   ARTICLE_FILENAME    - 文章文件名
#   ARTICLE_TITLE       - 文章标题
#   ARTICLE_DATE        - 发布日期 YYYY-MM-DD
#   ARTICLE_CATEGORY    - 分类名
#   ARTICLE_SUMMARY     - 核心摘要
#   ARTICLE_AUTHOR      - 作者
#   THINKING_QUESTION   - 科技向善问题
#
# 可选:
#   VIDEO_URL           - 视频链接
#   VIDEO_LINK_TEXT     - 视频按钮文字

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
INDEX="$REPO_DIR/index.html"
CARD_TEMPLATE="$SKILL_DIR/assets/index-card-snippet.html"

ARTICLE_AUTHOR="${ARTICLE_AUTHOR:-@MG豆豆}"

echo "📝 更新首页: $INDEX"

python3 << 'PYEOF'
import os, re

index_path = os.environ['REPO_DIR'] + '/index.html'
card_template_path = os.environ.get('CARD_TEMPLATE', '')

with open(index_path, 'r') as f:
    content = f.read()

# --- 1. 读取卡片模板并填充 ---
with open(card_template_path, 'r') as f:
    card = f.read()

category = os.environ['ARTICLE_CATEGORY']
date = os.environ['ARTICLE_DATE']

# 分类映射
cat_map = {
    '机器人': ('🤖', 'text-robot', '#f59e0b'),
    'AI':     ('🧠', '', '#8b5cf6'),
    '航天':   ('🚀', '', '#3b82f6'),
    '智能硬件': ('🔧', '', '#10b981'),
    'OpenClaw': ('🦞', 'text-accent', '#ff6b35'),
    '编程':   ('💻', '', '#6366f1'),
    '生物':   ('🧬', '', '#22c55e'),
    '新能源': ('⚡', '', '#eab308'),
}

emoji, cls, color = cat_map.get(category, ('📰', '', '#6b6b6b'))

if cls:
    pill_html = f'<span class="category-pill {cls}">{emoji} {category}</span>'
else:
    pill_html = f'<span class="category-pill" style="color: {color};">{emoji} {category}</span>'

# 视频链接按钮
video_url = os.environ.get('VIDEO_URL', '')
video_text = os.environ.get('VIDEO_LINK_TEXT', '相关视频')
if video_url:
    video_link_html = f'<a href="{video_url}" target="_blank" class="video-link" onclick="event.stopPropagation();">▶ {video_text}</a>'
else:
    video_link_html = ''

replacements = {
    '{{ARTICLE_FILENAME}}': os.environ['ARTICLE_FILENAME'],
    '{{CATEGORY_NAME}}': category,
    '{{CATEGORY_PILL_HTML}}': pill_html,
    '{{DATE_DISPLAY}}': date,
    '{{AUTHOR}}': os.environ.get('ARTICLE_AUTHOR', '@MG豆豆'),
    '{{TITLE}}': os.environ['ARTICLE_TITLE'],
    '{{SUMMARY}}': os.environ['ARTICLE_SUMMARY'],
    '{{THINKING_QUESTION}}': os.environ.get('THINKING_QUESTION', ''),
    '{{VIDEO_LINK_HTML}}': video_link_html,
}

for key, value in replacements.items():
    card = card.replace(key, value)

# --- 2. 插入卡片到 #cardsContainer 开头 ---
marker = '<div id="cardsContainer">'
if marker in content:
    content = content.replace(marker, marker + '\n' + card)
    print(f"✅ 卡片已插入: {os.environ['ARTICLE_TITLE']}")
else:
    print("⚠️ 未找到 #cardsContainer 标记，请检查 index.html")

# --- 3. 同步筛选标签 ---
nav_pattern = r'(<div class="nav-scroll" id="categoryNav">)(.*?)(</div>)'
nav_match = re.search(nav_pattern, content, re.DOTALL)
if nav_match:
    nav_content = nav_match.group(2)
    filter_check = f'data-filter="{category}"'
    if filter_check not in nav_content:
        new_button = f'\n                <button class="nav-pill" data-filter="{category}">{emoji} {category}</button>'
        content = content.replace(
            nav_match.group(0),
            nav_match.group(1) + nav_content + new_button + '\n            ' + nav_match.group(3)
        )
        print(f"✅ 新增筛选标签: {emoji} {category}")
    else:
        print(f"ℹ️ 筛选标签已存在: {category}")

# --- 4. 更新日期戳 ---
today_stamp = date.replace('-', '.')
content = re.sub(
    r'(<div class="date-stamp">\s*)\d{4}\.\d{2}\.\d{2}(\s*</div>)',
    rf'\g<1>{today_stamp}\2',
    content
)
print(f"✅ 日期戳已更新: {today_stamp}")

# --- 5. 写回文件 ---
with open(index_path, 'w') as f:
    f.write(content)

print("✅ 首页更新完成")
PYEOF

export CARD_TEMPLATE
echo "✅ update-index.sh 执行完成"
