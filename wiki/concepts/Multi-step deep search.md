---
tags: [search-api, deep-research]
---

# Multi-step deep search

Web検索を1回のクエリで終わらせず、複数段階の検索・読解・統合（synthesis）を経て回答を作るAPI動作モード。

- Exa `/search`のtype `deep`はmulti-stepな総合リサーチ+synthesis、`deep-reasoning`は強い推論を加える。`deep-lite`は軽量リサーチで約4秒に収まる ([[2026-09-30 Exa Search API]])。
- `additionalQueries`で1-10個の追加queryを渡すと、deep-searchの探索語彙を広げられる。
- latencyと精度のtrade-offは[[Fast Search tier]]（Perplexity）と同様のグラデーション。Exaは`synthesis`までをtypeに含める点が特徴。

[[Deep Research agent]]（Gemini）との対応:

- Deep Research agentはmanaged agent SDK/REST経路で数分のタスクを実行。Exaの`deep`/`deep-reasoning`はsearch endpointのtype選択で同等処理を1リクエストに圧縮
- 用途で分けると、Deep Research agentは外部Tool（Web・MCP・private data）の組み合わせ、Exaのdeepは検索+合成のAPI単体経路

## 関連

- [[構造化出力schema]]、[[Agent操舵フィールド]]
