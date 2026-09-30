---
tags: [agent, abstraction]
---

# 検索と抽出のbackend分離

Web検索と本文抽出を別model-callable toolとして、独立したproviderに割り当てられる抽象。

- Hermesは`web_search`（順位付き結果）と`web_extract`（URL本文）を別toolとして提供し、`web.search_backend`と`web.extract_backend`を独立設定できる ([[2026-09-30 Hermes Web Search]])。
- 組合せ例: SearXNG（無料metasearch、search-only）+ Firecrawl（有償extract）、DDGS（free search）+ Tavily（paid extract）など。
- [[2026-09-30 OpenCode Web Search]]はsearch onlyでbackend切替、`web_extract`相当は別経路。Hermesは両方を統合管理する点が粒度高。

経路設計上の含意:

- 同一の検索queryに対し、複数のextract providerで本文取得品質を比較できる
- 大量queryの前段検索は無料metasearch、深掘り本文のみ有償extractにするhybrid経路を1ツールで組める
- 検索と抽出が別providerになると、**結果IDの整合性**と**cache scope**をproviderごとに持つ必要が出る。Hermesの[[結果cacheとfan-out coalesce]]はこれらを内部管理する設計

[[生検索結果APIと回答APIの分離]]（Perplexity）と似るが:

- PerplexityはAPI製品設計の分離（生結果API vs 回答生成API）
- Hermesはagent抽象の分離（tool単位のbackend選択）
- どちらも「結果取得」と「解釈・統合」を分けるが、責任の所在（vendor / user agent）が異なる

## 関連

- [[検索providerの抽象化]]、[[429 fallback機構]]
