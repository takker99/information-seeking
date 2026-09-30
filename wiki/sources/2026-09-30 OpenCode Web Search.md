---
source_url: "https://opencode.ai/v2/docs/websearch/"
accessed: 2026-09-30
tags: [agent, web-search]
---

# OpenCode Web Search

OpenCodeの公式websearch機能説明。OpenCode本体とは別のproviderを選べる薄い統合層で、429時の自動切替とpermission actionを備える。

## 要点

### Providers

2026-09-30時点で4つを内蔵:

| Provider | ID | 環境変数 |
| --- | --- | --- |
| Exa | `exa` | `EXA_API_KEY` |
| Firecrawl | `firecrawl` | `FIRECRAWL_API_KEY` |
| Parallel | `parallel` | `PARALLEL_API_KEY` |
| Tavily | `tavily` | `TAVILY_API_KEY` |

接続: TUIで`/connect`、またはOpenCode起動前に環境変数設定。

### 選択

- `opencode.jsonc`の `websearch.provider` で固定（例 `"tavily"`）。
- `"random"` で利用可能なproviderから自動選択。**セッションごとに固定され、rate-limitされるまで継続利用**。

### Limitsと429 handling

- providerがHTTP 429を返すと `random` 選択経路では別providerで再試行。rate-limitされたproviderは `Retry-After` または60秒のcooldown。
- 全providerがcooldown中の場合は即fail。
- セッション移動やserver再起動でremembered providerはリセット、cooldownは同じworkspace内のセッションで共有。

### Permissions

- `websearch` permission action、検索語がresource。明示許可のないsearchは確認。
- ruleの順序とmatchingは[Permissions](/permissions)参照。

### Disable

- `websearch: false` でmodel requestsからweb search toolを除去。

## 設計含意

- **provider品質比較機能ではない**。`random`は「429耐性」を目的としたfallback機構で、source品質やdepthの比較はしない。
- このWikiで比較実験する場合「OpenCodeで検索」とせず、**実際に選ばれたproviderと設定**（`websearch.provider` 値、`EXA_API_KEY`等の有無）を記録する必要がある。
- provider間の機能差（[[2026-09-30 Exa Search API]]の`deep-reasoning`/`outputSchema`、[[2026-09-30 Tavily Search API]]の`search_depth`/`topic`）はOpenCodeのwebsearch層からは露出しない。OpenCodeは**薄い統合**で、provider固有機能は各自のAPIを直接呼ぶ方が活用できる場面もある。
- 同じ検索経路でも、providerが変われば結果もlatencyもcostも変わる。route記録ではprovider名を残す。

## 関連

- [[検索providerの抽象化]]、[[429 fallback機構]]
- [[2026-09-30 Exa Search API]]、[[2026-09-30 Tavily Search API]]、[[2026-09-30 Hermes Web Search]]
- [[問いに応じた情報探索経路の設計]]
