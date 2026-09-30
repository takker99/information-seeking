---
tags: [search-api, hidden-cost]
---

# auto_parametersの暗黙昇格

検索APIが「自動でパラメータを推定」するオプション。`search_depth`の暗黙昇格によりcostが2倍になる注意点がある。

- Tavily `auto_parameters: true`でqueryのcontent/intentから自動構成。`include_answer`/`include_raw_content`/`max_results`は**手動指定必須**（response sizeを直接変えるため）。`search_depth`は「結果が改善しそうなら`advanced`に自動昇格」する可能性があり、**2 API credits**を消費する ([[2026-09-30 Tavily Search API]])。
- 設計上の影響: 便利だが、bulk呼び出しでcostが予測不能になる。明示指定が**再現性と予算管理に有利**。
- 類似概念: 他社のauto-tuning（[[2026-09-30 Exa Search API]]の`auto` default typeは「balanced」のみでcost変動なし）、[[2026-09-30 Perplexity Search API]]はauto_parametersに相当する機能なし。

経路設計上の含意:

- コストcriticalな経路では明示パラメータで固定し、`auto_parameters`はプロトタイピング・spot利用に限定
- 重要sourceの信頼性検証（[[情報源の評価]]）を後段で持つ経路では、`auto_parameters`の暗黙挙動は追跡困難になりがち
