---
tags: [search-api, design]
---

# 生検索結果APIと回答APIの分離

順位付きWeb検索結果（生データ）を返すAPIと、引用付きLLM回答を返すAPIを別エンドポイントとして提供する設計。

- Perplexity Search APIは「raw results for your own processing」用、引用付きLLM回答はAgent API側で別途提供されると明示 ([[2026-09-30 Perplexity Search API]])。
- 同じ構造が[[2026-09-30 Exa Search API]]・[[2026-09-30 Tavily Search API]]でも見られ、合成answerはoptionalで独立扱い。

効果:

- 利用側で「LLMに要約させる」「自前のパイプラインで再ランキング・抽出する」「結果を直接データベースに入れる」を選べる
- 結果の出典が**自前の処理で残る**ため、生成経路の[[情報源の評価]]を維持しやすい
- 二次利用（社内cache、独自評価dataset、引用追跡の前段）で使い回せる

経路設計上の位置:

- [[Deep Research agent]]のようなclosed-endedな研究タスクには[[2026-09-30 Gemini Deep Research Agent]]側のAgent APIが便利
- 自前で要約・検証・保存まで回したいときはSearch APIとLLMを別建てにする選択肢がある

## 関連

- [[Fast Search tier]]、[[ドメインフィルタ]]
