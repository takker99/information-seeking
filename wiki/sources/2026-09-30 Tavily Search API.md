---
source_url: "https://docs.tavily.com/documentation/api-reference/endpoint/search"
accessed: 2026-09-30
tags: [web-search, search-api]
---

# Tavily Search API

Tavilyの公式Search endpoint reference。

## 要点

- 検索depthを選択し、順位付き結果と短いsource chunksを返す。
- 任意でLLM生成answer、cleaned raw content、言語・地域・domain・期間などの条件を指定できる。
- depthによってcredit消費とlatency/relevanceのtradeoffがある。正確な料金やquotaは利用前に別途確認する。
- `include_answer`を有効にしても、回答と元資料は別物として扱い、重要な出典は開いて確認する。

## 関連

- [[問いに応じた情報探索経路の設計]]
