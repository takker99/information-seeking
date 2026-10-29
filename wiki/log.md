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

## [2026-10-28] migrate | template 2026-10-28版を適用

- `.agents/skills/llm-wiki-write` を導入し、旧 `llm-wiki-ingest` を置き換え
- `.agents/scripts/` に search-pages.sh / read-page.sh / diagnose-wiki.sh / number-dup-check.sh を追加
- lint を template 版へ更新（オープンリンク分類、重複wikilink、raw参照、sourcesポインタ等）
- AGENTS.md の汎用規則を template に合わせ、情報探索固有の運用（情報探索手順・出典・API確認日）は維持
- index.md は維持（PGE-2026Aのindex.md廃止実験は適用しない）
- 既存ページの重複wikilinkは未整理。新lintが検出するため、今後のlint/file-backで整理する

## [2026-10-28] refactor | template schemaに合わせて重複リンクを整理

- 47ページの重複wikilink 156ペア（余分な出現195回）を解消。関連節の再掲は削除し、本文・表内の2回目以降は平文化した。analysesの47概念列挙はリストを保持したまま平文の列挙にした
- 出典追加: [[探索履歴の偏り]]・[[問いの反転]]の実例節に [[2026-10-01 SMS-2026S-report Scopus AI探索記録]] を引用
- 意味修正: 「生結果と回答生成の分離」と「検索と抽出のbackend分離」は分離する対象が異なる別軸であることを明記
- index.mdのtypo（mailo→mailto）を修正、overview.mdに最初の実地ケースと現在の規模を追記
- lint: DUPLICATE 156→0、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0

## [2026-10-29] refactor | M1/M3の概念統合

- M1: `concepts/include_domains_mode restrict_prefer.md` を `concepts/ドメインフィルタ.md` に統合。「適用モード: restrict / prefer」節としてTavily `include_domains_mode`（restrict/prefer、`include_domains`未指定時の400）、Perplexity allowlistとの差、使い分けを収めた。旧ページは削除
- M3: `concepts/auto_parametersの暗黙昇格.md` を `concepts/検索depthとcreditのトレードオフ.md` に統合。「auto_parametersによる暗黙昇格」節として`search_depth: advanced`への暗黙昇格・2 credits・明示指定の推奨・Exa/Perplexityとの比較を収めた。旧ページは削除
- リンク更新: `sources/2026-09-30 OpenAI ChatGPT Deep Research Help` は `[[ドメインフィルタ|include_domains_mode restrict/prefer]]`、`sources/2026-09-30 Tavily Search API` の関連節と `analyses/問いに応じた情報探索経路の設計` の表は統合先の既存リンクに寄せた。旧タイトルへのwikilinkは0
- `index.md` は旧2行を削除し、統合先2行の要約にrestrict/prefer・auto_parametersを含めた
- lint: DUPLICATE 0、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0、OPEN_LINKは `[[Keenious]]` のみ

## [2026-10-29] refactor | M2/M4/M5の概念統合とindex再編

承認済みrefactoringの残りを実行。index維持・conceptsのatomic性・事実と出典の不変を保った。

- M2: `concepts/履歴snapshot取得.md` を `concepts/ページ本文の段階取得.md` に統合。`## 履歴snapshot（特定時点の取得）` 節として `snapshotAsOf` のISO 8601指定・stored version返却・live取得なし・`maxAgeHours`/`subpages`との関係・用途（研究reproducibility、archive救済、監査差分）を収めた。旧ページは削除
- M4: `concepts/Fast Search tier.md` と `concepts/Multi-step deep search.md` を `concepts/検索depthとcreditのトレードオフ.md` に統合。Tavilyの`search_depth`/creditと既存のauto_parameters節を維持したまま、`## Perplexity Fast Search tier`（`search_type: "fast"`、$1.00/1000リクエスト、SDK互換workaround）と`## Exa Multi-step deep search`（`deep`/`deep-reasoning`/`deep-lite`、`additionalQueries`、Deep Research agentとの対応）を追加。旧2ページは削除
- M5: `concepts/429 fallback機構.md` と `concepts/Keyless ringとone-shot rescue.md` を新規 `concepts/provider切替とrate-limit fallback.md` に統合。OpenCodeの429時cooldown切替、Hermesのkeyless ring + one-shot rescue、両者の共通パターンと差異（切替契機・切替先・key無し動作・失敗時挙動・無効化）、route記録への含意を比較表付きで整理。旧2ページは削除
- リンク更新: 旧タイトルへのwikilinkは0。表示名で旧名を残したのは `concepts/オープンデータ公開条件（CC BY 4.0等）` の `[[ページ本文の段階取得|履歴snapshot取得]]` のみ。`analyses/問いに応じた情報探索経路の設計` の47概念列挙は平文の履歴記述として維持し、設計パターン節の3項目は統合後の名称に合わせた
- `index.md`: 統合で旧4行を削除し、統合先2行の要約を更新。conceptsに`### 実地ケース由来の方法論`を新設し、探索履歴の偏り・問いの反転・不在表示から研究ギャップを検出するの3行を移動（要約は不変）
- 重複節整理: `concepts/claimごとのconfidence score（research report）` の末尾`実例:`節を削除し、固有情報（Scopus AI Key Findings TableのHigh/Medium列が実用形）を制約bulletへ統合
- `overview.md`: ページ数の記載をやめ、2026-10-29時点の運用に更新
- lint: DUPLICATE 0、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0、OPEN_LINKは`[[Keenious]]`のみ。最終76ページ

