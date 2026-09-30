---
tags: [scholarly-search, design]
---

# 検索とfilterの分離

学術メタデータAPIで、全文検索（search）と構造化絞り込み（filter）を別endpoint/別パラメータとして提供する設計。

- OpenAlex: 各endpointにlist、filter、search、sort、group_by、page、select、get-singleの操作が共通 ([[2026-09-30 OpenAlex API]])。`filter`はIDやenum・数値・日付の構造条件、`search`は全文/keywordの類似検索。
- 推奨: **IDsでfilter**、曖昧なnameでfilterしない。"Smith"は数千author。先にOpenAlex IDをlookupしてからfilterする ([[2026-09-30 OpenAlex API]])。
- DOI/ORCID/ROR/ISSNは直接filterに使える。

[[検索語の展開]]（[[2026-09-30 Helsinki Information Seeking Guide]]）との接続:

- 人間が[[検索テクニック]]で展開した語彙は、最初keyword `search`に投げる
- 得られたIDを `filter` に渡すと、絞り込みと組合せが効く
- OQL（[[OpenAlex OQL]]）で保存可能なqueryに組み立てる

経路設計上の含意:

- [[引用追跡]]の前段: 既知DOIでworksを取得→authors/institutionsをfilterで辿る
- 探索の再現性: filterは構造化条件なので、search単独より再現性が高い（同じID集合は同じ結果集合になる）
