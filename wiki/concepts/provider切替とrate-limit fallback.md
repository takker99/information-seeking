---
tags: [agent, reliability, cost]
---

# provider切替とrate-limit fallback

検索providerが失敗・rate-limitしたときに、別providerへ自動で切り替えてavailabilityを確保する機構。keyed provider間の切替（OpenCode）と、keyless ring + one-shot rescue（Hermes）の2型がある。

## OpenCode: 429時のprovider切替

HTTP 429（rate limit）を受けたproviderを一定時間cooldownし、別providerに自動切替する reliability 機能。

- OpenCode websearchの`"random"`経路: providerが429を返すと、cooldownに入り、別providerで再試行。`Retry-After`があればそれに従い、無ければ60秒 ([[2026-09-30 OpenCode Web Search]])。
- 全providerがcooldown中の場合は即fail。
- cooldownは同一workspace内のセッションで共有。セッション移動やserver再起動でremembered providerはリセット。
- 同じ抽象はHermesにもあり、search/extractで別providerが選べるため429耐性はlayeredに組める。

## Hermes: keyless ringとone-shot rescue

API keyが無くても複数providerの無料枠をrotateして動かす「keyless ring」と、keyed backend失敗時に1回だけringで救済する「one-shot rescue」。

- Hermesは環境変数/URLが全く無い状態でも `web_search`/`web_extract`が動く: Exa/Parallel/Firecrawl/Keenableの無料tierをround-robinし、rate-limitで次vendorへmulti-hop ([[2026-09-30 Hermes Web Search]])。
- keyed backendが失敗（bad key、outage、5xx等）すると、その1回のみringへrescue（**non-sticky**、次のcallは再びkeyed backendを試す）。`web.keyless_rescue: false`で無効化。
- keyless ring + one-shot rescueはOpenCodeの429 fallbackのHermes版で、**ring vendorの無料枠にコストが分散**する点が追加負担。

## 共通パターンと差異

共通するのは、障害を機能低下ではなく別backendへの切替で吸収し、単一providerのrate-limitやoutageで全体を止めない設計。

| 軸 | OpenCode | Hermes |
|---|---|---|
| 切替の契機 | 429のみ | keyed backendの全失敗（bad key・outage・5xx等）、およびkeyless時のrate-limit |
| 切替先 | keyed provider間 | keyless ringの無料tier vendor |
| key無しでの動作 | 不可 | ringで動作 |
| 失敗時の挙動 | 全provider cooldown中は即fail | rescueは1回のみでnon-sticky |
| 無効化 | — | `web.keyless_rescue: false` |

## route記録への含意

- 品質比較のための仕組みではなく、**availability確保の機構**。1つのproviderのrate-limitに全体が引きずられないための防御。結果の質を担保する仕組みは別に必要（[[情報源の評価]]、明示provider固定）
- bulk呼び出し時に「普段使わないprovider」へ流れた記録は、route評価時に**意図せぬprovider切替**として扱うべき
- cooldownの共有は便利だが、workspaceをまたぐと独立に扱う必要があり、比較実験の独立性に影響しうる
- 「特に設定しない」状態でも動くファーストステップになる（Hermesのring、OpenCodeの`random`）。比較実験ではring vendorに流れた記録も意図せぬprovider切替になる
- ring vendor側の無料枠はSLA無保証。本番運用ではkeyed固定 + rescue pathとして位置付けるのが安全

## 関連

- [[検索providerの抽象化]]、[[結果cacheとfan-out coalesce]]
