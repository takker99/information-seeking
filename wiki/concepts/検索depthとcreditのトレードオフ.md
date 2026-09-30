---
tags: [search-api, cost]
---

# 検索depthとcreditのトレードオフ

検索API内でlatency・精度・snippet量をdepth tierで切替え、課金を連動させる設計。

- Tavily `search_depth`は `advanced`（2 credits）/ `basic`（1）/ `fast`（1）/ `ultra-fast`（1）。`advanced`と`basic`/`fast`は複数semantically relevant chunks/URL、`ultra-fast`はURLごとにNLP summary 1つ ([[2026-09-30 Tavily Search API]])。
- 課金差: `advanced`のみ2 credits。`auto_parameters`有効化で`advanced`に**暗黙昇格**する場合があり、costが2倍になりうる ([[2026-09-30 Tavily Search API]])。
- 類似の段階設計: [[Fast Search tier]]（Perplexity）、[[Multi-step deep search]]（Exaの`deep`/`deep-reasoning`）。単位は credits / 秒 / USD と各社で違うが、共通のトレードオフ軸がある。

経路設計上の含意:

- 大量クエリの前段フィルタ: low-cost tierで広く取って、重要sourceのみhigh-cost tierで深掘り
- `auto_parameters`を**業務利用で常時有効化するのは避ける**: 暗黙のcredit消費増を避けるため、`search_depth`等を明示指定する方が再現性と予算管理に有利

## 関連

- [[auto_parametersの暗黙昇格]]、[[生検索結果APIと回答APIの分離]]
