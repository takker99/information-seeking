---
tags: [api, design]
---

# Content negotiation（書誌metadata）

同一URLに対し、要求形式（JSON / XML / UNIXSD等）を切り替えて単一recordを取得する仕組み。

- Crossref REST APIの単一metadata recordはcontent negotiationで複数形式を返せる ([[2026-09-30 Crossref REST API]])。
- URL拡張子やAcceptヘッダで切替え。

経路設計上の含意:

- 既存pipelineがJSON前提ならそのまま、XMLが必要なら切替え
- bulk download（[Public data files and snapshots](https://www.crossref.org/documentation/retrieve-metadata/bulk-downloads/)）や[OAI-PMH](/documentation/retrieve-metadata/oai-pmh/)と並ぶ取得形式の選択肢
- 同一recordを複数形式でcacheしてもschemaが同じならhash keyが一致する。schema driftを[[検索過程の記録]]に書く

[[Dehydrated nested entity]]（OpenAlex）と並ぶ、API設計の「response shape切替」パターン。Crossrefは内容交渉、OpenAlexはnested stub化で、用途に応じて最適化する。
