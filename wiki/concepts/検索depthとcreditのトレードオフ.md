---
tags: [search-api, cost]
---

# 検索depthとcreditのトレードオフ

検索API内でlatency・精度・snippet量をdepth tierで切替え、課金を連動させる設計。

- Tavily `search_depth`は `advanced`（2 credits）/ `basic`（1）/ `fast`（1）/ `ultra-fast`（1）。`advanced`と`basic`/`fast`は複数semantically relevant chunks/URL、`ultra-fast`はURLごとにNLP summary 1つ ([[2026-09-30 Tavily Search API]])。
- 課金差: `advanced`のみ2 creditsで、他のtierの2倍。
- 類似の段階設計: [[Fast Search tier]]（Perplexity）、[[Multi-step deep search]]（Exaの`deep`/`deep-reasoning`）。単位は credits / 秒 / USD と各社で違うが、共通のトレードオフ軸がある。

## auto_parametersによる暗黙昇格

パラメータの自動推定はtier選択を呼び出し側から奪うため、課金の予測可能性に影響する。

- Tavily `auto_parameters: true`でqueryのcontent/intentから自動構成。`include_answer`/`include_raw_content`/`max_results`は**手動指定必須**（response sizeを直接変えるため）。`search_depth`は「結果が改善しそうなら`advanced`に自動昇格」する可能性があり、**2 API credits**を消費する (2026-09-30 Tavily Search API)。
- 設計上の影響: 便利だが、bulk呼び出しでcostが予測不能になる。明示指定が**再現性と予算管理に有利**。
- 他社比較: Exaの`auto` default typeは「balanced」のみでcost変動なし ([[2026-09-30 Exa Search API]])、Perplexityはauto_parametersに相当する機能なし ([[2026-09-30 Perplexity Search API]])。

経路設計上の含意:

- 大量クエリの前段フィルタ: low-cost tierで広く取って、重要sourceのみhigh-cost tierで深掘り
- コストcriticalな経路では明示パラメータで固定し、`auto_parameters`はプロトタイピング・spot利用に限定
- 重要sourceの信頼性検証（[[情報源の評価]]）を後段で持つ経路では、`auto_parameters`の暗黙挙動は追跡困難になりがち

## 関連

- [[生検索結果APIと回答APIの分離]]
