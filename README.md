# ストリームリットを使ったRAGのプロトタイプ

## 環境構築手順
- python 3.11
- エントリーポイントはmain_app.py
- SQL生成はmcp-mysql-server-master/main.py

### MySQLのコンテナを立てる
- docker環境がある人のみ
- streamlitはローカルで開発。dockerを使いたい人はcomposeファイルに追記。
```bash
docker compose up -d
```

### 仮想環境を構築して、ライブラリをinstall
```python
# 仮想環境をアクティベート : venv,anaconda
pip install -r requirements.txt
```

### streamlitのサーバーを起動
```python
streamlit run main_app.py
```