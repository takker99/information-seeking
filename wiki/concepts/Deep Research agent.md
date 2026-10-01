---
tags: [deep-research, agent]
---

# Deep Research agent

複雑な問いに対し、計画立案→複数sourceの検索→反復読解→出力というworkflowを自動実行するAI agent。同期的なチャット応答ではなく、数分〜数十分の応答を作る。

## マルチベンダー実装（2026-09-30確認）

| 実装 | 提供形 | 設計特徴 | 出典 |
| --- | --- | --- | --- |
| Gemini Deep Research Agent | Agent Platform (managed SDK / REST, v1beta1, global) | [[マルチソースグラウンディング]] (Google Search / Enterprise Web Search / Agent Search / remote MCP / file upload)。Polling/streaming + deferred tier | [[2026-09-30 Gemini Deep Research Agent]] |
| OpenAI Deep Research | Responses API (`o3-deep-research` / `o4-mini-deep-research`、legacy → `gpt-5.6-sol`置換) | web_search_preview / file_search / code_interpreter / **remote MCP (specialized search+fetch interface)**。3-step (clarification / prompt rewriting / research) はChatGPTのみ、APIはcaller側で実装 | [[2026-09-30 OpenAI Deep Research API]]、[[2026-09-30 OpenAI ChatGPT Deep Research Help]] |
| Anthropic Claude Research | Claude web/Desktop/Mobile (`+` → Research) + Engineering blog | **orchestrator-worker multi-agent architecture**: LeadResearcher + specialized Subagents + CitationAgent。extended thinking / interleaved thinking。90.2% performance gain vs single-agent (internal eval) | [[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 Anthropic Claude Research Help]] |
| Perplexity Advanced Deep Research | Consumer + Agent API (`high`/`xhigh` preset) | code sandbox、clarifying questions、follow-up during research、key findings as you go。Opus 4.6 Thinking / 4.5 Thinking 自動選択。Sonar Chat Completions → Agent API migration (2026-09-27) | [[2026-09-30 Perplexity Advanced Deep Research Help]]、[[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]] |
| xAI Grok Multi-Agent Research | API (`grok-4.20-multi-agent`, beta) | **4 or 16 agents** 切替。leader agentの出力のみ露出、sub-agent stateはencrypted。built-in tools: web_search / x_search / code_execution / collections_search + remote MCP | [[2026-09-30 xAI Grok Multi-Agent Research]] |
| Scopus AI Deep Research | Scopus内 (Elsevier, scholarly) | **peer-reviewed Scopus curated abstracts限定** (since 2003)。vector + keyword hybrid search。各claimにreference + **confidence score**付与。literature review replacementは避けるphilosophy | [[2026-09-30 Scopus AI Deep Research]] |

## 共通する設計要素

- **複数sourceのgrounding**: web searchが基本、file / MCP / private data / 業界data / curated abstracts まで拡張
- **Iterative process**: 1回の応答で完結せず、計画・検索・読解・戦略修正のloop
- **Plan→Search→Iterate→Output** のloopを基盤骨格に、各社が拡張
- **Inline citations + report outputs**: 出典付き、citation formatは実装依存
- **Steerability**: promptまたはUIでtone・format・depth・source選好を制御
- **Async / background mode**: 同期実行だとtimeoutするためpolling/streaming + webhook/deferred/background mode

## 設計のバリエーション軸

1. **Multi-agent粒度**: Gemini/OpenAI/Perplexityはmanaged model内にloop。Anthropicはorchestrator-workerを**明示**。xAIは4/16 agentsの離散値。Scopusはsingle reasoning engine
2. **Sourceの開閉**: Scopus = closed curated / Perplexity/OpenAI/Anthropic = web+premium data+MCP / Grok = web+X+code / Gemini = web+Workspace+file
3. **Citationの粒度**: 単純なURL列挙 (Gemini/Help) ↔ inline annotation ([[2026-09-30 OpenAI Deep Research API]] の`annotations` array) ↔ [[引用位置特定のCitationAgent]] (Anthropic) ↔ field grounding+confidence ([[2026-09-30 Exa Search API]]) ↔ reference+confidence score per claim ([[2026-09-30 Scopus AI Deep Research]])
4. **Prompting中間段**: ChatGPT版は3-step (clarification / prompt rewriting / research) を内部実行、API版はcaller責務。Perplexity Advancedは clarifying questionsをUX化
5. **Cost model**: token消費 ([[2026-09-30 Anthropic Multi-Agent Research System]] は multi-agent ~15x chat) ↔ tool call数課金 ([[2026-09-30 xAI Grok Multi-Agent Research]]) ↔ credit ([[2026-09-30 Tavily Search API]]のsearch_depth)
6. **途中のsteer**: Perplexityはresearch中のfollow-up、OpenAIはplan review / interrupt、Anthropicは設計上lead agentが動的にsubagent生成・戦略修正

## 経路設計上の位置

- [[マルチソースグラウンディング]]の具象化。[[MCPサーバー経由のsource拡張]] ([[2026-09-30 Gemini Deep Research Agent]]、[[2026-09-30 OpenAI Deep Research API]]) で学術・企業内dataへの経路を拡張できる
- [[content typeで探索先を選ぶ]]の「総合report」層を担う。[[検索語の展開]] → Deep Research → 結果検証 ([[情報源の評価]]) → 必要なら[[引用追跡]]で深掘り、が典型flow
- [[検索結果の広げ方と絞り方]]の自動化。Scopusの[[claimごとのconfidence score（research report）]]がconsumer向けの[[情報源の評価]]材料を提供
- 個人レベルの[[検索過程の記録]] ([[2026-09-30 Illinois Library Search Strategies]]) はDeep Researchの実行過程を模倣するテンプレート

## 共通する制約

- **Preview/beta/legacy**: 多くはPreview・beta・model deprecation予定 ([[2026-09-30 OpenAI Deep Research API]] は2026-07-23 shutdown、Perplexity Sonar Chat Completionsは2026-09-27 shutdown)。長期route評価ではmodel/preset移行の追跡が必須
- **機微データ・proprietary data**: Preview段階では入力禁止 ([[2026-09-30 Gemini Deep Research Agent]])、MCP経由の私的dataは read-onlyアクセス ([[2026-09-30 OpenAI Deep Research API]])
- **Consumer版 ≠ API版**: ChatGPT版の3-step中間処理やPro model availabilityなどはAPI版に[[生成AIで問いと検索語を作る]]相当の前段処理をcaller責務で再現する必要がある

## 関連

- [[マルチソースグラウンディング]]、[[非同期研究タスク]]、[[マルチソースグラウンディング]]、[[LeadResearcher_Subagent 役割分担（orchestrator-worker）]]、[[引用位置特定のCitationAgent]]、[[claimごとのconfidence score（research report）]]
- [[2026-09-30 Gemini Deep Research Agent]]、[[2026-09-30 OpenAI Deep Research API]]、[[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 xAI Grok Multi-Agent Research]]、[[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]]、[[2026-09-30 Scopus AI Deep Research]]
- [[SMS-2026S-report Scopus AI Deep Research論文探索]] — 学術限定DRを13ラウンド実行した実地ケース。「地図」として使いfulltextで根拠を確認する二段構成
- [[問いに応じた情報探索経路の設計]]
