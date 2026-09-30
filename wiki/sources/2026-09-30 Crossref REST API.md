---
source_url: "https://www.crossref.org/documentation/retrieve-metadata/rest-api/"
accessed: 2026-09-30
tags: [scholarly-search, metadata, api]
---

# Crossref REST API

Crossrefに登録された学術コンテンツのmetadataを取得する公式REST API。DOI・書誌・著者・出版物等の書誌同定を支える。**sign-up不要**で公開されている。

## 要点

### 基本

- base URL: `https://api.crossref.org/`
- 認証: 不要
- 結果はJSON。単一recordはcontent negotiationで他形式も可
- metadataはmember（出版者等）とtrusted source（Retraction Watch等）が登録した内容

### Polite pool

- `mailto=yourmail@company.org` をクエリに含めるとpolite pool扱い。Crossrefはbulk呼び出し時に**識別子付きのtráficoを優先**するため、研究目的・自動化利用では付けるのが推奨 ([[Crossref REST API](https://www.crossref.org/documentation/retrieve-metadata/rest-api/)]、 [Tips and tricks](https://www.crossref.org/documentation/retrieve-metadata/rest-api/tips-for-using-the-crossref-rest-api/))。
- 含めない場合は未識別のbulk trafficとして扱われ、rate limit等の影響を受けやすい。

### Endpoints（抜粋）

- `/works`: 登録content item一覧。多数のパラメータ・filter
- `/works/{doi}`: 単一DOIのmetadata
- `/works/{doi}/agency`: DOIの登録agency（Crossref or DataCite）
- `/journals` / `/journals/{issn}` / `/journals/{issn}/works`
- `/members` / `/members/{id}` / `/members/{id}/works/`
- `/prefixes/{prefix}` / `/prefixes/{prefix}/works`
- `/funders` / `/funders/{id}` / `/funders/{id}/works` （Open Funder Registry経由）
- `/types` / `/types/{id}` / `/types/{id}/works`
- `/licenses`

### 含まれるmetadata

- 書誌: title、author、container-title、published date等
- funding data、license情報
- post-publication updates（correction、retraction、versioning）
- ORCID（個人ID）、ROR（機関・funder ID）
- abstract（**一部は出版社・著者のcopyright対象**、他はほぼ再利用自由）

### Content negotiation

- 単一metadata recordを複数形式で返す。URLに拡張子やAcceptヘッダで指定。

### Research Nexusと近年の動き

- Crossrefは[Research Nexus](/documentation/research-nexus/)構想で、DOI・ORCID・ROR・funder等のidentifierを横断した研究recordのlinkageを進める
- 2026-09-15付のblog "Improving how funding connects to research outputs" で、ID無しのfunder名をROR IDに自動matchする方針

## 設計含意

- **metadata APIであって全文APIではない**。abstract等の本文は再利用条件を確認する必要がある ([[情報源の評価]]の後段)
- [[2026-09-30 OpenAlex API]]と並んでDOI起点の[[引用追跡]]の前段API。Crossrefはmember登録ベース、OpenAlexは curated core corpus で網羅範囲が異なる。両方を並列に使って網羅性補強
- ORCID・RORのidentifierがmetadataに埋まるため、author/affiliation同定が安定する。[[検索とfilterの分離]]でID指定検索と組み合わせる
- polite poolの慣行はroute記録の再現性に効く（同一呼び出しでcache hitやqueue優先度が変わる）
- Research Nexus路線は、学術metadataのidentifierがauthor/funder/affiliation/workを横断で結ぶ方向で、図書館の目録・機関repositoryとも接続する。[[マルチソースグラウンディング]]のsource拡張候補としてMCP化しやすい

## 関連

- [[DOI書誌メタデータとPolite pool]]、[[Content negotiation（書誌metadata）]]
- [[学術メタデータAPIの書誌グラフ]]、[[引用追跡]]
- [[2026-09-30 OpenAlex API]]
- [[問いに応じた情報探索経路の設計]]
