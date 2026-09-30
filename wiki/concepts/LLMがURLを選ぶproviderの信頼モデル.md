---
tags: [agent, trust-model]
---

# LLMがURLを選ぶproviderの信頼モデル

検索APIがindexを返すのではなく、LLMがURLとタイトル/descriptionを生成する設計。untrusted input経由の攻撃面で信頼性が異なる。

- 例: xAI Grokはserver-side `web_search` toolで**Grok自身がURLとdescriptionを生成** ([[2026-09-30 Hermes Web Search]])。index-based provider（Brave/Tavily/Exa）が逐語結果を返すのとは異なる。
- リスク: 悪意あるquery（untrusted upstream経由）でattacker-chosen URLを返す可能性。URL選択がモデル出力に依存。
- 推奨: untrusted input経路で得られたURLはfetch前に検証する。descriptionやtitleを根拠にせず、URL自体と実際のpage contentで[[情報源の評価]]を行う。

経路設計上の位置:

- OpenAI Native (Codex)も同じserver-side tool型で、LLMがURLを選ぶ構造
- [[2026-09-30 Gemini Deep Research Agent]]の`google_search` tool設定はindex-basedだが、Deep Research agentのplan→search→iterate→outputの中でURL選択が起きる点ではLLM駆動
- [[2026-09-30 OpenCode Web Search]]・[[2026-09-30 Hermes Web Search]]のkeyless ringやper-capability backend選択では、信頼モデルが違うproviderが混在しうる。route記録に**どの信頼モデルのproviderを使ったか**を残す

## 関連

- [[情報源の評価]]
