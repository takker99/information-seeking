---
source_url: "https://blog.scopus.com/accelerate-your-workflow-with-deep-research-a-new-scopus-ai-feature/"
accessed: 2026-09-30
tags: [deep-research, scholarly-search]
---

# Scopus AI Deep Research（Blog announcement）

Elsevier Scopus AIのDeep Research機能（2025-08-28 launch announcement）。Scopus収録のpeer-reviewed curated literatureに限定した、学術領域特化のDeep Research agent。

## 要点

### 位置づけ

- "amplify your thinking, not replace it" — 伝統的なliterature reviewを**置き換えず**、scoping / connections / gaps / synthesis insightsで研究者の思考を補助
- proprietary reasoning engine + agentic AI
- 入力はnatural language。Boolean/keywordを手書きする必要なし
- **Scopus収録のpeer-reviewed curated abstractsに限定**（since 2003）
- リアルタイムでAI actionを画面表示

### 動作

- queryを**simple componentsに分解**
- vector search + keyword search + 両方（hybrid）を選択肢として持つ
- 結果に応じて戦略を**adapt**（"based on the new information it surfaces"）
- curated abstractsをscan
- 10-20 individual componentsに分解したmulti-page report

### レポートの内容

- direct answers with **transparent scope and assumptions**
- unexpected connections / patterns
- **research limitations and gaps**（次の研究機会の提示）
- **synthesized insights with actionable next steps**
- 各claimにreference + **confidence score**が付く（full transparency）

### 絞り込み

natural language queryで:
- Country
- Time range
- Document type
- Citation count

### Conversational follow-up

- report生成後、追加質問可能
- Deep Researchが「蓄積researchで足りるか」「新searchが必要か」を自動判定
- 質問がreport自体への変更を求める場合は**新report**を生成（既存reportのeditは不可）
- Deep Researchは**research phaseで学んだ内容を次stepの探索判断に使う**

### 比較用注意点

- **no literature-review replacement** philosophyは[[Deep Research agent]]実装の中で独特
- vector + keyword hybrid searchは[[Semantic Search（embeddingベース）]]と[[検索テクニック]]のhybridに相当するが、engine内部の統合
- 各claimへのconfidence score付与は[[構造化出力schema]]（[[2026-09-30 Exa Search API]]のfield grounding）と類似だが、Scopusはin-house reasoning engineが出す

## 設計含意

- 限定source（curated abstracts only）は[[マルチソースグラウンディング]]の「少数source深掘り」極端。Anthropic Researchのweb + Workspace統合、Perplexityのweb + premium data、OpenAIのweb + file search + MCPと比べて、最も**閉じたsource graph**
- **confidence score per claim** は[[情報源の評価]]を中間生成物に埋め込む設計。[[LLM-as-judge評価rubric]]が開発時の評価軸であるのに対し、Scopusはend-user-facingの透明性軸
- "research limitations and gaps"を強調する姿勢は[[生成AIで問いと検索語を作る]]の延長で、次の問いの種を明示する
- literature review replacementを避けるphilosophyは[[学術メタデータAPIの書誌グラフ]]（[[2026-09-30 OpenAlex API]]、[[2026-09-30 Crossref REST API]]）での探索と役割分担が必要。Deep Research = 探索の加速、literature review = 人の仕事
- "natural languageで絞り込み指定" は[[生成AIで問いと検索語を作る]]の延長。Boolean ([[検索テクニック]]) ではなくsemantic + structured intentでfilter

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]、[[Semantic Search（embeddingベース）]]
- [[claimごとのconfidence score（research report）]]
- [[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 OpenAI Deep Research API]]、[[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]]
- [[問いに応じた情報探索経路の設計]]
