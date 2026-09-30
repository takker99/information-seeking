---
tags: [mcp, agent]
---

# MCPサーバー経由のsource拡張

agentをremote MCP（Model Context Protocol）サーバーに接続し、外部Tool/データsourceとして使う拡張方式。

- Gemini Deep Research Agentは`mcp_server` typeのTool設定でremote MCPサーバを接続できる。サーバ名・URL・認証情報・agentが呼べるToolの制限を渡せる ([[2026-09-30 Gemini Deep Research Agent]])。
- 役割: 公開WebやGoogle Searchに閉じず、社内API、独自database、構造化Toolを研究経路に組み込める。
- 設計含意: MCP対応Toolを1つ作れば、Deep Research agent以外のAI agentからも同じToolが呼べる（標準化protocolとして）。情報探索経路を「agentの中」ではなく「Tool側」に持たせる選択肢が増える。

[[マルチソースグラウンディング]]の実装手段の一つ。学術・図書館API（例: [[2026-09-30 OpenAlex API]]、[[2026-09-30 NDL Search API]]）をMCPで公開できれば、Deep Research agent経路にそのまま乗せられる。

## 関連

- [[マルチソースグラウンディング]]、[[Deep Research agent]]
