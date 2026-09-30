---
tags: [search-api, query-design]
---

# Multi-Query検索

1リクエストに複数の関連queryを配列で渡し、独立処理させるAPI呼び出し形式。[[query fan-out]]を**手動で明示**したいときに使う。

- Perplexity Search APIは1リクエスト最大5つのqueryを受け付け、各queryを独立処理する。1リクエスト=1 billing unitでrate limitはquery数ぶん消費 ([[2026-09-30 Perplexity Search API]])。
- 用途: 同じテーマを語彙違い・側面違いで並行取得したいとき、探索の網羅性を底上げしたいとき。
- 設計差: Google AI Modeのquery fan-outは自動分解、Perplexity multi-queryはユーザが分解を作る。

他社の同等機能:

- APIでfan-outを露出する設計は、後のingestで[[2026-09-30 Exa Search API]]のdeep typeや[[2026-09-30 Gemini Deep Research Agent]]のmulti-source searchと対応する。違いは分解責任を誰（vendor or client）が持つか。

経路設計上の含意:

- 探索の段階で[[検索語の展開]]（同義語・言語違い）を行っていれば、Multi-Queryに渡す語彙セットを人が設計できる
- 分解が粗いと重複sourceを並べることになり、コストと[[情報源の評価]]の手間が増える
