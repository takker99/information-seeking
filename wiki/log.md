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

## [2026-10-01] file-back | SMS-2026S-reportでのScopus AI Deep Research複数ラウンド探索を事例分析

他Wiki（`~/git/SMS-2026S-report`）で2026-07-23〜24に実行されたScopus AI Deep Research複数ラウンド（13レポート: 地盤力学bridge 8軸＋講義接続5軸）＋キュレーション＋DOI検証＋fulltext ingestの一連の探索を、このWikiの最初の実地ケースとしてfile-back。新設: sources 1件（探索記録の一覧）+ analyses 1件（ケース分析）。既存concept 6件にケースのwikilinkを追加（Deep Research agent、データベース統合AIアシスタント、claimごとのconfidence score、引用追跡、検索過程の記録、生成AIで問いと検索語を作る）。「問いに応じた情報探索経路の設計」のケース運用節に実績を追記。
主な知見: ①Scopus AIの"Unable to Find"が研究ギャップ検出として機能した ②AIレポートを地図・論文本体を根拠とする二段構成でDOI誤り3件を検出 ③「Gemini DeepResearchと組み合わせた」という記憶は元repoに記録がなく混同と確認済み——記録が記憶より正確な事例
(touched 2 new pages + 6 concepts + analyses + index/log)

## [2026-10-01] file-back | ケース×概念群の交差分析で6知見を抽出

[[SMS-2026S-report Scopus AI Deep Research論文探索]]の記録と本Wikiの概念群を突き合わせ、単独では見えなかった知見6点を抽出・file-back。新規concept 3件: [[不在表示から研究ギャップを検出する]]（閉じたcorpus上のsemantic不在断定=negative survey近似）、[[探索履歴の偏り]]（記録の非対称が後の判断を歪める）、[[問いの反転]]（mismatch→向きの設計ミスとして修理、素材を使い回すpivot）。既存concept 3件を更新: [[query fan-out]]（語彙差駆動の分解という変種）、[[claimごとのconfidence score（research report）]]（判定対象はclaimでcitation metadataは別判定——High confidence行の引用に誤りが潜む）、[[検索過程の記録]]（本人の記憶の混同を検出する効果を追加）。analysesページに「Wiki知見との交差で見えた点」節を追加。
(touched 3 new concepts + 3 concept updates + analyses + index/log)
