---
tags: [search-api, output-format]
---

# 構造化出力schema

検索・合成APIにJSON Schemaを渡し、回答を`text`または`object`で構造化させる仕組み。fieldごとの出典紐付けも可能。

- Exa `outputSchema`: root typeは`text`/`object`。`object`は合計10プロパティ・ネスト2階層・配列はitems定義必須。`output`がresponseに入り、search typeに加えて約2秒の合成latencyが乗る ([[2026-09-30 Exa Search API]])。
- streamingで`grounding` chunkが返ると、output fieldごとにcitationsとconfidence（`low`/`medium`/`high`）が紐付く。[[情報源の評価]]の単位をURLからfieldに細分できる。
- 類似機能は他社の`include_answer`（[[2026-09-30 Tavily Search API]]）だが、Exaはschema駆動で形式を厳密に制御できる点が異なる。

経路設計上の含意:

- 探索結果を[[検索過程の記録]]の行と組み合わせると、fieldごとの出典とconfidenceが残る
- データベース・cacheに保存すると再利用時のschema整合性確認が必要（schema drift）

## 関連

- [[Multi-step deep search]]、[[Agent操舵フィールド]]
