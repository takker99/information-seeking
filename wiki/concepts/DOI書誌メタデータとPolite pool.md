---
tags: [scholarly-search, api, etiquette]
---

# DOI書誌メタデータとPolite pool

DOIを起点に書誌metadataを取得するAPI経路と、bulk呼び出しで「polite pool」待遇を受けるための識別子提供の慣行。

- Crossref REST APIはDOIで`/works/{doi}`を取り、書誌・著者・出版物・license・funding・ORCID/ROR IDを返す ([[2026-09-30 Crossref REST API]])。
- **polite pool**: クエリに`mailto=yourmail@company.org`を含めると、Crossrefがbulk trafficの中で**識別子付きを優先**する。研究・自動化での利用では付けるのが推奨 ([[2026-09-30 Crossref REST API]]、 [Tips and tricks](https://www.crossref.org/documentation/retrieve-metadata/rest-api/tips-for-using-the-crossref-rest-api/))。

経路設計上の含意:

- 既にDOIが手元にあるならCrossrefは**最速の書誌同定API**。[[引用追跡]]の起点や、図書館目録の補完に使う
- [[2026-09-30 OpenAlex API]]と並列で叩くと、登録範囲の差（member deposit vs curated corpus）を[[情報源の評価]]の材料に出来る
- polite pool識別子はroute記録に残すと、再現時に同等の優先度で叩ける

[[マルチソースグラウンディング]]（[[2026-09-30 Gemini Deep Research Agent]]）のsource拡張として、MCP経由でDeep Research agentからCrossrefを引くと、plan→search→iterateのloop内でDOI書誌が安定して取れる。
