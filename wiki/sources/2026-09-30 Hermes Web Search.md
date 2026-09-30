---
source_url: "https://hermes-agent.nousresearch.com/docs/user-guide/features/web-search"
accessed: 2026-09-30
tags: [agent, web-search]
---

# Hermes Agent Web Search & Extract

Hermes Agentの公式Web Search & Extractガイド。`web_search`と`web_extract`を別model-callable toolとして提供し、検索と抽出にそれぞれ独立したproviderを割り当てられる。

## 要点

### 2 tools

- **`web_search`**: 順位付きWeb結果を返す
- **`web_extract`**: 1つ以上のURLからreadable contentを抽出
- どちらも `config.yaml` または `hermes tools` で設定。

### Providers（10種）

| Provider | Search | Extract | 認証 |
| --- | --- | --- | --- |
| Firecrawl（default） | ✔ | ✔ | `FIRECRAWL_API_KEY`（keyless可、500 credits/月） |
| SearXNG | ✔ | — | `SEARXNG_URL`、self-host前提の無料metasearch |
| Brave Search (free) | ✔ | — | `BRAVE_SEARCH_API_KEY`、2 000 queries/月 |
| DDGS (DuckDuckGo) | ✔ | — | 不要（`ddgs`パッケージ使用） |
| Exa | ✔ | ✔ | `EXA_API_KEY`、keyless可、1 000 searches/月 |
| Parallel | ✔ | ✔ | `PARALLEL_API_KEY`、keyless可 |
| Tavily | ✔ | ✔ | `TAVILY_API_KEY`、keyless opt-in |
| Perplexity | ✔ | ✔（query-relevant snippets） | `PERPLEXITY_API_KEY`、有償 |
| Keenable | ✔ | ✔ | `KEENABLE_API_KEY`、keyless可 |
| xAI (Grok) | ✔ | — | `XAI_API_KEY` またはOAuth、有償 |
| OpenAI Native (Codex) | ✔ | — | `hermes auth add openai-codex` |

search-only: Brave / DDGS / xAI / OpenAI Native。これらに`web_extract`を当てる場合は別provider（Firecrawl/Tavily/Perplexity/Keenable/Exa/Parallel）を組み合わせる。

### per-capability backend

`web.search_backend`と`web.extract_backend`を独立設定できる。例: SearXNG（無料search）+ Firecrawl（有償extract）の組合せ。

優先順位:

1. 明示のper-capability指定
2. `web.backend`（共有fallback、`nous`は管理Tool Gateway）
3. 環境変数からのauto-detect（**ただし共有backendを一度でも書いた後は無効化**。.envにkey追加してもweb経路は切り替わらない）

### Keyless ring（keyed backendが無くても動く仕組み）

- 環境変数もURLも無い状態でも `web_search`/`web_extract`が動く: Exa / Parallel / Firecrawl / Keenableの無料tierをround-robinで自動切替、rate-limitされたら次vendorへ（multi-hop）。
- 一度共有backendを書くと、keyed backend失敗時に**1回だけ**ringでrescue（non-sticky、次のcallは再びbackendをtry）。
- `web.keyless_fallback: false` / `web.keyless_rescue: false` で無効化。

### web_extractのtruncation

- `web.extract_char_limit`（default 15 000、最大500 000）でbudget管理。
- 超過時: head+tail window（約75%/25%、markdown行境界で切る）+ `[TRUNCATED]`フッター。完全本文はdiskに保存し、フッターにfile pathと`read_file`呼び出しを明記。
- 2 MB以上は保存本文を2 MBにcap。
- tool call側に`char_limit`引数で個別上書き可。
- `web.extract_timeout`（default 120秒、`0`で無効）でwall-clock timeout。

### Cache

- `web_search`: 同一query（case/whitespace無視）+ 同一providerはin-memory memo（per-process）
- `web_extract`: 同一URL+format+providerは`~/.hermes/cache/web/`配下に保存（CLI・gateway・cron・subagentで共有）
- 並列fan-outで同一searchが同時に走ると1つのbackend requestにcoalesce、limitは10/20/50/100にbucket化
- success responseのみcache、failureはretry、keyless rescue responseはcacheしない
- `localhost`/`127.0.0.1`/`*.local`/LAN/private IPはextract cache bypass（live取得）、`web.cache_exempt_hosts`でstaging URL等もbypass可能
- `web.cache_ttl_minutes`（default 20、1-1440）

### xAI (Grok)のtrust model

- server-side `web_search` toolをResponses APIで呼び、**GrokがURLとタイトル/description自体を生成**する。index-based provider（Brave/Tavily/Exa）と違い、URL選択がLLM出力。
- 悪意あるquery（untrusted upstream経由）でattacker-chosen URLを返す可能性がある。**untrusted input経路で得られたURLはfetch前に検証する**ことが推奨。

### OpenAI Native (Codex)

- Codex Responses endpointのbuilt-in `web_search`。Hermes client-sideの`web_search`を**1:1でswap**（additiveではない）
- openai-codex OAuth必須、API key無し。Codex Responses以外のtransport（custom `base_url`等）では使えない
- search-onlyで、抽出は別provider（FireXrawl等）を`web.extract_backend`で指定

### 設定・トラブル

- `hermes tools`でprovider選択、`hermes setup`で状態確認
- SearXNGのJSON format有効化が`formats: - html - json`のoverride必要
- local URLsは`security.allow_private_urls`有効時のみ到達可能

## 設計含意

- per-capability backend分離は[[2026-09-30 OpenCode Web Search]]より粒度が高い。「無料search + 有償extract」の組合せを1エンドポイントに統合できる
- keyless ring + one-shot rescueは[[429 fallback機構]]のHermes版で、**ring vendorの無料枠にコストが分散**する点が追加負担
- cache + fan-out coalesceは、複数subagentが同じ問いを並列で調べる場面で**コスト・latency双方を抑える**構造。[[Deep Research agent]]のsubagent researchに自然な基盤
- xAI/OpenAI Nativeはserver-side toolで、Hermes側のclient-side searchをswapする設計。[[2026-09-30 Gemini Deep Research Agent]]の`google_search` tool設定と同型の位置に置く
- LLMがURLを選ぶprovider（xAI）とindex-driven provider（Brave等）の信頼差は、route評価で**source provenance**として記録すべき軸

## 関連

- [[検索と抽出のbackend分離]]、[[Keyless ringとone-shot rescue]]、[[結果cacheとfan-out coalesce]]、[[Truncated extractとon-disk全本文]]、[[LLMがURLを選ぶproviderの信頼モデル]]
- [[2026-09-30 OpenCode Web Search]]
- [[問いに応じた情報探索経路の設計]]
