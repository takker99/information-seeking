---
source_url: "https://help.openai.com/en/articles/10500283-deep-research-in-chatgpt"
accessed: 2026-09-30
tags: [deep-research, consumer]
---

# OpenAI ChatGPT Deep Research Help

ChatGPT（および Work / Codex）のDeep Research機能のconsumer向けhelpページ。`@Deepresearch`またはtools menuから起動する。

## 要点

### 起動

- Chat / Work / Codex で `@Deepresearch` を入力、またはChatのtools menu `(+)`からDeep Researchを選択
- プランにより利用可否・月次タスク数（Pro/Plus/Team/Enterprise/Edu）

### フロー

1. 必要な成果（最終レポートの構造含む）を述べる
2. Chatはモデルが**proposed research plan**を提示。レビュー・修正可能。website filterや追加source contextも指定可。Work / Codexは初期プロンプト後にclarifying questions
3. 進捗をリアルタイムで監視。中断してfocusを絞る、sourceの追加・除外も可
4. citation/source link付きの構造化レポートを得る

### データsource

- defaultでpublic web + uploaded files
- 接続アプリ: Google Drive / SharePoint / 認証済み業界データサービス。deep research対応アプリのみ可。write actionは使わない（read actionのみ）
- Workspace restrictions / connected-account permissionsに従う
- **Sites filter**: 「restrict to only the websites/domains」または「Prioritize these sites, but allow full-web search」。カンマ区切りでURL列挙

### プラン別の制限

- Chat: プラン依存の月次タスク数。30日ごとにリセット（初回利用日から）
- Work: 既存Work/Codex allowance/creditsを使用。Chat deep researchタスク数とは別
- Enterprise / Edu: adminがRBACで制御。`Workspace settings > Permissions & roles`の`Deep research` permission。Web searchが有効である必要
- Pro: `Data Controls`で学習をoffにできる。Business/Enterprise/Eduはdefaultで学習に使われない

### 良いプロンプトの要素

- 問い・desired outcome・constraintsを明示
- 必要ならrelevant filesを添付
- ChatGPTが clarifying questions する前段で意図を込める
- research planをレビュー・編集してから着手

### SearchとDeep Researchの使い分け

公式の区別: "Use search for quick facts, and use deep research for depth and thoroughness." Searchは短時間・短答 + link、Deep Researchは長時間・詳細レポート。

### 出力

- citation/source link必須
- fullscreen report view
- 「editable report」「presentation」「spreadsheet」などformat指定可（対応範囲に依存）

## 設計含意

- **3-step flow（describe → plan review → monitor）** は[[2026-09-30 Gemini Deep Research Agent]]のplan→multi-source search→iterateと並ぶconsumer体験。ただしChatGPT版は明示的なplan承認ステップを挟む点が特徴
- 「Prioritize these sites, but allow full-web search」は[[2026-09-30 Tavily Search API]]の[[include_domains_mode restrict_prefer]]の **prefer** と同じ意図。複数のDeep Research productで「allowlist hard / priority soft」の二段構えが共通化
- 「read actionのみ・write actionは使わせない」は[[マルチソースグラウンディング]]の安全性で、副作用を許さない契約
- Chat版とAPI版（[[2026-09-30 OpenAI Deep Research API]]）の**中段処理（clarification / prompt rewriting）の差**は重要。consumer版は自動でUX向上、API版はcaller責務
- Apps / Workspace / RBACによる権限管理は[[Search履歴ベースの個人化]]（[[2026-09-30 Google Search AI Mode]]）と同型の企業向け制御

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]
- [[2026-09-30 OpenAI Deep Research API]]
- [[2026-09-30 Gemini Deep Research Agent]]
- [[問いに応じた情報探索経路の設計]]
