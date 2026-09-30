---
tags: [api, linked-data]
---

# JSON-LD / Linked Data書誌API

書誌metadataをJSON-LDまたはRDFで取得できるAPI設計。schemaはDublin Core、PRISM、DataCite、JPCOAR、CiNii独自拡張等を組み合わせる。

- [[2026-09-30 CiNii Web API]]は RDF（XML）と JSON-LD（JSON）を提供。詳細画面URLに`.rdf`/`.json`を付ける、またはAcceptヘッダで`application/rdf+xml`/`application/json`/`application/ld+json`指定のcontent negotiation ([Content negotiation（書誌metadata）]([[2026-09-30 Crossref REST API]]))。
- JSON-LD 1.0仕様（W3C 2014-01-16勧告）に準拠。[[Dehydrated nested entity]]（OpenAlex）と違い、JSON-LDはnested entityを構造的に保持しつつ`@id`/`@type`で参照可能。
- [[DC-NDL拡張schema]]（[[2026-09-30 NDL Search API]]）とschema互換部分を共有し、CiNii/NDL/大学図書館catalogを横断するLinked Dataとして連結できる。

経路設計上の位置:

- 学術書誌のgraph traversal: identifier（DOI/NAID/ORCID/KAKEN_RESEARCHERS/NRID等）でentity間を`@id`参照で辿る
- Linked Data viewer/Reasoner（SPARQL等）と組み合わせて[[引用追跡]]を構造的に行う
- 同じidentifierが複数schemaで表現されるため、書誌同定の[[情報源の評価]]をschema統一で補強

[[Dehydrated nested entity]]（OpenAlex）との対比:

- OpenAlexはresponse内のnested entityをdehydrated（ID+name）で返してresponse sizeを抑える
- JSON-LD/RDFはnested entityを`@id`参照で保持。クライアントがSPARQL等のqueryで辿る
- 設計の方向性が違う: 効率（OpenAlex） vs Linked Data原則（CiNii/Crossref）

## 関連

- [[図書館検索プロトコル（SRU_OpenSearch_OpenURL_OAI-PMH）]]、[[Content negotiation（書誌metadata）]]
