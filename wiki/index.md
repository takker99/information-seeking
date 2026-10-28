# Wiki Index

全ページのカタログ。各エントリ1行: `- [ページタイトル](パス) — 1行要約`
Query時は最初に読む。
→ 候補ページの本文は `bash .agents/scripts/read-page.sh "<タイトル>"` で読む（末尾に1 hop・2 hopの関連ページが付く。パスを直接 read するとhop情報が得られない）

## top-level

- [overview](overview.md) — このwikiの俯瞰図

## concepts

### 探索の基本手続き

- [検索語の展開](concepts/検索語の展開.md) — key concepts・同義語・シソーラス・訳語の拡張
- [検索テクニック](concepts/検索テクニック.md) — Boolean演算子・phrase search・truncation・advanced search・field制限
- [検索結果の広げ方と絞り方](concepts/検索結果の広げ方と絞り方.md) — 結果量に応じた調整とdatabase切替
- [検索過程の記録](concepts/検索過程の記録.md) — search journalの項目と運用。本人の記憶の校正装置でもある
- [content typeで探索先を選ぶ](concepts/content typeで探索先を選ぶ.md) — 必要な資料種からdatabase・guideを選ぶ
- [引用追跡](concepts/引用追跡.md) — 後方/前方のcitation graph辿り
- [情報源の評価](concepts/情報源の評価.md) — 学術性・peer review・Publication Forum

### 生成AI・AI検索

- [生成AIで問いと検索語を作る](concepts/生成AIで問いと検索語を作る.md) — 汎用生成AIの問い・語彙支援と限界
- [データベース統合AIアシスタント](concepts/データベース統合AIアシスタント.md) — Helka AI Search・Scopus AI等のDB内AI検索
- [query fan-out](concepts/query fan-out.md) — 問いのsubtopic分解と並行検索
- [マルチモーダル入力の問い](concepts/マルチモーダル入力の問い.md) — テキスト以外の入力素材
- [生成UIの問い](concepts/生成UIの問い.md) — simulation・diagram等のgenerative UI
- [Search履歴ベースの個人化](concepts/Search履歴ベースの個人化.md) — Personal Intelligence・履歴ベース回答

### Deep Research agent

- [Deep Research agent](concepts/Deep Research agent.md) — plan→search→iterate→outputのmanaged agent（Gemini/OpenAI/Anthropic/Perplexity/xAI/Scopusのマルチベンダー実装）
- [非同期研究タスク](concepts/非同期研究タスク.md) — backgroundタスクとpolling/streaming
- [マルチソースグラウンディング](concepts/マルチソースグラウンディング.md) — 複数source種を統合して答える
- [MCPサーバー経由のsource拡張](concepts/MCPサーバー経由のsource拡張.md) — remote MCPをagent経路に組込む
- [LeadResearcher / Subagent 役割分担（orchestrator-worker）](concepts/LeadResearcher_Subagent 役割分担（orchestrator-worker）.md) — Anthropic型multi-agent pattern
- [引用位置特定のCitationAgent](concepts/引用位置特定のCitationAgent.md) — subagent→CitationAgentの引用処理
- [LLM-as-judge評価rubric](concepts/LLM-as-judge評価rubric.md) — agentic systemの評価rubric
- [Interleaved thinking](concepts/Interleaved thinking.md) — extended thinkingのtool呼び出し合間での利用
- [subagentからfilesystemへ直接output](concepts/subagentからfilesystemへ直接output.md) — game of telephone回避
- [claimごとのconfidence score（research report）](concepts/claimごとのconfidence score（research report）.md) — 出力の透明性軸。判定対象はclaimで書誌metadataは別判定

### 検索・抽出API

- [生検索結果APIと回答APIの分離](concepts/生検索結果APIと回答APIの分離.md) — PerplexityのSearch APIとAgent API
- [Multi-Query検索](concepts/Multi-Query検索.md) — 1リクエストに複数query
- [ドメインフィルタ](concepts/ドメインフィルタ.md) — allowlist/denylistとrestrict/preferの適用モード
- [構造化出力schema](concepts/構造化出力schema.md) — JSON Schemaでoutputを制御
- [Agent操舵フィールド](concepts/Agent操舵フィールド.md) — objective・systemPromptでの操舵
- [ページ本文の段階取得](concepts/ページ本文の段階取得.md) — text/highlights/summaryの段階取得、cache制御と履歴snapshot
- [検索depthとcreditのトレードオフ](concepts/検索depthとcreditのトレードオフ.md) — Tavilyのsearch_depth課金・auto_parametersの暗黙昇格、PerplexityのFast tier、Exaのmulti-step deep search

### Agent harness

