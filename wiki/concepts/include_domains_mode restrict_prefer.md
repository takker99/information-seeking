---
tags: [search-api, filtering]
---

# include_domains_mode restrict/prefer

ドメインフィルタの適用モード。`restrict`はハードフィルタ（指定domainのみ）、`prefer`は優先（他も探索、上位に来るだけ）。

- Tavily `include_domains_mode`: `restrict`（default、ハードフィルタ）または `prefer`（指定domainを優先しつつ他も探索）。`include_domains`未指定でこのmodeを設定すると400 ([[2026-09-30 Tavily Search API]])。
- Perplexityの[[ドメインフィルタ]]はallowlist（=Tavily `restrict`相当）のみで、中間挙動は出せない。Tavilyの方が[[情報源の評価]]の前段で「普段は広く、特定domainを上位化」ができる。
- 使い分け:
  - 規制領域（医学・法令等）でsource群を**狭める**: `restrict`
  - 普段通り広く探すが、信頼publisherを**上位化**: `prefer`
  - 既知domain群を[[content typeで探索先を選ぶ]]のpublisher集合と組み合わせて使う

## 関連

- [[ドメインフィルタ]]、[[検索depthとcreditのトレードオフ]]
