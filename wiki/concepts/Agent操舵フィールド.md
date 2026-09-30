---
tags: [search-api, agent-design]
---

# Agent操舵フィールド

検索APIに「目的」と「行動指針」を渡して、ランタイムに探索方針を制御する追加パラメータ群。callerが分解責任を持つ設計。

- Exa `objective`: 呼び手の広い目的（どのdocumentを優先・除外するか、どのfacts/numbersを引き出すか）。agent向けToolとして渡す際はToolの説明文にこの方針を明記 ([[2026-09-30 Exa Search API]])。
- Exa `systemPrompt`: 出力や行動の追加指示（source選好、novelty/duplication制約など）。
- 関連概念: [[2026-09-30 Gemini Deep Research Agent]]のsteerability（tone・format・structured table指定）。

[[Deep Research agent]]のprompt内指示と比べると:

- Deep Research agentはprompt単位でsteer（`background=True`、streaming、tools指定等）
- Exa `objective`/`systemPrompt`は1リクエストのfield単位でsteer。同一endpointを複数agentから呼んでも個別方針を載せられる

設計含意:

- [[content typeで探索先を選ぶ]]を「domainではなく方針で」実装する手段。exploration vs exploitationのバランスをpromptで指示
- 同じ呼び出しで[[情報源の評価]]の閾値を変えられ、用途別のAPI pathを1エンドポイントに集約できる

## 関連

- [[Multi-step deep search]]、[[構造化出力schema]]
