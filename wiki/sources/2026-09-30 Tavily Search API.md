---
source_url: "https://docs.tavily.com/documentation/api-reference/endpoint/search"
accessed: 2026-09-30
tags: [web-search, search-api]
---

# Tavily Search API

Tavily Searchの公式`/search` endpoint reference。LLM agent向け検索エンジンとして、検索深度・LLM生成answer・本文取得・領域フィルタを1エンドポイントで制御する。

## 要点

### エンドポイント

- `POST https://api.tavily.com/search`
- 認証: `Authorization: Bearer tvly-YOUR_API_KEY`

### search_depth（精度/速度/creditの段階）

- `advanced`: 最高関連性、latency増、複数semantically relevant chunks/URL（`chunks_per_source`で制御）。**2 API credits**
- `basic`（デフォルト）: バランス。1 credit。複数chunks/URL
- `fast`: 低latency、関連性は良好。1 credit、複数chunks/URL
- `ultra-fast`: latency最優先、URLごとにNLP summaryを1つ。1 credit

### パラメータ

- `query`: 必須
- `chunks_per_source`: 1-3（advanced/basic/fast時）。各sourceの最大chunk数、`<chunk 1> [...] <chunk 2> [...]`の形でcontentに入る
- `max_results`: 0-20、default 10
- `topic`: `general`/`news`/`finance`。`news`は政治・スポーツ等のリアルタイム更新に強い
- `time_range`: `day`/`week`/`month`/`year`または `d`/`w`/`m`/`y`。publish/last updatedでfilter
- `start_date` / `end_date`: `YYYY-MM-DD`
- `include_published_date`: β、各結果に`published_date`を載せる
- `filter_by_published_date`: 日付窓外のresultを除去。`include_published_date`も有効化
- `include_answer`: booleanまたは `basic`/`advanced`。LLM生成short answer
- `include_raw_content`: booleanまたは `markdown`/`text`。cleaned/parsed HTML本文
- `include_images`: 結果画像を含める。`include_image_descriptions`でdescriptionも追加
- `include_favicon`: favicon URL
- `include_domains`: max 300、`exclude_domains`: max 150
- `include_domains_mode`: `restrict`（default、ハードフィルタ）/ `prefer`（他も探索、上位に来るだけ）。`include_domains`未指定で設定すると400
- `country`: 優先国enum（topic=general時のみ）。ISOではなく国名
- `language`: ISO 639-1（`en`）または英語名（`english`）。`filter_by_language: true`でstrict filter
- `auto_parameters`: trueでqueryから自動構成。`include_answer`/`include_raw_content`/`max_results`は手動指定必須。`search_depth`が`advanced`に自動昇格する場合あり（**2 credits**）
- `exact_match`: クエリ内の引用符付きphraseのみマッチ、synonym/意味拡張をバイパス
- `include_usage`: responseにcredit情報を載せる
- `safe_search`: adult/unsafe filter。`fast`/`ultra-fast`では非対応

### response

- `query` / `answer`（`include_answer`時のみ）/ `images`（query-related、description付きも）/ `results[]`（title, url, content, score, raw_content, published_date, favicon, images, id）/ `auto_parameters`（auto_parameters時）/ `response_time` / `usage` / `request_id`

### 関連エンドポイント

OpenAPI specに`Extract`/`Crawl`/`Map`/`Research`/`Feedback`/`Usage`/`Logs`のtagがある。`/search`はquery中心、`/extract`はURLからの本文抽出、`/research`はDeep Research系の経路として別endpointが用意されている。

## 設計含意

- `include_domains_mode: prefer`は[[2026-09-30 Perplexity Search API]]のallowlist/denylistにない中間挙動。「普段は広めに探して、特定domainを優先的に上位に出す」が[[ドメインフィルタ]]より緩く[[情報源の評価]]の前段として使える
- `advanced` depthの**2 credits**課金は[[Fast Search tier]]の低latencyオプションと並ぶ課金設計。深depthのbulk利用は予算影響が大きいため、用途別depth切替が必要
- `auto_parameters`で`search_depth`が自動昇格する場合、credit消費が**黙って2倍**になりうる。明示指定の方が再現性とcost管理に有利
- `topic=finance`は[[content typeで探索先を選ぶ]]のcontent typeに直結する特殊topic。同種のdomain特定topicが他APIにないか比較対象になる
- `/research` endpointは[[2026-09-30 Gemini Deep Research Agent]]のmanaged agent経路に近い位置にある可能性。`/search`とは別物のため個別確認が必要

## 関連

- [[検索depthとcreditのトレードオフ]]、[[include_domains_mode restrict_prefer]]、[[auto_parametersの暗黙昇格]]
- [[2026-09-30 Perplexity Search API]]、[[2026-09-30 Exa Search API]]
- [[問いに応じた情報探索経路の設計]]
