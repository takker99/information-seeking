---
tags: [evaluation, agent]
---

# LLM-as-judge評価rubric

multi-agent/agentic systemのoutput評価にLLM judgeを使う方法。複数の評価軸をrubricとしてまとめてpromptに記述し、score 0.0-1.0 + pass-failを返す。

Anthropic Researchのrubric ([[2026-09-30 Anthropic Multi-Agent Research System]]):

- **Factual accuracy** — claimsがsourceと一致するか
- **Citation accuracy** — cited sourceがclaimと一致するか
- **Completeness** — 要求された側面をすべて扱っているか
- **Source quality** — primary sourceを優先したか、SEO-optimized content farmに偏っていないか
- **Tool efficiency** — 適切なtoolを妥当な回数使ったか

評価の運用tips:

- 小さなtest set（~20 queries）から始める。prompt tweakで大きな効果が出やすい
- 明確な正解がある場合（例: 「S&P 500 IT企業のboard members一覧」）はLLM judgeが答え合わせに十分機能
- 自動化でも**human eval**がedge case（SEO偏り、hallucinated answer、tool failure等）を拾う

経路設計上の位置:

- [[Deep Research agent]]の複数実装（[[2026-09-30 Gemini Deep Research Agent]]、[[2026-09-30 OpenAI Deep Research API]]、[[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 xAI Grok Multi-Agent Research]]）を同一rubricで比較可能にする
- 個人レベルのroute評価（[[検索過程の記録]]）にもLLM judgeが部分適用できる（例: 候補source集合が十分か）
- 自動化偏り（SEO content farm優先）を防ぐ[[情報源の評価]]の自動化に応用可能

## 関連

- [[Deep Research agent]]、[[情報源の評価]]
