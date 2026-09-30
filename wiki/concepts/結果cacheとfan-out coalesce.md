---
tags: [agent, caching]
---

# 結果cacheとfan-out coalesce

同一のsearch/extract要求を再利用するためのcache機構と、並列fan-outの同一要求を1つのbackend callに統合する機構。

- Hermesは`web_search`をin-memory memo（per-process）、`web_extract`を`~/.hermes/cache/web/`配下の共有file cache（CLI・gateway・cron・subagent横断）([[2026-09-30 Hermes Web Search]])。
- 並列fan-outで同一searchが同時に走ると1つのbackend requestにcoalesce、limitは10/20/50/100にbucket化。
- success responseのみcache、failureはretry、keyless rescue responseはcacheしない。
- `localhost`/`127.0.0.1`/`*.local`/private IPはextract cache bypass。`web.cache_exempt_hosts`でstaging URL等をbypass可能。

経路設計上の含意:

- [[Deep Research agent]]のようなsubagent fan-outが効いてくる経路で**cost・latency双方を抑える**基盤になる
- cache hit時は[[情報源の評価]]の手順が変わらない（cached responseは元のprovider URLを保持）が、鮮度はcache TTLに従う
- local URLをbypassする設計はdev/previewとresearch URLが混在する環境で重要
- 重複除去を前提にすると、bulkクエリのbenchmarkは**cache状態込み**で評価する必要がある

## 関連

- [[検索providerの抽象化]]、[[Keyless ringとone-shot rescue]]
