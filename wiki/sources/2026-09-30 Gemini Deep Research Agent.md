---
source_url: "https://docs.cloud.google.com/gemini-enterprise-agent-platform/agents/use-deep-research"
accessed: 2026-09-30
tags: [deep-research, agent, api]
---

# Gemini Deep Research Agent

Google Cloud Gemini Enterprise Agent PlatformのDeep Research Agent利用ドキュメント。Geminiアプリ版の説明ではなく、開発者向けAgent PlatformのPre-GA機能として提供される。

## 要点

### 位置づけ

- Gemini Deep Research Agentはmanaged AI agent。複数段階の研究ワークフロー（plan → multi-source search → iterate → output）を計画・実行・統合する。
- 公開Webとprivate enterprise dataの両方を横断し、包括的な引用付きレポートを生成する意思決定支援。
- 標準Geminiモデルとの対比: latency=秒 → 分、process=generate → output → plan→search→iterate→output、output=会話文とコード → 引用付き詳細レポート（図・チャート・インライン画像）。

### Pre-GA制約

- Preview段階。Limited support、pre-GAバージョン間の互換性は保証されない。
- 機微・proprietary・機密情報は入力禁止。商用・production利用は不可。

### 強み

- **Iterative process**: 即時応答ではなく、方法論的なmulti-step workflowで進める。
- **Advanced workloads**: due diligence、market analysis、competitive landscapingなど複雑タスク向け。
- **Extensive data grounding**: remote MCP server、internal institutional knowledge、uploaded file/folder（PDF・spreadsheet等）を同時並行で扱える。
- **Polished reporting**: presentation-ready visuals（financial graphs、inline infographics、market positioning matrices）をHTMLとimage modelで生成する。
- **High steerability**: prompt内でtone（technical、executive）、strict format、structured data tableなどを指定できる。

### アクセス

- グローバルendpoint **v1beta1**。Google Gen AI SDKまたはREST API直接リクエスト。
- 例はGitHub notebook (`intro_deep_research.ipynb`)。

### 前提条件

- Google Cloudプロジェクト、請求有効化、Agent Platform APIの有効化、必要なIAM role（roles/aiplatform.user、roles/serviceusage.serviceUsageConsumer）。

### タスクの開始

- research taskは反復検索・読解で数分かかる。**`background=True`が必須**（非同期実行）。
- 取得は **polling**（`stream=False`）と **streaming**（`stream=True`）の2方式。SDK/RESTとも`interaction_id`を返す。
- **deferred tier**: オフピークに自動スケジュールされ50%割引。`stream=False`必須。

### Streaming

- `background=True, stream=True`でthought summary・text・生成画像をリアルタイム受信。`event_type`（`interaction.created`, `step.delta`, `interaction.completed`, `error`）を使い、`interaction_id`と`last_event_id`を保持すれば接続断から再開できる。
- 切断回復: 元`interaction_id`でGETし、過去のeventを頭からreplayしてから続きを更新。

### Tools（複数sourceのgrounding）

- defaultで `google_search`（公開Web）と `url_context` を有効。Tool制限と拡張のため明示指定できる。
- 主要Tool:
  - `google_search`: 公開Web（デフォルト）
  - `enterprise_web_search`: コンプラ強化版
  - `vertex_ai_search`（Agent Search）: 自社サイト・文書集合
  - `mcp_server`: remote MCPサーバ接続、認証・利用Tool制限可
- Google Searchのみに絞る指定例: `tools=[{"type": "google_search"}]`。

### 設計含意

- Plan→Search→Iterate→Outputのloopは[[content typeで探索先を選ぶ]]や[[引用追跡]]を自動化したものに相当する。人間は問いと初期方針を提示し、agentがsource選択と反復を担う。
- grounding sourceにMCP・Agent Search・enterprise dataまで並べると、1つのagent経路で[[query fan-out]]と[[引用追跡]]の両方を含むsource graph探索を実行できる。
- 引用はinlineでレポートに埋め込まれるが、出典の正確さは人間が確認する単位は依然残る。

## 関連

- [[Deep Research agent]]、[[非同期研究タスク]]、[[マルチソースグラウンディング]]、[[MCPサーバー経由のsource拡張]]
- [[2026-09-30 Google Search AI Mode]] — 消費者向けAI検索
- [[問いに応じた情報探索経路の設計]]
