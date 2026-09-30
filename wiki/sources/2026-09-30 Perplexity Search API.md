---
source_url: "https://docs.perplexity.ai/docs/search/quickstart"
accessed: 2026-09-30
tags: [web-search, search-api]
---

# Perplexity Search API

Perplexity Search APIの開発者向けquickstartガイド。リアルタイムのWeb検索結果を構造化データとして返し、domain/language/region/content抽出の制御ができる。

## 要点

### 役割分担

- **Search API**: リアルタイム順位付きWeb検索結果を構造化データで返す。自前で処理するためのraw results用途。
- **Agent API** ([別ページ](/docs/agent-api/quickstart)): 引用付きLLM回答が必要なときはそちら。

### アクセス経路

- [Playground](https://console.perplexity.ai/project/playground/search): API keyなしで試せる。
- Perplexity CLI: ターミナルからJSONで順位付き結果。shell pipelineやagent tool呼び出し向け。
- 公式SDK: Python `perplexityai`、TypeScript `@perplexity-ai/perplexity_ai`、JS、cURL。

### 認証

- `PERPLEXITY_API_KEY` 環境変数。SDKは自動で読む、明示指定も可。

### 基本パラメータ

- `query`: 検索語（文字列または後述の複数query配列）
- `max_results`: 1-20、デフォルト10
- `search_context_size`: 結果の範囲（例 `high`）
- 結果オブジェクト: `title`、`url`、`snippet`、`date`、`last_updated`

### Fast Search

- `search_type: "fast"` で低latency・低cost。\$1.00 / 1000リクエスト。SDK互換のためのworkaroundが[Fast Search](/docs/search/fast-search#sdk-support)にある。

### Regional Web Search

- `country` にISO 3166-1 alpha-2（`US`/`GB`/`DE`/`JP`等）。地域固有のニュース・規制・言語向け。

### Multi-Query

- 1リクエストに最大5つの関連queryを配列で渡せる。各queryは独立処理。
- 課金: 1リクエスト=1 billing unit。rate limitは配列のquery数ぶん消費（5 queryなら5 unit）。

### Domain filter

- `search_domain_filter` で allowlist（プレフィックスなし）または denylist（`-`プレフィックス）。**両方を同じリクエストで併用不可**。
- 最大20ドメイン。pathを付けると部分pathで絞れる（例 `"nature.com/articles"`）。
- 専用ガイド [domain-filter](/docs/search/filters/domain-filter) に高度なパターン。

## 設計含意

- raw result APIと回答生成APIを分離するのは他の[[2026-09-30 Exa Search API]]・[[2026-09-30 Tavily Search API]]と異なる構造ではないが、Perplexityは**同一brand内に両APIを明示分離**しているのが特徴。利用側で生結果パイプラインと回答生成のどちらを選ぶかを決められる。
- multi-queryは[[query fan-out]]（Google AI Modeの自動分解）を**手動で明示する**形。分解ロジックをこちらで持ちたいときに有用。
- domain filterのallowlist/denylistは[[content typeで探索先を選ぶ]]をdomain指定で行う実装。[[情報源の評価]]で選んだ出版社のみを許可リストにするなどの使い方ができる。

## 関連

- [[生検索結果APIと回答APIの分離]]、[[Fast Search tier]]、[[Multi-Query検索]]、[[ドメインフィルタ]]
- [[2026-09-30 Exa Search API]]、[[2026-09-30 Tavily Search API]]
- [[問いに応じた情報探索経路の設計]]
