---
source_url: "https://docs.cloud.google.com/gemini-enterprise-agent-platform/agents/use-deep-research"
accessed: 2026-09-30
tags: [deep-research, agent, api]
---

# Gemini Deep Research Agent

Google Cloud Gemini Enterprise Agent PlatformのDeep Research Agent利用ドキュメント。Geminiアプリ版の説明ではなく、開発者向けAgent Platformの情報。

## 要点

- Agentは問いを計画し、複数段階の検索・読解・反復を行って、引用付きレポートを作る。応答は非同期で、数分かかる場合がある。
- Google SearchとURL Contextを標準的なtoolとして使い、remote MCP、Agent Search、ファイル入力などを組み合わせられる。
- ページ上ではPreviewと明記され、Preview利用では機密・専有情報を入力しないよう注意されている。
- 複雑なサーベイの候補経路ではあるが、一般検索より品質が高いことをこの仕様ページだけで結論づけることはできない。

## 関連

- [[問いに応じた情報探索経路の設計]]