## [2026-10-29] file-back | PGE-2026Aの分野間引用断絶探索を編み込む

- 別Wiki（PGE-2026A）で2026-10-28に実行した分野間引用断絶の探索を、2つ目の実地ケースとしてfile-backした
- 新規raw 3本: subagent①計量書誌学相談記録・subagent②系譜ツール調査記録・メインセッション検証報告。OpenCodeのセッションDBから会話本文を抽出し、subagent出力の文字化けは取得時点のまま保持（修正済みの内容はメイン検証報告側を正とする）
- 新規sources: 2026-10-28 引用断絶検出手法のsubagent相談（PGE-2026A）
- 新規concepts: 引用ネットワーク断絶の検出手法（3次元フレーム・既存手法の落とし穴・3限界・名寄せ・ハイブリッド現実解・subagent実行用手順）。自動ツール経路は未実行であることを明示
- 新規analyses: 分野間引用断絶の探索事例（Mogami・金谷経路）（確認済みの根拠と未実行の自動ツール経路を区別し、手法検証パイロットの計画と成功判定を記録）
- 更新: 不在表示から研究ギャップを検出する（関連節に断絶検出手法を追加）・index.md・overview.md
- lint: DUPLICATE 0（初回は新analysesページの重複リンク1件を指摘し平文化で解消）、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0、OPEN_LINKは `[[Keenious]]` のみ。最終79ページ

## [2026-10-29] file-back | 発見モードの概念ページを切り出す

- 検証モード（指定ペアの断絶検定）に対し、ペアを指定しない発見モードを独立ページに切り出した
- 新規concepts: 未知異分野の発見（意味近接×引用不在）。LBDと多言語embedding・overlay mapsゼロセル列挙・sleeping beauty王子分析・孤立クラスタ検出・LLM系LBDを、発見モードでの使い方と限界付きで収録。引用事象前提の手法の不適性を明記。縮小版パイロットの手順は未実行の提案として明示
- 更新: 引用ネットワーク断絶の検出手法（関連節に発見モードページを追加）・sourcesページ（Moreau & Yamanishi 2023の「発見が実作物にならない」問題をsubagent①報告の要点に追加）・index.md
- lint: DUPLICATE 0（初回は新ページ内の重複リンク1件を指摘し関連節から解消）、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0、OPEN_LINKは `[[Keenious]]` のみ。最終80ページ

## [2026-10-29] file-back | 手法検証パイロット（分野ペアA・D）を編み込む

- 引用ネットワーク断絶の検出手法の検証モード手順を、成功判定を渡さない合成パイロット2本（subagent単独実行・親介入なし）で試した。A（粉体工学×粒状統計物理）・D（X線CT計測×地盤粒状CT）とも4基準合格
- 新規raw 2本: パイロットA・Dの最終報告。OpenCodeセッションDBからの抽出で、最終応答が2メッセージに分かれていたDは連結した。日本語の乱れは取得時点のまま保持
- 新規sources: 2026-10-29 引用断絶検出手法のパイロット報告（分野ペアA・D）
- 新規analyses: 手法検証パイロットの実施記録（分野ペアA・D）。usability-test設計・4基準合否・手順書が喚起した実装とパイロットが生んだ差分5項・コスト（入力トークンA約805千・D約356千）
- 更新: 引用ネットワーク断絶の検出手法（実行手順に有効年代確定とrefs=0救済・per-work切替を追加、COCIプレフィックス列挙をツールに追加、判定の語彙5種を新設、意図的輸送経路を理論的背景に追記、パイロット実績を冒頭に明記）・未知異分野の発見（検出対象の型に並行発明非結合と経路置換型断絶を追記）・index.md
- ドメイン発見（JSPT×粒状物理の断絶構造と橋群・CT計測の経路置換構造）はPGE-2026A側sessionで後日編み込むため、本wikiはポインタで留めた
- lint: DUPLICATE 0、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0、OPEN_LINKは `[[Keenious]]` のみ。最終82ページ

## [2026-10-29] file-back | 新しく見つかった研究群の調査設計

- 既存の文献調査の後に同領域の新しい研究群が見つかった状況を扱う調査指示の項目を、conceptsに切り出した。原因を引用断絶に限定せず、DB境界・語彙断絶・探索経路の欠落として診断する点を先頭に置いた
- 新規concepts: 新しく見つかった研究群の調査設計。記述/関係の2分割、発見経路の一次データ化、不在主張への検出限界、引用ゼロと接触ゼロの分離、判定語彙の指定、比較前の記録量対称性、停止条件と未確認の分離、指示テンプレートを収録。判定基準を指示文に織り込むかusability-test用に伏せるかの使い分けも含む
- 更新: 引用ネットワーク断絶の検出手法（subagent実行用の手順に新ページへの参照を追加）・index.md
- lint: DUPLICATE 0、ORPHAN 0、index欠損/stale 0、raw切れ 0、sourcesポインタ欠落 0、OPEN_LINKは `[[Keenious]]` のみ。最終83ページ
