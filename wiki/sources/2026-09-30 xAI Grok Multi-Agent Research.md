---
source_url: "https://docs.x.ai/developers/model-capabilities/text/multi-agent"
accessed: 2026-09-30
tags: [deep-research, multi-agent, api]
---

# xAI Grok Realtime Multi-Agent Research

xAI公式の `grok-4.20-multi-agent` モデル仕様（Realtime Multi-agent Research）。**beta**でAPI interface・挙動は将来変更の可能性あり。Anthropic Researchが「lead agent + subagents + CitationAgent」の内部構成を公開しているのに対し、xAIは同等のmulti-agent orchestrationを**単一model endpoint**として提供。

## 要点

### 役割

- Grokが複数AI agentをリアルタイムでorchestrateし、deep / multi-step研究を実行
- 各agentは「web検索」「データ分析」「findings合成」等を専門化、協働して引用付きの回答を作る
- 標準のsingle-turn tool useを超え、複数agentがfindingsを**cross-reference**・**iterate**

### 使い方

- model: `grok-4.20-multi-agent`
- API: xAI SDK / OpenAI Responses互換 / REST
- built-in tools: `web_search`、`x_search`、`code_execution`、`collections_search`、remote MCP（client-side tools / custom tools は**未対応**）
- multi-turn conversation: `previous_response_id` で継続
- `max_tokens` パラメータは**未対応**

### Output behavior（設計上の重要点）

- **leader agentのtool calls + final responseのみが返す**
- sub-agent state（intermediate reasoning・tool calls・outputs）は**encrypted**で、 `use_encrypted_content=True` を指定したときだけresponseに含まれる
- defaultでresponseをcleanに保ちつつ、multi-turn時にsub-agentの内部状態を送れる

### 構成: 4 agents vs 16 agents

| Setup | Agent数 | 用途 | SDK parameter |
| --- | --- | --- | --- |
| 4 agents | quick research・focused queries | xAI SDK `agent_count=4` / OpenAI SDK `reasoning.effort: low\|medium` / Vercel AI SDK `reasoningEffort: low\|medium` / REST `reasoning.effort` |
| 16 agents | deep research・complex multi-faceted | xAI SDK `agent_count=16` / OpenAI SDK `reasoning.effort: high\|xhigh` / Vercel AI SDK `reasoningEffort: high\|xhigh` / REST `reasoning.effort` |

注: 16-agentは大幅にtoken消費が増える。task complexityで選択。

### Pricing

- leader agent + sub-agentsすべてのtoken（input / output / reasoning）が課金対象
- leader / sub-agentに関わらずserver-side tool callも課金
- `usage` / `server_side_tool_usage` fieldで監視

### Prompting Guide

- スコープ・深さを明示
- structured output（比較表等）を要求
- sourceや視点を指定（"academic papers 2024-2025"等）
- 複雑な問いはmulti-turnで段階的に
- contextをpromptに含める

### Limitations

- 出力はleader agentのみ露出（sub-agent stateはencrypted）
- client-side tools / custom tools 未対応
- Chat Completions API 未対応（xAI SDKかResponses APIを使う）
- `max_tokens` 未対応

## 設計含意

- [[Deep Research agent]]のmulti-agent実装で、Anthropic Research ([[2026-09-30 Anthropic Multi-Agent Research System]]) と並び立つ存在。Anthropicがsubagentを内部で**明示**spawnするのに対し、xAIは`grok-4.20-multi-agent`として**単一model endpointに隠蔽**。クライアントから見るとsub-agentが「何台いるか」「何を使ったか」は暗号化されている
- 4 vs 16 agentsの[[Agent操舵フィールド]]は、Anthropicの "scale effort to query complexity" (simple fact=1 agent / comparison=2-4 / complex=10+) と相似形。xAIは離散的な2値で抽象化
- [[マルチソースグラウンディング]]の `web_search` + `x_search`（X/Twitter） + `code_execution` + `collections_search` + MCP の組合せは、Anthropicのorchestrator-workerに並ぶsource幅
- tool pricing for server-side callsは、Perplexity Agent API ([[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]]) のtools arrayとも類似。[[検索depthとcreditのトレードオフ]]をtokenではなく **tool call数**で評価する軸

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]、[[MCPサーバー経由のsource拡張]]、[[Agent操舵フィールド]]
- [[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 Gemini Deep Research Agent]]、[[2026-09-30 OpenAI Deep Research API]]、[[2026-09-30 Perplexity Sonar Deep Research to Agent API Migration]]
- [[問いに応じた情報探索経路の設計]]
