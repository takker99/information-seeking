---
tags: [ai-search, web-search]
---

# query fan-out

複雑な問いをsubtopicに分解し、複数のdata sourceに同時並行で問い合わせて結果を統合する検索手法。

- Google AI Modeは"query fan-out"として説明し、関連web contentの幅を広げる働きを期待する ([[2026-09-30 Google Search AI Mode]])。
- 統合の単位はsubtopicの集合。1回の問いに対し内部で複数のクエリが走り、回答はそれら結果を束ねる形になる。
- 含意: 結果には含まれるリンクの根拠確認が一層重要になる。fan-outで拾うsourceが複合するため、確認範囲は1リンクに留まらない。

図書館の[[content typeで探索先を選ぶ]]と比較すると、query fan-outは「複数databaseの同時検索」をシステム側で実行する操作。人間がA-Z listから選ぶのと、機能面で対応するが異なる単位。どちらが優れているかは問いの種類とsourceの粒度で変わる。

## 関連

- [[マルチモーダル入力の問い]]、[[生成UIの問い]]
