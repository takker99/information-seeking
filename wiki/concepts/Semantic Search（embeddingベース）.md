---
tags: [scholarly-search, semantic-search]
---

# Semantic Search（embeddingベース）

keyword一致ではなく、embedding空間での意味近傍で文献を探す検索方式。書誌APIやDBで別endpointとして提供されることがある。

- OpenAlexは通常のkeyword `search`と別に [Semantic Search](/api/semantic-search/) を提供 ([[2026-09-30 OpenAlex API]])。
- 同じthemeでも語彙が違う関連研究を拾える。[[検索語の展開]]（同義語・訳語）と機能が重なるが、**機械が計算した意味近傍**を使うため、人間が展開しきれない関連も拾える可能性がある。
- [[2026-09-30 Helsinki Information Seeking Guide]]の「YSOシソーラスで多言語語彙を取る」の**自動版**に相当。

経路設計上の含意:

- 探索の前段で[[検索語の展開]]を補助する用途: 既知DOI/論文から意味近傍の関連研究を発見
- 限界: embedding modelと評価setが検索品質を決める。[[情報源の評価]]を後段に持つ前提で使う
- 検索の再現性: embedding modelが変わると結果集合が変わる。route記録にmodel/versionを残すと再現しやすい

[[Keenious]]（[[2026-09-30 Helsinki Information Seeking Guide]]が言及する類似論文検索）も意味近傍を使った論文推薦で、GUI版・DB統合AIアシスタント版 ([[データベース統合AIアシスタント]])と並ぶ経路。

## 関連

- [[検索語の展開]]、[[学術メタデータAPIの書誌グラフ]]
