import streamlit as st
import asyncio
import os
import json
from langchain_core.messages import AIMessage

from langchain_mcp_adapters.client import MultiServerMCPClient
from langgraph.prebuilt import create_react_agent

from dotenv import load_dotenv 

load_dotenv()
# 指示文
instruction = "ただし、以下のユーザーの質問に対して「会社情報」「ユーザー情報」「型枠情報」\
              「取引評価」「付属部品」「図面データ」「型枠画像」「型枠動画」\
               テーブルを参考に答えてください。"

# 履歴保存用ファイル
HISTORY_FILE = "history.json"

# --- 共通の関数定義 ---

def save_to_history(question: str, answer: str):
    """履歴をJSONファイルに保存する関数"""
    entry = {"question": question, "answer": answer}
    history = load_history()
    history.append(entry)
    with open(HISTORY_FILE, "w", encoding="utf-8") as f:
        json.dump(history, f, ensure_ascii=False, indent=2)

def load_history():
    """JSONファイルから履歴を読み込む関数"""
    if os.path.exists(HISTORY_FILE):
        try:
            with open(HISTORY_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except json.JSONDecodeError:
            return []
    return []

def format_history_for_prompt(history):
    """プロンプト用に履歴を整形する関数（直近5件）"""
    formatted = ""
    for item in history[-2:]:
        formatted += f"ユーザー: {item['question']}\nAI: {item['answer']}\n"
    return formatted

async def run_database_query(user_input: str):
    """
    データベースに問い合わせを行い、結果をStreamlitに表示する非同期関数
    """
    history = load_history()
    formatted_history = format_history_for_prompt(history)
    prompt = f"{formatted_history}ユーザー: {user_input}\nAI: {instruction}"

    client = MultiServerMCPClient(
        {
            "mysql": {
                "command": "python",
                "args": ["./mcp-mysql-server-master/main.py"],
                "env": {
                    "DB_HOST": os.getenv("DB_HOST", "test"),
                    "DB_PORT": os.getenv("DB_PORT", "3306"),
                    "DB_USER": os.getenv("DB_USER", "test"),
                    "DB_PASSWORD": os.getenv("DB_PASSWORD", "test"),
                    "DB_NAME": os.getenv("DB_NAME", "test_db")
                },
                "transport": "stdio",
            }
        }
    )

    tools = await client.get_tools()
    agent = create_react_agent("openai:gpt-4.1", tools)

    sql_response = await agent.ainvoke({"messages": prompt})
    ai_messages =  [msg for msg in sql_response["messages"] if isinstance(msg, AIMessage)]
    for msg in ai_messages:
        #print(f"[AI {i}] {msg.content}")
        st.write(msg.content)
        save_to_history(user_input, msg.content)

# --- Streamlit UI の定義 ---

# サイドバー
st.sidebar.title("森山工業株式会社")
st.sidebar.markdown("### エージェントを選択")
page = st.sidebar.radio(
    "label_for_system",
    ["DB エージェント", "クレーム対応エージェント"],
    label_visibility="collapsed"
)

# 水平線
st.sidebar.markdown("---")

# ページごとの表示切替
if page == "DB エージェント":
    st.title("🔍 DBの内容について回答します")
    
    # 元のアプリのUIをここに配置
    user_input = st.text_area("入力欄", help="例えば「部品Cを所持しているのはどの会社ですか？」")

    if st.button("送信"):
        if user_input:
            with st.spinner("データベース検索中..."):
                asyncio.run(run_database_query(user_input))
        else:
            st.warning("質問を入力してください。")
            
    # 履歴表示
    st.markdown("---")
    st.subheader("質問履歴")
    history = load_history()
    for idx, item in enumerate(history):
        with st.expander(f"Q{idx + 1}: {item['question']}"):
            st.markdown(f"**A:**\n{item['answer'] if item['answer'] else '（回答なし）'}")


elif page == "クレーム対応エージェント":
    st.title("📝 お客様対応エージェント")
    
    claim_input = st.text_input("お問い合わせ内容を入力してください")

    if st.button("送信"):
        if claim_input:
            # ここにクレーム対応用の処理を実装
            st.success(f"以下のお問い合わせ内容を受け付けました：\n\n> {claim_input}")
        else:
            st.warning("お問い合わせ内容を入力してください。")