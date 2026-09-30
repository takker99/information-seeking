---
tags: [license, open-data]
---

# オープンデータ公開条件（CC BY 4.0等）

APIやデータセットがどのライセンスで公開されているかを確認し、二次利用可能性を判定する軸。

- [[2026-09-30 CiNii Web API]]のCiNii Books（図書・雑誌・著者・図書館のRDF/JSON-LD）は [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.ja) でオープンデータ公開。**内容説明・目次は提供元との契約で画面上のみ**（API取得不可）。
- [[2026-09-30 NDL Search API]]は**データプロバイダごとに許諾条件が異なる**。許諾が得られたmetadataのみAPIで提供。商用・継続アクセスでは事前連絡が必要な場合あり。
- 他のAPI:
  - [[2026-09-30 OpenAlex API]]: 全データ [CC0](https://creativecommons.org/publicdomain/zero/1.0/)
  - [[2026-09-30 Crossref REST API]]: ほぼ全metadata再利用自由、**abstractは一部publisher/author copyright**
  - [[2026-09-30 Tavily Search API]]、[[2026-09-30 Perplexity Search API]]等: responseの二次利用は各API利用規約に依存

経路設計上の位置:

- 二次利用・社内dataset・cache保存を前提とする経路では、API利用規約を毎回確認する
- [[情報源の評価]]で「公開されている」ことと「自由に再利用できる」ことは別。open access（学術）とopen data（API）は別軸
- [[マルチソースグラウンディング]]（[[2026-09-30 Gemini Deep Research Agent]]）で複数sourceを統合する場合、各sourceのlicenseが回答の再利用性に影響する
- [[引用追跡]]で[[履歴snapshot取得]]（[[2026-09-30 Exa Search API]]）を使う場合、取得対象pageのcopyrightとsnapshotの再配布条件に留意

## 関連

- [[情報源の評価]]
