#!/bin/bash
# MG Maker Daily - 晨间新闻自动化脚本
# 每天早上7点执行
# 1. 检查飞书表格选题
# 2. 如无选题，自动搜索前一天科技新闻
# 3. 按提示词创作内容
# 4. 发送审核通知
# 5. 审核通过后发布

set -e

# 配置
FEISHU_APP_TOKEN="GpMvbgnQta9ISpsywtrca6lTnvb"
FEISHU_TABLE_ID="tbl5cLUFMdhl6b0U"
GITHUB_REPO="hardihuang/MGMakerDaily"
WEBSITE_URL="http://mgdaily.mgspace.net"
DATE=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)

echo "========================================"
echo "MG Maker Daily - 晨间新闻自动化"
echo "日期: $DATE"
echo "========================================"

# Step 1: 检查飞书表格中是否有待发布的选题
echo "[1/5] 检查飞书表格选题..."

# 调用飞书 API 获取状态为"选题库"的记录
# 注意：这里需要实际的飞书 API 调用
# 伪代码示意：
# pending_topics=$(feishu_bitable_list_records --app_token $FEISHU_APP_TOKEN --table_id $FEISHU_TABLE_ID --filter "状态=选题库")

PENDING_COUNT=0  # 实际应从API获取

if [ $PENDING_COUNT -eq 0 ]; then
    echo "无待发布选题，开始自动搜索新闻..."
    
    # Step 2: 自动搜索前一天科技新闻
    echo "[2/5] 搜索 $YESTERDAY 科技新闻..."
    
    # 搜索关键词列表
    TOPICS=(
        "AI人工智能"
        "机器人"
        "编程教育"
        "开源硬件"
        "3D打印"
        "新能源"
        "航天科技"
    )
    
    # 随机选择一个主题
    RANDOM_TOPIC=${TOPICS[$RANDOM % ${#TOPICS[@]}]}
    echo "选定主题: $RANDOM_TOPIC"
    
    # 使用 web_search 搜索新闻（需要配置 API）
    # 这里使用模拟数据，实际应调用搜索 API
    
    # 创建新选题到飞书表格
    echo "创建新选题到飞书表格..."
    # feishu_bitable_create_record ...
    
    NEWS_TITLE="示例：$YESTERDAY $RANDOM_TOPIC 领域重大突破"
    NEWS_URL="https://example.com/news"
    
else
    echo "发现 $PENDING_COUNT 个待发布选题"
    # 获取第一个选题
    NEWS_TITLE="从飞书表格获取的标题"
    NEWS_URL="从飞书表格获取的链接"
fi

# Step 3: AI 创作内容
echo "[3/5] AI 创作文章内容..."

# 生成文章各字段内容
# 这里应该调用 AI 模型生成，实际由 MG豆豆 执行

echo "文章标题: $NEWS_TITLE"
echo "正在生成: 核心摘要、前沿聚焦、技术原理、应用场景..."
echo "正在生成: 科技关键词、ICC问题、思考问题..."

# Step 4: 发送审核通知
echo "[4/5] 发送审核通知..."

# 生成审核消息
MESSAGE=$(cat <<EOF
📰 MG Daily 晨间新闻待审核

日期: $DATE
标题: $NEWS_TITLE
原文: $NEWS_URL

状态: 已创作完成，等待审核

审核链接: $WEBSITE_URL/admin

请在飞书表格中查看完整内容，审核通过后回复"发布"即可自动上线。
EOF
)

echo "$MESSAGE"
# 实际应发送到飞书/微信/邮件
# message send --target "黄昊" --content "$MESSAGE"

echo ""
echo "========================================"
echo "等待审核中..."
echo "审核通过后执行: ./publish-article.sh"
echo "========================================"

# 保存当前任务状态到文件
echo "$DATE|$NEWS_TITLE|$NEWS_URL|pending" > /tmp/mg_daily_pending.task
