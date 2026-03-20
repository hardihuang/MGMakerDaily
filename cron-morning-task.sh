#!/bin/bash
# MG Maker Daily - 晨间新闻定时任务
# 每天早上7点执行

set -e

echo "[$(date)] MG Daily 晨间任务开始..."

# 配置
APP_TOKEN="GpMvbgnQta9ISpsywtrca6lTnvb"
TABLE_ID="tbl5cLUFMdhl6b0U"
WORKSPACE="/home/admin/.openclaw/workspace/mg-maker-daily"

cd "$WORKSPACE"

# 步骤1: 检查是否有"选题库"状态的新闻
echo "[Step 1] 检查选题库..."
# 使用 feishu_bitable_list_records 工具检查
# 如果有选题，生成文章并发布

# 步骤2: 如果没有选题，搜索新闻并创建
# (需要 web_search API key)

# 步骤3: 生成HTML并发布到GitHub
echo "[Step 3] 发布文章..."

# 步骤4: 更新飞书表格状态
echo "[Step 4] 更新状态..."

echo "[$(date)] 晨间任务完成"
