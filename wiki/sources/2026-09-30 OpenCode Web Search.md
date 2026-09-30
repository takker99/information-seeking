---
source_url: "https://opencode.ai/v2/docs/websearch/"
accessed: 2026-09-30
tags: [agent, web-search]
---

# OpenCode Web Search

OpenCodeの公式websearch機能説明。

## 要点

- OpenCodeの `websearch` はproviderを選べる。2026-09-30時点の文書にはExa、Firecrawl、Parallel、Tavilyが掲載されている。
- providerはUIから接続するか環境変数で設定し、設定・permissionで無効化や確認要求もできる。
- `random`選択では429後に別providerを試す仕組みがある。これはprovider品質の比較機能ではない。
- このWikiで比較する際は、単に「OpenCode検索」とせず、実際に選ばれたproviderと設定を記録する必要がある。

## 関連

- [[問いに応じた情報探索経路の設計]]
