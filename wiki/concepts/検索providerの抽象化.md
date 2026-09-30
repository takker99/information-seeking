---
tags: [agent, abstraction]
---

# 検索providerの抽象化

agent本体とは別の検索backendを差し替え可能にする薄い統合層。同一のagent経路で複数providerを試せる。

- OpenCode websearchはproviderとしてExa / Firecrawl / Parallel / Tavilyの4つを内蔵。`opencode.jsonc`の`websearch.provider`で固定、または`"random"`で自動選択 ([[2026-09-30 OpenCode Web Search]])。
- [[2026-09-30 Hermes Web Search]]も`web_search`/`web_extract`を別providerに割り当てられる同様の抽象を持つ。
- 共通する設計思想:
  - agent本体のロジックは固定、backendだけ差替え可能
  - provider品質を抽象化せず、429 fallbackに留める（比較機能は出さない）
  - 環境変数でAPI key管理

経路設計上の含意:

- 同じ問いに対しproviderを切り替えて結果・latency・costを比較する実験基盤になる
- ただし、各provider固有の機能は露出しない（[[2026-09-30 Exa Search API]]の`outputSchema`のfield grounding、[[2026-09-30 Tavily Search API]]の`topic=finance`など）。provider固有機能を使いたいならAPIを直接呼ぶ方が有利
- このWikiでの比較実験では「OpenCodeのwebsearch」ではなく、**実際に選ばれたprovider名**を記録しないと再現性が壊れる

## 関連

- [[429 fallback機構]]
