# Log

追記専用のタイムライン。各エントリ: 見出し `## [YYYY-MM-DD] action | 短い題名` + 詳細は本文。
過去のエントリは書き換えない。追記のみ。

## [2026-09-30] initialize | 情報探索Wikiを開始

情報探索の方法を実例から研究する独立Wikiを初期化。最初の問いを「問いに応じた情報探索経路の設計」とし、サービス一覧ではなく探索方法・根拠評価・実例を育てる方針を記録した。

## [2026-09-30] research | 現行ツールと探索方法の初回スキャン

公式ドキュメントと大学図書館ガイドを検索・取得し、AI検索、Deep Research、検索API、Agentのprovider設定、学術メタデータAPI、図書館API、引用追跡の初期地図を作成。比較実験は未実施。web-search subagentはモデル解決エラー、web検索の一部カテゴリ検索はHTTP 429のため、直接の公式ドキュメント取得に切り替えた。
(touched 17 pages: 14 new sources + research question/index/log)

## [2026-09-30] file-back | 他Wikiの問いを探索ケースにする

他Wikiの未解決問いをinformation-seeking参照で調査し、対象Wikiで回答/ingestを完了した後、一連の探索方法をこのWikiへ一事例として記録する方針を明文化。作業中のrouteメモと、完了後のケースfile-backを分け、ドメイン知識の二重管理を避ける。
(touched 3 wiki pages + AGENTS.md/log)

## [2026-09-30] ingest | 14 sourcesを直列で再参照・ingest

sources/の全14ページに対し、`source_url`を再取得して要約を刷新。各sourceから概念を抽出し、47のconceptページを新設（図書館ガイド系7、AI検索系5、Deep Research系4、検索/抽出API系12、Agent harness系7、学術メタデータ系7、図書館系4）。analyses/の「初回の資料調査」tableを再参照後の概念で再構成し、再ingestで各社の設計パターン（生結果/回答分離・段階化・provider切替・schema-dehydrated・library protocol・二次利用条件）が反復している事実をまとめた。
(touched 14 sources + 47 concepts + analyses + index/log)

## [2026-09-30] ingest | Deep Research マルチベンダー化

Deep Research agent conceptページの出典がGemini一社に偏っていたため、他社の公式資料をweb検索で探索。OpenAI（API + ChatGPT help）、Anthropic（multi-agent engineering blog + Claude help）、Perplexity（Sonar→Agent API migration + Advanced Deep Research help）、xAI（Grok multi-agent docs）、Scopus AI（Deep Research announcement + tips）を直列でingestし、sources 8件・concept 6件を新設（LeadResearcher/Subagent役割分担、引用位置特定のCitationAgent、LLM-as-judge評価rubric、Interleaved thinking、subagent→filesystem直接output、claimごとのconfidence score）。Deep Research agentページをマルチベンダー実装の比較表に刷新し、設計のバリエーション軸（multi-agent粒度・source開閉・citation粒度・prompting中間段・cost model・途中steer）を整理。
(touched 8 sources + 6 concepts + Deep Research agent concept + index/log)
