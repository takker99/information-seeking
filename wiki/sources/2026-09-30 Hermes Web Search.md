---
source_url: "https://hermes-agent.nousresearch.com/docs/user-guide/features/web-search"
accessed: 2026-09-30
tags: [agent, web-search]
---

# Hermes Agent Web Search & Extract

Hermes Agentの公式Web Search & Extractガイド。

## 要点

- `web_search`と`web_extract`を別のmodel-callable toolとして提供する。
- 複数providerを選択でき、検索と本文抽出に異なるproviderを割り当てられる。search-only providerとextract対応providerがある。
- Providerやfree/keyed tier、keyless fallback、cache、長文extractのtruncate設定など、Agent側でrouteを組み合わせる設定がある。
- これらは設定可能性の事実であり、個々のproviderが返す根拠の質や各free tierの継続利用性は別途確認が必要。

## 関連

- [[問いに応じた情報探索経路の設計]]
