---
source_url: "https://help.openalex.org/api/"
accessed: 2026-09-30
tags: [scholarly-search, api]
---

# OpenAlex API

OpenAlexの公式REST API reference。works / authors / sources / institutions / topics / concepts等を含む学術情報グラフをHTTP APIで検索する。データは[CC0](https://creativecommons.org/publicdomain/zero/1.0/)。

## 要点

### 基本

- base URL: `https://api.openalex.org`
- 認証: `api_key`クエリパラメータ（無くても基本機能は無料で試せる）
- 全データCC0、licenseに関する懸念は原則無い
- LLM/agent向けに[LLM Quick Reference](/api/llm-quick-reference/)と[OpenAPI spec](/openapi.json)を提供

### Endpoint

エンティティごとにendpoint: `/works`、`/authors`、`/sources`、`/institutions`、`/topics`、`/concepts`、`/publishers`、`/funders`。

各endpoint共通の操作: list、filter、search、sort、group_by、page、`select`（field選択）、ID指定で単一entity取得。

### 認証・rate

- basic use無料
- [free API key](/api/authentication/)で**日次budget 10倍**
- 重い用途は[pay-as-you-go](/access/pricing/)
- website自体も同じpublic endpointで稼働

### 重要な落とし穴

- **IDsでfilter、nameでfilterしない**: "Smith"は数千author、"MIT"は複数institution。先にOpenAlex IDをlookupしてからfilterする。DOI/ORCID/ROR/ISSNは直接使える
- **Nested entityはdehydrated返却**: ID + display nameのみのstub。詳細が必要なら別途取得
- **defaultはcurated core corpus (300M+ works)**。`corpus=all`でopt-inのexpansion（datasets/repository records、約60%増）
- **全field snake_case**
- **AI agentにはLLM Quick Referenceを渡す**のが公式推奨

### 検索の種類

- keyword-based `search`（API全体）
- [Semantic Search](/api/semantic-search/)（embedding-based、別途仕様）
- [OQL](/api/oql/)（OpenAlex Query Language、保存可能な表現力あるquery）

### Response envelope

```json
{
  "meta": {
    "count": 286750097,
    "page": 1,
    "per_page": 25,
    "cost_usd": 0.0001
  },
  "results": [...],
  "group_by": []
}
```

`meta.count`は総一致数、`meta.page`/`meta.per_page`（default 25、max 100）、`meta.cost_usd`は1 callのcost（pay-as-you-go向け）。

### セキュリティ

- text field（title、abstract、affiliation）は外部source由来でサニタイズ無し。web表示や処理では**untrusted textとして扱う**: HTML escape、prepared statement、OWASP XSS防止策など。
- 現状悪意あるpayload観測は無いが、原理上可能性あり。

## 設計含意

- ID指定filterはDOI/ORCID/ROR/ISSNを既に持っている場合に有用。図書館目録・書誌・著者IDをキーとして[[引用追跡]]の前段で[[2026-09-30 Crossref REST API]]と並列に使える
- `meta.cost_usd`がresponseに含まれるため、bulk呼び出しの**cost計算がAPI自体で可能**。pay-as-you-go利用時の予算管理に直結
- semantic searchとkeyword searchは別endpoint。[[情報源の評価]]で「検索方法の差が結果集合の差を生む」ことを意識する
- CC0 datasetは[[content typeで探索先を選ぶ]]のcontent typeを**field別に拡張**できる（埋め込みからの意味検索、書誌同定、機関ランキング等）
- AI agent向けにLLM Quick ReferenceとOpenAPI specがある。[[マルチソースグラウンディング]]のsource拡張候補としてDeep Research agent経路にMCP経由で乗せやすい

## 関連

- [[学術メタデータAPIの書誌グラフ]]、[[検索とfilterの分離]]、[[Semantic Search（embeddingベース）]]、[[Dehydrated nested entity]]、[[OpenAlex OQL]]
- [[2026-09-30 Crossref REST API]]
- [[問いに応じた情報探索経路の設計]]