- [検索providerの抽象化](concepts/検索providerの抽象化.md) — backend差替え可能な薄い層
- [provider切替とrate-limit fallback](concepts/provider切替とrate-limit fallback.md) — OpenCodeの429時provider切替とHermesのkeyless ring+one-shot rescue
- [検索と抽出のbackend分離](concepts/検索と抽出のbackend分離.md) — search/extractを別providerに
- [結果cacheとfan-out coalesce](concepts/結果cacheとfan-out coalesce.md) — subagent並列時のcache統合
- [Truncated extractとon-disk全本文](concepts/Truncated extractとon-disk全本文.md) — head/tail window+disk全保存
- [LLMがURLを選ぶproviderの信頼モデル](concepts/LLMがURLを選ぶproviderの信頼モデル.md) — xAI等のLLM駆動URLの信頼差

### 学術メタデータ

- [学術メタデータAPIの書誌グラフ](concepts/学術メタデータAPIの書誌グラフ.md) — OpenAlex/Crossrefのdiscovery API
- [検索とfilterの分離](concepts/検索とfilterの分離.md) — keyword searchと構造化filter
- [Semantic Search（embeddingベース）](concepts/Semantic Search（embeddingベース）.md) — embedding近傍の文献検索
- [Dehydrated nested entity](concepts/Dehydrated nested entity.md) — ID+nameのstub返却
- [OpenAlex OQL](concepts/OpenAlex OQL.md) — 保存可能なquery言語
- [DOI書誌メタデータとPolite pool](concepts/DOI書誌メタデータとPolite pool.md) — DOI起点APIとmailto識別子
- [Content negotiation（書誌metadata）](concepts/Content negotiation（書誌metadata）.md) — 単一recordの形式切替

### 図書館・書誌

- [図書館検索プロトコル（SRU/OpenSearch/OpenURL/OAI-PMH）](concepts/図書館検索プロトコル（SRU_OpenSearch_OpenURL_OAI-PMH）.md) — 図書館系の標準protocol
- [DC-NDL拡張schema](concepts/DC-NDL拡張schema.md) — 日本の図書館Dublin Core拡張
- [JSON-LD / Linked Data書誌API](concepts/JSON-LD _ Linked Data書誌API.md) — RDF/JSON-LDでの書誌取得
- [オープンデータ公開条件（CC BY 4.0等）](concepts/オープンデータ公開条件（CC BY 4.0等）.md) — 二次利用条件の判定軸

### 実地ケース由来の方法論

- [探索履歴の偏り](concepts/探索履歴の偏り.md) — 蓄積した記録の非対称が後の比較判断にバイアスを与える
- [問いの反転](concepts/問いの反転.md) — mismatch発覚時に問いを逆向きに組み替え、素材を使い回すpivot
- [不在表示から研究ギャップを検出する](concepts/不在表示から研究ギャップを検出する.md) — curated corpus上のsemantic不在断定をnegative survey近似として使う
- [引用ネットワーク断絶の検出手法](concepts/引用ネットワーク断絶の検出手法.md) — 意味近接×引用不在・構造切れ目・時間異常の3次元と、DB境界・メタ欠落・名寄せ・用語断絶の落とし穴
- [未知異分野の発見（意味近接×引用不在）](concepts/未知異分野の発見（意味近接×引用不在）.md) — ペア指定なしで意味近接×引用欠落から候補異分野を列挙する発見モード。LBD・overlayゼロセル列挙・王子分析

## entities

（なし）

## sources

