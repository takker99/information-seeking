---
source_url: "https://developers.openai.com/api/docs/guides/deep-research"
accessed: 2026-09-30
tags: [deep-research, agent, api]
---

# OpenAI Deep Research（API）

OpenAI Responses API経由のDeep Research機能。`o3-deep-research` / `o4-mini-deep-research`モデル（レガシー、2026-07-23 shutdown予定、置換は `gpt-5.6-sol`）が、Responses APIと組み合わせて数百のsourceを分析・統合する引用付きレポートを作る。

## 要点

### API経路

- Responses APIを使う。modelに `o3-deep-research` または `o4-mini-deep-research` を指定
- 必須: 少なくとも1つのデータsource（web search / remote MCP servers / file search over vector stores）
- 任意: code interpreter toolでコード実行による解析
- 非対応: function calling。custom toolsも未対応。remote MCPは「search/fetch interface」を実装したspecialized typeが必要

### Tools

| Tool | 用途 | 備考 |
| --- | --- | --- |
| `web_search_preview` | 公開Web検索 | 公開Webへアクセス |
| `file_search` | vector stores経由の私的データ | max **2 vector stores**まで同時添付可 |
| `code_interpreter` | コード実行でデータ解析 | container type `auto` |
| remote MCP server | 企業内データ等のsource | `search`+`fetch` interface必須。`require_approval: "never"` 必須（read-only） |

### 非同期実行

- `background: true` 推奨（multi-stepで数十分かかる）
- webhooks完了通知、`max_tool_calls` でcost/latency制約
- background modeはresponseを約10分保持するためpolling可能。**Zero Data Retention (ZDR)とは互換しない**（MAM Modified Abuse Monitoring organizationsは使用可）

### Output構造

- Responses API標準のoutput arrayに、deep research固有のitemが入る:
  - `web_search_call`（actions: `search`/`open_page`/`find_in_page`）
  - `code_interpreter_call`
  - `mcp_tool_call`
  - `file_search_call`
  - `message`（inline citations付きの最終回答。annotationにurl/title/start/end_index）

### ChatGPT と Responses API の3-step差

ChatGPT版は中間モデル（例: `gpt-4.1`）を使い、

1. **Clarification**: 意図・目標・制約を明確化
2. **Prompt rewriting**: 詳細なプロンプトへ展開
3. **Deep research**: 展開済みプロンプトを渡して実行

Responses API経由のdeep researchは**1/2を含まない**。caller側でclarifying question / prompt rewritingの前段処理を構成する必要がある。プロンプトが十分詳細なら前段処理は不要。

### 私的データの組込方法

- prompt textに含める（スケールしない）
- vector storeへuploadしfile search toolで接続（推奨、max 2 vector stores）
- Connectors（Dropbox・Gmail等）でpull-in
- remote MCP serverで接続（`search`+`fetch` interface）

### Safety

- prompt injection・exfiltration・privacy・compliance・ZDRへの配慮が必要
- deep research MCP serverの `require_approval: "never"` 設定は、search/fetchがread-onlyのためHITLの意義が薄いことを根拠にする

## 設計含意

- [[マルチソースグラウンディング]]（[[2026-09-30 Gemini Deep Research Agent]]）と同型: web search + file search + remote MCP + code interpreter の組合せをtool毎の[[マルチソースグラウンディング]]として整理できる
- MCP serverの `search`+`fetch` interface限定は[[MCPサーバー経由のsource拡張]]の具体的な実装契約を提示。汎用MCP serverは対応しない
- ChatGPT版の中間2段（clarification / prompt rewriting）はconsumer体験の最適化で、API経由ではcaller責務。[[Deep Research agent]]のprompt設計で[[生成AIで問いと検索語を作る]]と接続する
- `background: true` と webhookは[[非同期研究タスク]]のOpenAI版実装。ZDR制約との両立が難しい
- model IDは `gpt-5.6-sol` への移行が進行中。[[2026-09-30 Gemini Deep Research Agent]]の`deep-research-preview-*`と同様、preview/legacy model IDは将来廃止予定

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]、[[MCPサーバー経由のsource拡張]]、[[非同期研究タスク]]
- [[2026-09-30 OpenAI ChatGPT Deep Research Help]] — consumer側
- [[2026-09-30 Gemini Deep Research Agent]]
- [[問いに応じた情報探索経路の設計]]
