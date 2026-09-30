---
tags: [scholarly-search, query-language]
---

# OpenAlex OQL

OpenAlex Query Language。保存可能・再利用可能なquery式を文字列で組む仕組み。

- OQLは[公式のOQLページ](/api/oql/)で定義。`filter`や`search`の組合せを文字列で記述できる ([[2026-09-30 OpenAlex API]])。
- 用途: 同じ検索を後日に再現する、定期的なデータ更新を監視する、repositoryに保存して[[検索過程の記録]]に統合する。
- 関連: [[検索とfilterの分離]]（OpenAlex）と機能が接続する。filter式をOQLで文字列化し、保存・共有できる。

経路設計上の含意:

- 探索の再現性: OQL文字列が**そのまま再現用query**になる。route記録にOQLを残すと、同じ問いを別の環境で再現できる
- bulk update: 同じOQLを定期実行すれば、研究領域のpublication flowを追跡できる
- [[引用追跡]]の前段: works集合をOQLで固め、authors/conceptsをfilterで展開

[[検索語の展開]]が人手の語彙拡張なら、OQLは**filterの構造化**を担う。同じ探索期間内に両方を使い分ける。
