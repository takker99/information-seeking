---
tags: [search-api, cost]
---

# 検索depthとcreditのトレードオフ

検索API内でlatency・精度・snippet量・課金をdepth/tierで切替える設計。単位は credits / 秒 / USD / リクエスト数と各社で違うが、共通のトレードオフ軸がある。

- Tavily `search_depth`は `advanced`（2 credits）/ `basic`（1）/ `fast`（1）/ `ultra-fast`（1）。`advanced`と`basic`/`fast`は複数semantically relevant chunks/URL、`ultra-fast`はURLごとにNLP summary 1つ ([[2026-09-30 Tavily Search API]])。
- 課金差: `advanced`のみ2 creditsで、他のtierの2倍。
- 同軸の段階設計: 後述のPerplexity Fast Search tier、Exaの`deep`/`deep-reasoning`。

## auto_parametersによる暗黙昇格

パラメータの自動推定はtier選択を呼び出し側から奪うため、課金の予測可能性に影響する。

- Tavily `auto_parameters: true`でqueryのcontent/intentから自動構成。`include_answer`/`include_raw_content`/`max_results`は**手動指定必須**（response sizeを直接変えるため）。`search_depth`は「結果が改善しそうなら`advanced`に自動昇格」する可能性があり、**2 API credits**を消費する (2026-09-30 Tavily Search API)。
- 設計上の影響: 便利だが、bulk呼び出しでcostが予測不能になる。明示指定が**再現性と予算管理に有利**。
- 他社比較: Exaの`auto` default typeは「balanced」のみでcost変動なし (2026-09-30 Exa Search API)、Perplexityはauto_parametersに相当する機能なし (2026-09-30 Perplexity Search API)。

## Perplexity Fast Search tier

検索API内でlatency・costを犠牲に精度を下げる低コストオプション。大量リクエストのふるい分けや、リアルタイムUIの裏側に向く。

- Perplexity Search APIで `search_type: "fast"` を指定すると低latency・低cost。\$1.00 / 1000リクエスト ([[2026-09-30 Perplexity Search API]])。
- 標準tierと並列で存在し、用途で切り替える。SDK互換性のためのworkaroundも[公式ガイド](https://docs.perplexity.ai/docs/search/fast-search#sdk-support)にある。
- 各社が「精度と速度のtrade-off」をAPIの側面として出している。Tavilyの`search_depth`、Exaの`fast`/`instant` tierが対応する。

使い分け:

- 大量クエリの前段フィルタ: Fastで広く取って、得られにくいsourceは標準/深depthで取り直す
- リアルタイムUI: 1秒以下の応答が要る場面
- 最終根拠の前段: 標準以上の深度で取り直す。重要情報は[[情報源の評価]]で必ず確認

## Exa Multi-step deep search

Web検索を1回のクエリで終わらせず、複数段階の検索・読解・統合（synthesis）を経て回答を作るAPI動作モード。

- Exa `/search`のtype `deep`はmulti-stepな総合リサーチ+synthesis、`deep-reasoning`は強い推論を加える。`deep-lite`は軽量リサーチで約4秒に収まる ([[2026-09-30 Exa Search API]])。
- `additionalQueries`で1-10個の追加queryを渡すと、deep-searchの探索語彙を広げられる。
- latencyと精度のtrade-offはPerplexityのFast Search tierと同様のグラデーション。Exaは`synthesis`までをtypeに含める点が特徴。

[[Deep Research agent]]（Gemini）との対応:

- Deep Research agentはmanaged agent SDK/REST経路で数分のタスクを実行。Exaの`deep`/`deep-reasoning`はsearch endpointのtype選択で同等処理を1リクエストに圧縮
- 用途で分けると、Deep Research agentは外部Tool（Web・MCP・private data）の組み合わせ、Exaのdeepは検索+合成のAPI単体経路

## 経路設計上の含意

- 大量クエリの前段フィルタ: low-cost tierで広く取って、重要sourceのみhigh-cost tierで深掘り
- コストcriticalな経路では明示パラメータで固定し、`auto_parameters`はプロトタイピング・spot利用に限定
- 重要sourceの信頼性検証（情報源の評価）を後段で持つ経路では、`auto_parameters`の暗黙挙動は追跡困難になりがち

## 関連

- [[生検索結果APIと回答APIの分離]]
