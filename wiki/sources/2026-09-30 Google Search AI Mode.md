---
source_url: "https://support.google.com/websearch/answer/16011537?hl=en"
accessed: 2026-09-30
tags: [ai-search, web-search]
---

# Google Search AI Mode

Google Search内の消費者向けAI検索モードに関するHelpページ。Gemini APIのDeep Research Agent仕様とは別の、Google Searchの利用者向け機能の説明。

## 要点

### 位置づけ

- AI ModeはAI Overviewsを強化したGoogleの「最も強力なAI search体験」。複雑な問いを1回のsearchで扱い、追質問とWeb linkで深掘りできる。
- 設定は更新中とページ冒頭に明記されている。説明が現時点の体験と一致しない可能性がある。

### アクセス

- [google.com/ai](https://google.com/ai)
- google.comの検索バーからAI Modeを選択
- Googleアプリのホーム画面アイコン

### 入力手段

- テキスト、声、画像、PDF/local/Drive file、Web URL。Chromeタブも追加できる（[AI Mode on Chrome](https://support.google.com/chrome/answer/16704170)）。

### 動作モデル - query fan-out

- 問いを複数のsubtopicに分解し、複数のdata sourceに対し**同時並行**に検索する。これによって関連web contentを広げ、回答に統合する。
- "Don't always get it right"（誤読・文脈の見落とし）と明記。重要情報は別の場所でも確認するよう案内。

### モデル選択

- "Fast" model: 通常の応答。
- "Pro" model: Gemini 3 Pro in AI Mode。18歳以上で個人Google Account。深い推論・generative UI・強化された画像生成（infographic等）。**日次利用上限**があり、超過後は次のリセットを待つかGoogle AI planにupgrade。

### 生成UI

- インタラクティブな図・チャート・シミュレーション。sliderやtoggleで変数を操作する形式。英語・サインイン必須。問いの中で「simulation」「interactive visual」「diagram」等を明示して起動する。

### パーソナライズ

- "Personal Intelligence"（18歳以上、historyとpersonalized recommendations有効時）: 過去のSearch Services Historyを参照し回答を調整。tell AI Mode to remember/forgetで制御。
- Workspace（Gmail/Calendar）・Google Photos連携で検索サービスをパーソナライズ可能。同意するとAI Modeがこれらのcontentへアクセスする。

### 補助機能

- Search Labsの"AI Mode" experiment: 18歳以上、新機能を先行体験。
- AI Mode history: 質問と回答を保存し、再開や削除ができる。
- フィードバック: thumbs up/down、Share more feedback（カテゴリ選択可）。

### データとプライバシー

- Search generative AI改善に、Searchとの相互作用（queryやfeedback）を利用。レビュー時はアカウントから切断し、自動で個人識別子や機微情報を除去。

## 関連

- [[query fan-out]]、[[マルチモーダル入力の問い]]、[[生成UIの問い]], [[Search履歴ベースの個人化]]
- [[2026-09-30 Gemini Deep Research Agent]] — API側で同名のDeep Researchを扱う別製品
