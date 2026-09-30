---
source_url: "https://support.nii.ac.jp/ja/cinii/api/api_outline"
accessed: 2026-09-30
tags: [library-search, scholarly-search, api]
---

# CiNii Web API

国立情報学研究所（NII）のCiNii metadata/API概要。OpenURL・OpenSearch・RDF・JSON-LDの4つのAPIを提供し、論文・図書/雑誌・著者・図書館の書誌・metadata連携に使える。

## 要点

### 提供API（4つ）

- **OpenURL**: 書誌をURL形式で受け渡す規格。OPAC・リンクリゾルバとの連携。CiNiiは受信機能と送信機能（CiNii Research/Books詳細画面にリンクリゾルバlink）の両方を持つ。
- **OpenSearch**: 検索結果RSS。ブラウザ検索バーへの組み込みと、システム間連携のAPIとして使える。`Access-Control-Allow-Origin: *`でクロスドメイン非同期通信可。
- **RDF**: Dublin Core + dcndl + jpcoar + prism + datacite + foaf を組み合わせたRDF/XML。詳細表示画面のURL末尾に`.rdf`を付ける、Acceptヘッダで`application/rdf+xml`指定のcontent negotiation対応。
- **JSON-LD**: RDF同等のmetadataをJSONで。詳細表示URL末尾に`.json`、またはAcceptで`application/json`/`application/ld+json`。W3C JSON-LD 1.0仕様準拠（2014-01-16勧告）。

### 検索種別

CiNii Research側で: 論文検索、図書館検索、所蔵検索。CiNii Books側で: 図書・雑誌検索、著者検索、図書館検索、所蔵検索。用途ごとに別API pageで仕様公開。

### データ公開（CiNii Books）

- [NII総合目録データベース](https://contents.nii.ac.jp/catill/about/cat/infocat/od)のデータを[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.ja)でオープンデータとして公開。
- オープンデータ対象: CiNii Books 図書・雑誌・著者・図書館のRDFとJSON-LD。
- **内容説明・目次は提供元との契約で画面上のみ提供**。API経由では取得できない。
- 更新: 週1回（金曜夜反映、**翌週反映**）。データセット公開（RDF/XML）は当面年1回程度。

### 利用登録

- API利用には[登録](/ja/cinii/api/developer)が必要。
- 商用利用では事前連絡が求められる場合がある（[利用規約](/cinii/terms)参照）。

### 関連NIIコンテンツサービス

- [CiNii Research](https://cir.nii.ac.jp/) / [CiNii Articles](http://ci.nii.ac.jp/) / [CiNii Books](http://ci.nii.ac.jp/books/) / [CiNii Dissertations](http://ci.nii.ac.jp/d/)
- [KAKEN](http://kaken.nii.ac.jp/)（科研費データベース）
- [IRDB](https://irdb.nii.ac.jp/)（学術機関リポジトリデータベース）
- [NII-REO](http://reo.nii.ac.jp/)（電子リソースリポジトリ）

## 設計含意

- **RDF/JSON-LDの2形式提供**は[[Content negotiation（書誌metadata）]]（[[2026-09-30 Crossref REST API]]）と同型の選択肢提供。CiNiiはURL拡張子でもAcceptでも取得できる
- DC-NDL拡張 ([[DC-NDL拡張schema]]) + JPCOAR + prism + datacite のschema組み合わせは、NDL Search ([[2026-09-30 NDL Search API]]) と互換部分を共有。両者の書誌を同じschemaで読み書きできる可能性がある
- **内容説明・目次はAPI不可、画面のみ**という制約は、論文評価に要旨や概要を見たい場合の経路設計に影響する。[[情報源の評価]]は本文ではなく書誌同定に重きを置く
- CC BY 4.0のオープンデータ部分は商用・再利用しやすい。[[マルチソースグラウンディング]]のsource拡張としてDeep Research agentにMCP経由で乗せやすい
- 4つのAPI（OpenURL/OpenSearch/RDF/JSON-LD）は[[図書館検索プロトコル（SRU_OpenSearch_OpenURL_OAI-PMH）]]の仲間。SRU/OAI-PMHが無いため、bulk harvestはデータセット公開（RDF/XML、年1回）または週次のAPI取得で代替
- 関連NIIサービス（KAKEN/IRDB/NII-REO）と合わせて、日本の学術書誌・研究助成・機関リポジトリ・電子リソースを[[マルチソースグラウンディング]]経路に組み込める

## 関連

- [[JSON-LD _ Linked Data書誌API]]、[[オープンデータ公開条件（CC BY 4.0等）]]
- [[図書館検索プロトコル（SRU_OpenSearch_OpenURL_OAI-PMH）]]、[[DC-NDL拡張schema]]
- [[2026-09-30 NDL Search API]]
- [[問いに応じた情報探索経路の設計]]
