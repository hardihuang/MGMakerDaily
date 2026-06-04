#!/usr/bin/env python3
# MG Maker Daily 飞书推送脚本
# 自动扫描Bot所在的所有群，批量推送消息卡片
# 无需维护群列表，加群即推，退群即停

import json
import sys
import time
import requests

APP_ID = "cli_aaaba5837eb95cfa"
APP_SECRET = "l3SMAbmc8ag9RQ4UWPR7hblV5MFCw0pd"
BASE_URL = "https://open.feishu.cn/open-apis"

# 排除的群关键词（非班级群不推送）
EXCLUDE_KEYWORDS = ["研发", "项目组", "ICC-", "反馈群", "服务群", "沟通群", "打印", "对接", "商城"]

def get_token():
    resp = requests.post(
        f"{BASE_URL}/auth/v3/tenant_access_token/internal",
        json={"app_id": APP_ID, "app_secret": APP_SECRET}
    )
    data = resp.json()
    if data.get("code") != 0:
        print(f"❌ 获取token失败: {data}")
        sys.exit(1)
    return data["tenant_access_token"]

def get_bot_groups(token):
    """扫描Bot所在的所有群"""
    groups = []
    page_token = ""
    while True:
        params = {"page_size": 50}
        if page_token:
            params["page_token"] = page_token
        
        resp = requests.get(
            f"{BASE_URL}/im/v1/chats",
            params=params,
            headers={"Authorization": f"Bearer {token}"}
        )
        data = resp.json()
        if data.get("code") != 0:
            print(f"❌ 获取群列表失败: {data}")
            break
        
        for item in data.get("data", {}).get("items", []):
            groups.append({
                "name": item["name"],
                "chat_id": item["chat_id"]
            })
        
        if not data.get("data", {}).get("has_more"):
            break
        page_token = data.get("data", {}).get("page_token", "")
    
    return groups

def should_push(group_name):
    """判断是否应该推送到该群"""
    for kw in EXCLUDE_KEYWORDS:
        if kw in group_name:
            return False
    return True

def send_card(token, chat_id, article):
    """发送消息卡片"""
    card = {
        "config": {"wide_screen_mode": True},
        "header": {
            "title": {"tag": "plain_text", "content": f"🤖 MG Maker Daily · {article['date']}"},
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
                        "text": {"tag": "plain_text", "content": "📖 阅读全文"},
                        "type": "primary",
                        "url": article["url"]
                    },
                    {
                        "tag": "button",
                        "text": {"tag": "plain_text", "content": "📺 看视频"},
                        "type": "default",
                        "url": article.get("video_url", article["url"])
                    }
                ]
            },
            {"tag": "hr"},
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
                    {"tag": "plain_text", "content": "每3天一篇科技新闻 · 给小小创客的3分钟阅读"}
                ]
            }
        ]
    }

    resp = requests.post(
        f"{BASE_URL}/im/v1/messages?receive_id_type=chat_id",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        json={
            "receive_id": chat_id,
            "msg_type": "interactive",
            "content": json.dumps(card)
        }
    )
    data = resp.json()
    return data.get("code") == 0, data

def main():
    # 支持命令行传入文章信息
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

    token = get_token()
    print(f"🔑 Token 获取成功")

    # 扫描所有群
    all_groups = get_bot_groups(token)
    print(f"📡 扫描到 {len(all_groups)} 个群")

    # 过滤出班级群
    push_groups = [g for g in all_groups if should_push(g["name"])]
    skip_groups = [g for g in all_groups if not should_push(g["name"])]
    
    print(f"🎯 将推送到 {len(push_groups)} 个班级群")
    if skip_groups:
        print(f"⏭️ 跳过 {len(skip_groups)} 个非班级群: {', '.join(g['name'] for g in skip_groups)}")

    # 批量推送
    success = 0
    for g in push_groups:
        ok, resp = send_card(token, g["chat_id"], article)
        if ok:
            print(f"  ✅ {g['name']}")
            success += 1
        else:
            print(f"  ❌ {g['name']}: {resp.get('msg', 'unknown error')}")
        time.sleep(0.5)  # 防止限频

    print(f"\n📊 推送完成: {success}/{len(push_groups)} 个群成功")
    return success

if __name__ == "__main__":
    main()
