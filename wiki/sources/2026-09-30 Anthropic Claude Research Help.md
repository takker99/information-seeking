---
source_url: "https://support.claude.com/en/articles/11088861-use-research-on-claude"
accessed: 2026-09-30
tags: [deep-research, consumer]
---

# Anthropic Claude Research Help

ClaudeのResearch機能のconsumer向けhelpページ。Pro / Max / Team / Enterpriseプランで、Claude web / Desktop / Mobile から使える。

## 要点

### 位置づけ

- ResearchはClaudeのagentic capability。「operates agentically, conducting multiple searches that build on each while determining exactly what to investigate next」
- 異なる角度を自動で探索し、open questionsをsystematically処理。**数分でcitation付きのthorough answerを返す**
- **Web searchがONである必要**。Researchだけ単独では機能しない

### 有効化

- chat左下の`+`ボタン → "Research" をクリック。chat下部に青インジケータ。再クリックで無効化

### データsource

- internal context（接続時）: Gmail、Google Calendar、Google Docs
- web検索

### プラン別

- Pro / Max / Team / Enterprise がweb・Desktop・Mobileで利用可
- 2025-04-15 release時のearly betaは US / Japan / Brazil
- Usage limitは通常会話と同じ。Researchは複数のsourceを取得するため **limit消費が速い**
- Google Workspace連携はTeam / Enterpriseでadminがdomain-wideでenable必要

### Steerの例

- 「Claude, please use the research tool to…」で明示呼び出し
- Google integrationsがONの場合: 「Pull relevant context from [relevant internal knowledge source]」で内部knowledge source指定

### 関連help

- "When should I use web search, extended thinking, and research?" で3機能の使い分けを案内
- "Enable and use web search" でweb search tool自体の設定

## 設計含意

- Web search toolの**enable/precondition**としてResearchが動く構造は、Deep Research agentが「web search上に構築される」設計 ([[2026-09-30 Gemini Deep Research Agent]]のgoogle_search default tool, [[2026-09-30 OpenAI Deep Research API]]のweb_search_preview必須) と同型
- "Pull relevant context from X" の明示は、Anthropicのmulti-agent architecture ([[2026-09-30 Anthropic Multi-Agent Research System]]) で subagent が tool選択を意識する設計の consumer側表現
- プラン別limit消費が速い点は[[マルチソースグラウンディング]]の[[2026-09-30 Anthropic Multi-Agent Research System]]のtoken budget議論と整合
- Web / Desktop / Mobile横断は[[2026-09-30 Google Search AI Mode]] ([[Search履歴ベースの個人化]]) と類似consumer体験の追求

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]
- [[2026-09-30 Anthropic Multi-Agent Research System]]
- [[2026-09-30 Gemini Deep Research Agent]]、[[2026-09-30 OpenAI Deep Research API]]
- [[問いに応じた情報探索経路の設計]]
