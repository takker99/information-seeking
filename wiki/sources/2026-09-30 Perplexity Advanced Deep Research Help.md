---
source_url: "https://www.perplexity.ai/help-center/en/articles/13600190-what-s-new-in-advanced-deep-research"
accessed: 2026-09-30
tags: [deep-research, consumer]
---

# Perplexity Advanced Deep Research Help

Perplexity Research mode（特に Advanced Deep Research）のconsumer向けupdate案内。2026-09-14付、Help Center indexにも掲載。Research mode全体像は別article（10738684 "What is Research mode?"）に分散。

## 要点

### 処理概要

- "Advanced Deep Research" はPerplexity Researchのmajor update
- 数十〜数百のsourceを検索・読解し、計画を反復改善、coding能力で計算実行、cross-reference、PDF/Perplexity Pageへexport可能な包括レポートを生成
- **Advanced Deep Researchの追加機能**:
  - calculations and data analysis in an improved code sandbox
  - uploaded documentsを直接処理
  - より広範なweb検索
  - run前に clarifying questions
  - research中の follow-up questions
  - 進捗表示と key findingsの逐次表示
  - stream / edit / share可能なレポート

### モデル選択

- Max subscribers: Opus 4.6 Thinking
- Pro subscribers: 4.5 Thinking（gradual rollout）
- Consumer Researchは自動model組合せ選択。手動model切替は不可（API経由 ([[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]]) は別）

### 体験の流れ

1. broad queries → Researchが clarifying questionsを最初に提示
2. **follow-up questionsをresearchが走っている最中に追加可能**（完了待ち不要）
3. research progress表示、どのsourceを読んでいるか、何を学んでいるかを可視化
4. **Key Findings as You Go**: 最終レポート前にfindingsを途中表示
5. reportはfileへ stream、edit・refine・share可

### 用法判断

"Deep Researchは意思決定支援・研究・分析用。adapt depth / tone / format by task type — 学位論文、市場分析、複雑な主題のexploration等"

## 設計含意

- **Follow-up during research** はAnthropicの [[2026-09-30 Anthropic Multi-Agent Research System]] には明示されない ([[2026-09-30 OpenAI ChatGPT Deep Research Help]] も「interruptしてadjust focus」程度)。PerplexityはUXとして途中質問を追加できる点を強調
- **Code sandboxでの計算** は[[2026-09-30 OpenAI Deep Research API]]のcode interpreter、Agent API ([[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]]) のsandboxと並ぶ。複数実装で共通化
- **Progressive disclosure（Key Findings as You Go）** は[[非同期研究タスク]]のpolling/streaming ([[2026-09-30 Gemini Deep Research Agent]]) と並ぶ。中間結果を[[検索過程の記録]]の節目として使える
- Opus 4.6 Thinking / 4.5 Thinkingのような推論強化モデルの選択は、Anthropic評価 ([[2026-09-30 Anthropic Multi-Agent Research System]]) のtoken効率議論と整合

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]、[[非同期研究タスク]]
- [[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]] — API側
- [[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 OpenAI ChatGPT Deep Research Help]]
- [[問いに応じた情報探索経路の設計]]
