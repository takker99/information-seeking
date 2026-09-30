---
tags: [library-search, metadata]
---

# DC-NDL拡張schema

Dublin Coreを国立国会図書館が拡張したmetadata schema。日本語図書館catalogで広く採用され、NDL Search APIのresponse基本形。

- DC-NDL（国立国会図書館ダブリンコアメタデータ記述）に従い、各プロトコル（SRU/OpenSearch/OpenURL/OAI-PMH）のresponseが構成される ([[2026-09-30 NDL Search API]])。
- RDF形式は [DC-NDL（RDF）フォーマット仕様](/renkei/dcndl)。
- 英語版のNDL Search API仕様書は2022-08-29で止まり旧システム準拠、新機能の参照は日本語版（2026-09-25付 第1.5版）。

経路設計上の含意:

- 日本の図書館間でschema互換性が高いため、NDL以外の図書館catalogもDC-NDLで読める可能性がある。[[content typeで探索先を選ぶ]]のschema軸
- 学術metadata API（[[2026-09-30 OpenAlex API]]、[[2026-09-30 Crossref REST API]]）と図書館目録を接続するschema変換ポイントになる。同一recordを複数schemaでcacheする場合は[[検索過程の記録]]にschemaを残す

[[Dehydrated nested entity]]（OpenAlex）との対比:

- OpenAlexはresponse内のnested entityをdehydratedで返す
- DC-NDLは要素をDC Terms + 拡張要素でフラットに並べる設計で、nested entityの扱いが違う

[[Content negotiation（書誌metadata）]]（Crossref）と並び、図書館・学術APIのschema標準化の代表例。