- [2026-09-30 Google Search AI Mode](sources/2026-09-30 Google Search AI Mode.md) — 消費者向けAI検索。query fan-out、マルチモーダル入力、生成UI、Personal Intelligence
- [2026-09-30 Gemini Deep Research Agent](sources/2026-09-30 Gemini Deep Research Agent.md) — Pre-GA非同期・multi-source research Agent。polling/streaming/deferred tier
- [2026-09-30 OpenAI Deep Research API](sources/2026-09-30 OpenAI Deep Research API.md) — Responses API + 専用model。web_search/file_search/code_interpreter/remote MCP (search+fetch interface)
- [2026-09-30 OpenAI ChatGPT Deep Research Help](sources/2026-09-30 OpenAI ChatGPT Deep Research Help.md) — consumer側Deep Research。3-stepフロー、sites filter (restrict/prioritize)、Apps read-only
- [2026-09-30 Anthropic Multi-Agent Research System](sources/2026-09-30 Anthropic Multi-Agent Research System.md) — LeadResearcher + Subagents + CitationAgent。90.2%性能向上、8 prompting原則
- [2026-09-30 Anthropic Claude Research Help](sources/2026-09-30 Anthropic Claude Research Help.md) — Claude consumer Research。Web検索必須、Gmail/Calendar/Docs連携
- [2026-09-30 Perplexity Sonar Deep Research to Agent API Migration](sources/2026-09-30 Perplexity Sonar Deep Research to Agent API Migration.md) — Sonar Chat Completions → Agent API preset (fast/low/medium/high/xhigh)への移行
- [2026-09-30 Perplexity Advanced Deep Research Help](sources/2026-09-30 Perplexity Advanced Deep Research Help.md) — Advanced Deep Research。code sandbox・clarifying・follow-up during・key findings as you go
- [2026-09-30 xAI Grok Multi-Agent Research](sources/2026-09-30 xAI Grok Multi-Agent Research.md) — grok-4.20-multi-agent。4/16 agents切替、leader agentのみ露出、sub-agent stateはencrypted
- [2026-09-30 Scopus AI Deep Research](sources/2026-09-30 Scopus AI Deep Research.md) — Elsevier学術領域特化。peer-reviewed Scopus限定、claimごとのconfidence score
- [2026-09-30 Perplexity Search API](sources/2026-09-30 Perplexity Search API.md) — 生検索結果APIとAgent APIの分離、Fast tier、Multi-Query、domain filter
- [2026-09-30 Exa Search API](sources/2026-09-30 Exa Search API.md) — search depth・outputSchema・agent操舵・本文段階取得・snapshot
- [2026-09-30 Tavily Search API](sources/2026-09-30 Tavily Search API.md) — search_depth・topic・domain mode・auto_parameters・関連エンドポイント
- [2026-09-30 OpenCode Web Search](sources/2026-09-30 OpenCode Web Search.md) — 4 provider（Exa/Firecrawl/Parallel/Tavily）と429 fallback
- [2026-09-30 Hermes Web Search](sources/2026-09-30 Hermes Web Search.md) — 10 provider・per-capability分離・keyless ring・cache・xAI等の信頼モデル差
- [2026-09-30 OpenAlex API](sources/2026-09-30 OpenAlex API.md) — works/authors等・CC0・ID filter・semantic search・OQL
- [2026-09-30 Crossref REST API](sources/2026-09-30 Crossref REST API.md) — DOI書誌metadata・polite pool・content negotiation・Research Nexus
- [2026-09-30 NDL Search API](sources/2026-09-30 NDL Search API.md) — SRU/OpenSearch/OpenURL/OAI-PMHとDC-NDL拡張schema・provider別利用条件
- [2026-09-30 CiNii Web API](sources/2026-09-30 CiNii Web API.md) — OpenURL/OpenSearch/RDF/JSON-LD、CiNii Books CC BY 4.0オープンデータ
- [2026-09-30 Helsinki Information Seeking Guide](sources/2026-09-30 Helsinki Information Seeking Guide.md) — 検索語展開・シソーラス・AI Search of Helka・Scopus AI等DB統合AI案内
- [2026-09-30 Illinois Library Search Strategies](sources/2026-09-30 Illinois Library Search Strategies.md) — 探索前の戦略立案とsearch journalによる記録
- [2026-09-30 Illinois Citation Chasing](sources/2026-09-30 Illinois Citation Chasing.md) — 後方/前方citation chasingとcitation indexing database
- [2026-10-01 SMS-2026S-report Scopus AI探索記録](sources/2026-10-01 SMS-2026S-report Scopus AI探索記録.md) — 別Wikiで実行したScopus AI Deep Research複数ラウンド（13レポート）のraw記録一覧
- [2026-10-28 引用断絶検出手法のsubagent相談（PGE-2026A）](sources/2026-10-28 引用断絶検出手法のsubagent相談（PGE-2026A）.md) — 計量書誌学subagentの手法検証・実測と親セッション検証。M&K 1953不在、RMP 1996にMogami系ゼロ
- [2026-10-29 引用断絶検出手法のパイロット報告（分野ペアA・D）](sources/2026-10-29 引用断絶検出手法のパイロット報告（分野ペアA・D）.md) — 検証モード手順のsubagent単独実行2本の報告。A: JSPT→粒状物理のゼロセル、D: CT計測の経路置換型断絶

## analyses

- [問いに応じた情報探索経路の設計](analyses/問いに応じた情報探索経路の設計.md) — 探索経路の初期研究課題と、14 sources再ingest後の設計パターン整理、他Wikiの問いを探索ケースにする運用
- [SMS-2026S-report Scopus AI Deep Research論文探索](analyses/SMS-2026S-report Scopus AI Deep Research論文探索.md) — 学術限定DR複数ラウンド×キュレーション×DOI検証×fulltext ingestの実地ケース。AIレポートを地図、論文を根拠とする二段構成が効いた
- [分野間引用断絶の探索事例（Mogami・金谷経路）](analyses/分野間引用断絶の探索事例（Mogami・金谷経路）.md) — subagent並列相談+spot-check検証+回顧seed手作業で断絶と位相分離を検出した2つ目の実地ケース。自動ツール経路は未検証
- [手法検証パイロットの実施記録（分野ペアA・D）](analyses/手法検証パイロットの実施記録（分野ペアA・D）.md) — 成功判定を渡さないusability-test相当のパイロット2本。4基準合格、手順書の差分5項を抽出
