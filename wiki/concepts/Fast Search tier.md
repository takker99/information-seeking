---
tags: [search-api, performance]
---

# Fast Search tier

検索API内でlatency・costを犠牲に精度を下げる低コストオプション。大量リクエストのふるい分けや、リアルタイムUIの裏側に向く。

- Perplexity Search APIで `search_type: "fast"` を指定すると低latency・低cost。\$1.00 / 1000リクエスト ([[2026-09-30 Perplexity Search API]])。
- 標準tierと並列で存在し、用途で切り替える。SDK互換性のためのworkaroundも[公式ガイド](/docs/search/fast-search#sdk-support)にある。
- 概念としては[[2026-09-30 Tavily Search API]]のsearch depthや[[2026-09-30 Exa Search API]]の`fast`/`instant` tierに対応し、各社が「精度と速度のtrade-off」をAPIの側面として出している。

使い分け:

- 大量クエリの前段フィルタ: Fastで広く取って、得られにくいsourceは標準/深depthで取り直す
- リアルタイムUI: 1秒以下の応答が要る場面
- 最終根拠の前段: 標準以上の深度で取り直す。重要情報は[[情報源の評価]]で必ず確認

## 関連

- [[生検索結果APIと回答APIの分離]]
