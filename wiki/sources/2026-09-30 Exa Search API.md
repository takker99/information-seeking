---
source_url: "https://exa.ai/docs/reference/search"
accessed: 2026-09-30
tags: [web-search, search-api]
---

# Exa Search API

Exa `/search` endpointの公式API reference。Web検索と検索結果からの本文抽出を1エンドポイントで提供し、合成出力・段階的検索深度・schema指定出力・エージェント操舵に対応する。

## 要点

### 認証・SDK

- base URL: `https://api.exa.ai`
- 認証: `Authorization: Bearer $EXA_API_KEY` または `x-api-key: $EXA_API_KEY`。keyは[dashboard](https://dashboard.exa.ai/api-keys)で作成
- 公式SDK: `exa-py`（pip install）、`exa-js`（npm install）。いずれも`EXA_API_KEY`を環境から読む
- agent経路: hosted MCP server `https://mcp.exa.ai/mcp`、またはagent skill `npx skills add exa-labs/agent-skills`
- OpenAPI spec: `https://exa.ai/docs/exa-spec.yaml`（schemaのsource of truth）

### search type（精度と速度の段階）

- `auto`（デフォルト）: バランス型
- `fast`: ユーザー向け検索・対話ワークフロー向け
- `instant`: chat/voice/autocomplete向け、最低latency
- `deep-lite`: 軽量リサーチ、synthesis付き、約4秒latency
- `deep`: multi-stepの総合リサーチ、synthesis付き
- `deep-reasoning`: 深い推論、複雑な分析・意思決定タスク向け

### 入出力制御

- `query`: 必須
- `additionalQueries`: deep-search variant用、1-10個
- `numResults`: 1-100（public最大、default 10）。contact salesで上限拡張
- `includeDomains` / `excludeDomains`: 1-1200、各エントリはhostname / hostname+path prefix / wildcard subdomain。allowlist/denylistで**site:演算子で代用しない**（公式注記）
- `startPublishedDate` / `endPublishedDate`: ISO 8601
- `userLocation`: ISO 2-letter国コード
- `category`: `company`/`publication`/`news`/`personal site`/`financial report`/`people`、または自由文字列のhint。`publication`は学術出版（authors/venue/citations付き構造化メタデータ）
- `moderation`: 不適切コンテンツのフィルタ
- `compliance`: `hipaa`（エンタープライズ、cache-only取得、限定パラメータ）
- `additionalQueries`はdeep-search typeでのみ機能

### エージェント操舵

- `objective`: 呼び手の広い目的（どのdocumentを優先・除外するか、どのfacts/numbersを引き出すか）。agent向けToolとして渡す際はTool説明文にこの方針を書く
- `systemPrompt`: 出力や行動の追加指示（source選好、novelty/duplication制約）

### 合成出力（schema）

- `outputSchema`: `text`または`object`のJSON Schema。responseに`output`が含まれ、選択したsearch typeに加えて約2秒の合成latencyが乗る
- object schemaは合計10プロパティまで（ネスト・配列item含む）、ネスト2階層、配列はitems定義必須

### contents — 本文取得

- `text`: full page text（plain or HTML tags、`verbosity`: compact/standard/full、`maxCharacters`、`includeSections`/`excludeSections`）
- `highlights`: LLMが選んだ関連snippet。`query`で抽出方向を指定。dynamic highlights（β）は結果集合で共有予算を使う
- `summary`: LLM生成要約。`query`/`schema`で構造化可能
- `extras`: `links`/`imageLinks`/`richImageLinks`/`richLinks`/`codeBlocks`を結果ごとに追加
- `subpages` + `subpageTarget`: 結果pageから辿るsubpage数・探索語
- `livecrawlTimeout`: livecrawlの最大時間（10-90000 ms、default 10000）
- `maxAgeHours`: cache年齢の閾値（正=閾値以内のcacheを使う、0=fresh取得、-1=常にcache、省略時はfallback取得）。`text`の`verbosity`等を**freshに適用するには0指定**
- `snapshotAsOf`: ISO 8601 date-time / date-only（midnight UTC）。指定時刻のstored versionを返す。live取得せず履歴再現

### streaming

- SSE。`stream=true` + `outputSchema`指定時のみstream、それ以外は通常JSON
- chunk type: `text-delta` / `grounding` / `results` / `stream-reset` / `done` / `error`
- `grounding`はoutput fieldごとのcitation+confidence（`low`/`medium`/`high`）

### 失敗時・支払い

- 401 unauthorized / 402 payment required / 429 too many / 500 internal / 503 unavailable
- 402にはstandard error envelopeまたはx402 payment challenge（API key無しで402 priced endpointを呼ぶと`X402_PAYMENT_REQUIRED`ヘッダとBazaar/AgentKit discoveryの`extensions`）

## 設計含意

- `deep`/`deep-reasoning` typeは[[Deep Research agent]]をAPI callで部分実行する形に相当する。synthesisとlatencyをsearch typeとして切替可能なのが[[2026-09-30 Perplexity Search API]]や[[2026-09-30 Tavily Search API]]との差分
- `outputSchema`でJSON Schemaを渡し、`grounding`chunkでfieldごとのconfidenceが返る。[[情報源の評価]]の単位を「URL全体」ではなく「output field」に切り下げられる
- `objective`と`systemPrompt`は[[マルチソースグラウンディング]]の経路でDeep Research agentを呼ぶ際の指示語彙と相似形。caller側で探索方針を明示できる
- `snapshotAsOf`は履歴snapshotの取得。[[引用追跡]]や研究reproducibilityで「ある時点のページ内容」を固定したいときに有用

## 関連

- [[Multi-step deep search]]、[[構造化出力schema]]、[[Agent操舵フィールド]]、[[ページ本文の段階取得]]、[[履歴snapshot取得]]
- [[MCPサーバー経由のsource拡張]]
- [[2026-09-30 Perplexity Search API]]、[[2026-09-30 Tavily Search API]]
- [[問いに応じた情報探索経路の設計]]
