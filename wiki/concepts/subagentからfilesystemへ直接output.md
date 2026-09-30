---
tags: [agent, design]
---

# subagentからfilesystemへ直接output

multi-agent systemで、subagentの出力artifactをfilesystem等に直接書き出し、lead agentは軽量referenceだけを受け取る設計。"game of telephone"を避ける。

- Anthropic Researchのappendix ([[2026-09-30 Anthropic Multi-Agent Research System]])が紹介
- 効果: 中継時の情報loss防止、conversation history経由のtoken overhead削減、structured output（code・reports・visualizations）で特に有効

[[Deep Research agent]]一般の含意:

- [[非同期研究タスク]]（[[2026-09-30 Gemini Deep Research Agent]]）のpolling/streamingでresponse本体を返す設計と対比。Anthropic式はartifact永続化により、report・dataset・chartを直接共有できる
- [[マルチソースグラウンディング]]の[[MCPサーバー経由のsource拡張]]と組み合わせると、subagentがMCP経由で外部sourceからartifactを取得 → filesystemに書く → lead agentが軽量referenceで要約、という流れが組める
- 個人レベルの[[検索過程の記録]]（[[2026-09-30 Illinois Library Search Strategies]]）にsearch journalとしてartifact化する際にも類似の効用

設計上の制約:

- filesystem書き込み権限をagentに与える必要があり、[[情報源の評価]]の観点で副作用リスク管理が必須
- code execution sandbox ([[2026-09-30 OpenAI Deep Research API]]のcode interpreter等) の中で閉じると安全

## 関連

- [[マルチソースグラウンディング]]、[[MCPサーバー経由のsource拡張]]
