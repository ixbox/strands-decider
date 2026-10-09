# strands-decider

[strands-decider](https://github.com/strands-labs/strands-decider) の HTTP サーバーを Docker Compose で起動するための構成です。

strands-decider は、選択肢からの選択（choice）、Yes/No の判定（noul）、尺度での評価（score）を信頼度つきで返す小型の判定モデルです。
このリポジトリでは `StrandsAgents/strands-decider-2B-hobson-v21` を `strands-decider serve` で配信します。

## 必要なもの

- Docker と Docker Compose
- Hugging Face のアクセストークン（`HF_TOKEN`）

## 起動

`.env` に Hugging Face のトークンを書きます。
`.env` は `.gitignore` に含まれているのでコミットされません。

```sh
echo 'HF_TOKEN=hf_xxxxxxxx' > .env
```

ビルドして起動します。

```sh
docker compose up --build
```

サーバーは `http://localhost:8000` で待ち受けます。
初回起動時にモデルをダウンロードするので、応答できるようになるまで時間がかかります。

## リクエスト例

```sh
curl -s localhost:8000/v1/systemone \
  -H 'content-type: application/json' \
  -d '{
    "state": "Help! My payouts have been failing for 3 days!",
    "questions": {
      "is_urgent": {"type": "noul", "instructions": "Does this convey urgency?"}
    }
  }'
```

```json
{
  "model": "strands-decider-2B-hobson-v21",
  "answers": {
    "is_urgent": {
      "type": "noul",
      "noul": 0.8277
    }
  },
  "usage": {
    "input_tokens": 86,
    "output_tokens": 1
  },
  "latency_ms": 140.03
}
```

`noul` は 1 に近いほど Yes 寄りです。
質問の種類と書き方は [strands-decider の README](https://github.com/strands-labs/strands-decider) を参照してください。

## モデルキャッシュ

ダウンロードしたモデルは名前付きボリューム `huggingface`（コンテナ内の `/cache/huggingface`）に保存されます。
コンテナを作り直しても再ダウンロードは発生しません。

キャッシュを消すときはボリュームごと削除します。

```sh
docker compose down -v
```

## 別のモデルを使う

モデル名は `Dockerfile` の `CMD` で指定しています。
一時的に変えるだけなら、`docker compose run` でコマンドを上書きできます。

```sh
docker compose run --rm --service-ports strands-decider \
  strands-decider serve StrandsAgents/strands-decider-2B-hobson-v19 --host 0.0.0.0 --port 8000
```
