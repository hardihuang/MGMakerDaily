#!/usr/bin/env python3
# MG Maker Daily 飞书推送脚本
# 将最新文章以消息卡片形式推送到指定班级群

import json
import sys
import requests

APP_ID = "cli_aaaba5837eb95cfa"
APP_SECRET = "l3SMAbmc8ag9RQ4UWPR7hblV5MFCw0pd"
BASE_URL = "https://open.feishu.cn/open-apis"

# 班级群列表 - 从 push-config.json 加载
import os

CONFIG_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "push-config.json")

def load_config():
    with open(CONFIG_PATH, "r") as f:
        return json.load(f)

CLASS_GROUPS = {}  # 运行时从 config 加载

def get_token():
    """获取 tenant_access_token"""
    resp = requests.post(
        f"{BASE_URL}/auth/v3/tenant_access_token/internal",
        json={"app_id": APP_ID, "app_secret": APP_SECRET}
    )
    data = resp.json()
    if data.get("code") != 0:
        print(f"❌ 获取token失败: {data}")
        sys.exit(1)
    return data["tenant_access_token"]

def send_card(token, chat_id, article):
    """发送消息卡片到指定群"""
    card = {
        "config": {"wide_screen_mode": True},
        "header": {
            "title": {
                "tag": "plain_text",
                "content": f"🤖 MG Maker Daily · {article['date']}"
            },
            "template": "orange"
        },
        "elements": [
            {
                "tag": "div",
                "text": {
                    "tag": "lark_md",
                    "content": f"**{article['title']}**\n\n{article['summary']}"
                }
            },
            {
                "tag": "action",
                "actions": [
                    {
                        "tag": "button",
                        "text": {
                            "tag": "plain_text",
                            "content": "📖 阅读全文"
                        },
                        "type": "primary",
                        "url": article["url"]
                    },
                    {
                        "tag": "button",
                        "text": {
                            "tag": "plain_text",
                            "content": "📺 看视频"
                        },
                        "type": "default",
                        "url": article.get("video_url", article["url"])
                    }
                ]
            },
            {
                "tag": "hr"
            },
            {
                "tag": "div",
                "text": {
                    "tag": "lark_md",
                    "content": f"💬 *{article['question']}*"
                }
            },
            {
                "tag": "note",
                "elements": [
                    {
                        "tag": "plain_text",
                        "content": f"每3天一篇科技新闻 · 给小小创客的3分钟阅读"
                    }
                ]
            }
        ]
    }

    resp = requests.post(
        f"{BASE_URL}/im/v1/messages",
        params={"receive_id_type": "chat_id"},
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        },
        json={
            "receive_id": chat_id,
            "msg_type": "interactive",
            "content": json.dumps(card)
        }
    )
    data = resp.json()
    if data.get("code") != 0:
        print(f"  ❌ 发送失败: {data.get('msg', data)}")
        return False
    else:
        print(f"  ✅ 发送成功: message_id={data['data']['message_id']}")
        return True

def main():
    # 支持命令行传入文章信息，否则使用默认
    if len(sys.argv) > 1:
        article = json.loads(sys.argv[1])
    else:
        article = {
            "title": "东京人形机器人峰会：机器人会跳舞穿针，中国品牌抢尽风头",
            "date": "2026-06-04",
            "summary": "亚洲首届人形机器人峰会在东京举办！本田灵巧手能穿针引线，中国Mini Pi机器人会跳舞卖萌只卖5500美元——日本发明了机器人，中国企业却把它做成了爆款。",
            "url": "https://hardihuang.github.io/MGMakerDaily/article-humanoids-summit-tokyo.html",
            "video_url": "https://www.bilibili.com/video/BV1QiVn6LEBQ",
            "question": "日本发明了人形机器人，中国企业却把它做成了爆款——你觉得\"先发明\"和\"先量产\"哪个更重要？"
        }

    if not CLASS_GROUPS:
        config = load_config()
        CLASS_GROUPS.update(config.get("class_groups", {}))
    
    if not CLASS_GROUPS:
        print("⚠️ 班级群列表为空，请先在 push-config.json 中配置 chat_id")
        sys.exit(1)

    token = get_token()
    print(f"🔑 Token 获取成功")

    success_count = 0
    for chat_id, class_name in CLASS_GROUPS.items():
        print(f"\n📤 推送到 {class_name} ({chat_id})...")
        if send_card(token, chat_id, article):
            success_count += 1

    print(f"\n📊 推送完成: {success_count}/{len(CLASS_GROUPS)} 个群成功")

if __name__ == "__main__":
    main()
