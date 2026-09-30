---
tags: [agent, citation]
---

# 引用位置特定のCitationAgent

multi-agent researchで、最終回答に出てくる各claimに対し文書中の引用位置（span・出典）を特定する専用agent。

- Anthropic Researchのflow: LeadResearcherがsubagentのfindingsを集約 → **CitationAgent** がdocumentとreportを処理して引用位置を特定 → 全claimがsourceにattributionされる ([[2026-09-30 Anthropic Multi-Agent Research System]])
- 一般の[[Deep Research agent]]ではinline citationを生成するため[[構造化出力schema]]（[[2026-09-30 Exa Search API]]のfield grounding、`confidence`付き）と類似

効果:

- lead agentにcitation特定を兼任させるとtoken消費・認知負荷が上がる。専用agentに分離することでqualityとfidelityが上がる
- subagentが個別に行った検索結果をCitationAgentが一括処理するため、引用の整合性が保証されやすい
- [[情報源の評価]]の単位（URL全体ではなく文中span）を**機械的に**付与できる

設計含意:

- consumer向け[[2026-09-30 OpenAI ChatGPT Deep Research Help]]もcitation必須を強調
- AI ModeのPersonal Intelligence ([[2026-09-30 Google Search AI Mode]])はsource linkを回答に付与するが、span特定は明示されない
- 評価rubric ([[LLM-as-judge評価rubric]]) で「citation accuracy = cited sources match claims?」が評価軸になる

## 関連

- [[構造化出力schema]]、[[情報源の評価]]
