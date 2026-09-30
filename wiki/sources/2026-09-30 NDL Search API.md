---
source_url: "https://ndlsearch.ndl.go.jp/help/api/specifications"
accessed: 2026-09-30
tags: [library-search, catalog, api]
---

# 国立国会図書館サーチAPI

NDL SearchのAPI仕様概要。SRU / OpenSearch / OpenURLの検索用APIと、OAI-PMHのハーベスト用APIを提供する。日本語仕様書は2026-09-25付の第1.5版。

## 要点

### 提供API

| 種類 | プロトコル | 出力 | アクセスURL |
| --- | --- | --- | --- |
| 検索用 | SRU | XML | `https://ndlsearch.ndl.go.jp/api/sru` |
| 検索用 | OpenSearch | XML(RSS) | `https://ndlsearch.ndl.go.jp/api/opensearch` |
| 検索用 | OpenURL | HTML | `https://ndlsearch.ndl.go.jp/api/openurl` |
| ハーベスト用 | OAI-PMH | XML | `https://ndlsearch.ndl.go.jp/api/oaipmh` |

※SRW / Z39.50は2020-03-02で終了。

### metadata schema

- メタデータは [DC-NDL（国立国会図書館ダブリンコアメタデータ記述）](https://www.ndl.go.jp/jp/dlib/standards/meta/index.html) に基づく。各プロトコルのresponseもDC-NDLを基本形とする。
- RDF形式: [DC-NDL（RDF）フォーマット仕様](/renkei/dcndl)

### 提供範囲

- NDL Searchで検索できるデータのうち、**許諾が得られたもののみをAPIで提供**。
- 詳細は[API提供対象DP一覧](/help/api/provider)。データプロバイダごとに利用条件が異なる（営利利用・継続アクセス・事前連絡の有無等）。

### リクエスト例

- SRU: `title="桜" AND from="2018"` をUTF-8でURL encode、CQL
- OpenSearch: `title=マリーアントワネット&ndc=2&dpid=iss-ndl-opac`（NDCは前方一致）
- OpenURL: `au=夏目漱石`
- OAI-PMH: `metadataPrefix=dcndl_v3&set=ndl-dl&from=2026-01-30&until=2026-01-30`

### 仕様書

- 日本語: [第1.5版 2026-09-25](/file/help/api/specifications/ndlsearch_api_20260925.pdf)
- 附録: データプロバイダ一覧とAPI対応表（2026-06-24）、データグループID・mediaType一覧（2024-04-01）、コレクションコード・Access Rights一覧（2025-09-16）
- 英語版: [Ver.1.24 2022-08-29](/file/help/api/specifications/ndlsearch_api_20220829_en.pdf)（旧システムに基づく）

## 設計含意

- 4つのプロトコルを**用途で使い分け**: 検索=SRU/OpenSearch、リンクリゾルバ=OpenURL、bulk harvest=OAI-PMH。[[引用追跡]]の入口としてはOpenURLで書誌を引き、SRUで本文や所蔵を辿る組合せ
- DC-NDL拡張は日本の図書館間で広く採用されているため、NDL以外の図書館catalogも同じschemaで読める可能性がある。[[content typeで探索先を選ぶ]]を「schema」で選ぶ軸
- **provider別利用条件の差**は重要。同一APIでもdata providerごとに許諾範囲・営利利用可否が変わる。[[情報源の評価]]の後段で「取得できたmetadataが商用利用に耐えるか」をprovider単位で判定
- 日本語仕様書は2026-09-25付で更新、英語版は2022-08-29で止まる（**旧システム準拠**）。新機能の参照は日本語版を当る

## 関連

- [[図書館検索プロトコル（SRU_OpenSearch_OpenURL_OAI-PMH）]]、[[DC-NDL拡張schema]]
- [[問いに応じた情報探索経路の設計]]
