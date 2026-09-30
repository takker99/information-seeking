---
tags: [agent, reliability]
---

# 429 fallback機構

HTTP 429（rate limit）を受けたproviderを一定時間cooldownし、別providerに自動切替する reliability 機能。

- OpenCode websearchの`"random"`経路: providerが429を返すと、cooldownに入り、別providerで再試行。`Retry-After`があればそれに従い、無ければ60秒 ([[2026-09-30 OpenCode Web Search]])。
- 全providerがcooldown中の場合は即fail。
- cooldownは同一workspace内のセッションで共有。セッション移動やserver再起動でremembered providerはリセット。

経路設計上の位置:

- 品質比較のための仕組みではなく、**availability確保の機構**。1つのproviderのrate-limitに全体が引きずられないための防御
- 結果の質を担保する仕組みは別に必要（[[情報源の評価]]、明示provider固定）
- 同じ抽象は[[2026-09-30 Hermes Web Search]]にもあり、search/extractで別providerが選べるため429耐性はlayeredに組める

運用上の注意:

- bulk呼び出し時に「普段使わないprovider」へ流れた記録は、route評価時に**意図せぬprovider切替**として扱うべき
- cooldownの共有は便利だが、workspaceをまたぐと独立に扱う必要があり、比較実験の独立性に影響しうる

## 関連

- [[検索providerの抽象化]]
