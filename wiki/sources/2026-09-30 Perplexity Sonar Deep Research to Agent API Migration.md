---
source_url: "https://docs.perplexity.ai/docs/sonar/models/sonar-deep-research"
accessed: 2026-09-30
tags: [deep-research, agent, api, migration]
---

# Perplexity Sonar Deep Research → Agent API Migration

Perplexity公式の `sonar-deep-research` ドキュメントページ。2026-09-30時点で内容はAgent APIへの移行案内ページになっている。**Sonar Chat Completionsは2026-09-27にサポート終了**、同期/streamingはAgent APIへ自動reformulate、asyncはbackground modeへの移行が必要。

## 要点

### Sonar → Agent API の移行

- Sonar Chat Completions は `messages` を `choices` に変換する従来型
- Agent API は `input` をtyped `output` array（model step毎、`message` item + `search_results` item）に変換
- **Open Responses standard**準拠で、portability重視。lock-inを避け、性能・効率で選ばれる設計

### Agent APIのtools

- **Web search**（built-in）
- **URL fetching**
- **Sandbox**（コード実行・compute・データ解析・output verificationをrequest内で完結）
- **MCP**（外部Tool/データ接続）
- **Premium data sources**: finance search、people search

### 対応モデル（cross-vendor）

OpenAI / Anthropic / Google / xAI / Z.AI / Moonshot AI / NVIDIA / Perplexity Sonar を単一endpointで選択可能。[[マルチソースグラウンディング]]をprovider非依存で組める基盤。

### Preset（task intensity別）

| Preset | 用途 | 旧Sonar対応 |
| --- | --- | --- |
| `fast` | single-fact lookup、definitions、quick summaries | Sonar / Sonar Pro |
| `low` | multi-hop browsing、wide aggregation | Sonar Reasoning Pro |
| `medium` | (中程度) | — |
| `high` | expert-level reasoning、exhaustive source coverage | Sonar Deep Research |
| `xhigh` | 最高品質、deep research用 | — |

公式推奨: 「state-of-the-art deep researchには `xhigh` preset」。

### Agent loop

single request内で: reason → act → observe → continue。[[2026-09-30 Anthropic Multi-Agent Research System]]の subagent loop と相似形だが、Perplexityはagent loopを**単一model内**で実装。

### 互換性

- [[2026-09-30 OpenAI Deep Research API]]（Responses API・background mode）と並べて比較すると、Agent APIの`xhigh`は"tasks of deep research"を**preset経由で呼び出す**点が異なる
- Open Responses standardで OpenAI Responses API / [[2026-09-30 Gemini Deep Research Agent]] の Responses API 等との相互運用性が将来改善する可能性

## 設計含意

- Perplexityは2026年内にDeep Researchを「独立model」から「Agent API preset」へ移行。[[Deep Research agent]]の実装方針は会社ごとに分かれる: **専用model** (Gemini Deep Research agent, OpenAI o3-deep-research legacy) ↔ **agent loop preset** (Perplexity Agent API) ↔ **multi-agent orchestration** (Anthropic Research, xAI Multi-agent)
- 単一endpointでcross-vendor model選択 ([[マルチソースグラウンディング]]) は、route評価で「provider」を変数として扱える
- `xhigh` presetはbenchmarkトップだが[[検索depthとcreditのトレードオフ]]に似たcost・latency trade-offが背後にあると推測
- Open Responses standard準拠は将来[[構造化出力schema]]を含むAPI仕様の標準化を促す可能性

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]、[[非同期研究タスク]]
- [[2026-09-30 Perplexity Advanced Deep Research Help]] — consumer側
- [[2026-09-30 Anthropic Multi-Agent Research System]]、[[2026-09-30 OpenAI Deep Research API]]、[[2026-09-30 Gemini Deep Research Agent]]
- [[問いに応じた情報探索経路の設計]]
