---
tags: [agent, reliability, cost]
---

# Keyless ringとone-shot rescue

API keyが無くても複数providerの無料枠をrotateして動かす「keyless ring」と、keyed backend失敗時に1回だけringで救済する「one-shot rescue」。

- Hermesは環境変数/URLが全く無い状態でも `web_search`/`web_extract`が動く: Exa/Parallel/Firecrawl/Keenableの無料tierをround-robinし、rate-limitで次vendorへmulti-hop ([[2026-09-30 Hermes Web Search]])。
- keyed backendが失敗（bad key、outage、5xx等）すると、その1回のみringへrescue（**non-sticky**、次のcallは再びkeyed backendを試す）。`web.keyless_rescue: false`で無効化。
- 関連概念: [[429 fallback機構]]（OpenCode）。OpenCodeは429のみ、Hermesはkeyed backendの全失敗でrescue。

経路設計上の含意:

- 「特に設定しない」状態でも動くファーストステップになる。[[2026-09-30 OpenCode Web Search]]の`random`も同種の初期体験提供
- 比較実験ではring vendorに流れた記録が**意図せぬprovider切替**になる。明示固定が重要
- ring vendor側の無料枠はSLA無保証。本番運用ではkeyed固定 + rescue pathとして位置付けるのが安全

## 関連

- [[検索providerの抽象化]]、[[結果cacheとfan-out coalesce]]
