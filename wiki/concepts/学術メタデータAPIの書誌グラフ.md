---
tags: [scholarly-search, api]
---

# 学術メタデータAPIの書誌グラフ

学術出版物・著者・所属機関・topics・concepts・出版者・助成機関などを結ぶグラフをREST APIで操作する設計。

- OpenAlexは works / authors / sources / institutions / topics / concepts / publishers / funders をendpointとして公開し、全データCC0 ([[2026-09-30 OpenAlex API]])。
- Crossref REST APIは会員登録のDOI・書誌メタデータを提供 ([[2026-09-30 Crossref REST API]])。
- 両者はdiscovery・書誌同定を支えるAPIで、全文取得は別経路。metadata中のabstractには著作権が残る場合がある。

経路設計上の位置:

- [[引用追跡]]の**機械化経路**: citation graphを[[2026-09-30 Illinois Citation Chasing]]で人が辿る代わりに、APIで大規模に辿れる
- [[マルチソースグラウンディング]]のsource拡張: Deep Research agentからMCP経由で学術書誌を呼び出せる
- [[content typeで探索先を選ぶ]]のcontent typeを**学際的に拡張**: works（論文）、authors、topicsで「同じ研究の周辺」を機械的に取れる

[[2026-09-30 Helsinki Information Seeking Guide]]の「分野別database」と比較:

- 図書館ガイドのdatabase選択は人手の判断（分野・主題・収録範囲）
- 学術メタデータAPIは機械可読な書誌グラフ。[[検索語の展開]]の語彙をDOI/author IDに変換する段階でも使う

信頼性・網羅性:

- Crossrefは登録publisher・trusted sources由来、未登録の文献は含まれない
- OpenAlexは curated core corpus 300M+ works、`corpus=all`でdatasets/repository recordsも含む
- 分野別の深さは[[content typeで探索先を選ぶ]]で別途確認が必要

## 関連

- [[引用追跡]]、[[マルチソースグラウンディング]]
