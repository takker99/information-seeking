---
tags: [library-search, protocols]
---

# 図書館検索プロトコル（SRU/OpenSearch/OpenURL/OAI-PMH）

図書館・書誌系で長く使われてきた標準プロトコル群。Z39.50/SRWの系譜を引き継ぎ、各図書館・機関が採用している。

- SRU: Search/Retrieve via URL。HTTP+XMLでCQL（Contextual Query Language）queryを実行、XMLで書誌metadataを返す
- OpenSearch: RSSベースの簡易検索プロトコル。ブラウザ・フィードリーダ向け
- OpenURL: リゾルバ向けlink、書誌識別子（ISBN等）→所蔵・本文URLを返す
- OAI-PMH: Open Archives Initiative Protocol for Metadata Harvesting。bulk harvest用、XMLで定期取得

[[2026-09-30 NDL Search API]]は4つを提供。[[2026-09-30 CiNii Web API]]は OpenSearch、OpenURL、RDF、JSON-LD、SRU/OAI-PMHも一部提供（旧システム含む）。

経路設計上の位置:

- [[引用追跡]]の入口: OpenURLでDOI/ISBN→所蔵・本文linkに変換
- [[content typeで探索先を選ぶ]]: databaseの代わりに図書館catalogを選ぶ軸
- bulk update: OAI-PMHで所蔵・書誌の定期取得
- 検索: SRU（高度query）/OpenSearch（簡易RSS）

[[学術メタデータAPIの書誌グラフ]]（OpenAlex/Crossref系）と対比:

- 学術APIはDOI/ORCID等のidentifierでdiscovery重視
- 図書館プロトコルは所蔵・所在・identifier link resolver重視
- 両者は補完関係: 学術APIで書誌同定 → 図書館プロトコルで所蔵・本文へ

schema選択の基準: [[DC-NDL拡張schema]]、Dublin Core、MARC21、JATS等、各図書館の採用schemaに依存する。
