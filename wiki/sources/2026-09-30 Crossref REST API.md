---
source_url: "https://www.crossref.org/documentation/retrieve-metadata/rest-api/"
accessed: 2026-09-30
tags: [scholarly-search, metadata, api]
---

# Crossref REST API

Crossrefに登録された学術コンテンツのmetadataを取得する公式REST API。

## 要点

- `/works`等を通じて、会員やtrusted sourcesが登録したDOI、著者、刊行物等のmetadataを検索・取得できる。
- 公開APIの利用にsign-upは不要。metadataには登録内容が反映されるため、欠落・誤りもありうる。
- APIは書誌・識別子の発見に使うもので、全文を提供するAPIではない。metadata中のabstractには著作権が残る場合がある。

## 関連

- [[問いに応じた情報探索経路の設計]]
