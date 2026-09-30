---
tags: [agent, thinking]
---

# Interleaved thinking

extended thinking（LLMが回答前にthinking traceを出力する仕組み）をtool呼び出しの合間に挟む運用。tool結果の質を評価し、次のqueryを調整する。

- Anthropic ResearchのSubagentは各tool呼び出し後にinterleaved thinkingでtool結果を評価し、gapsを埋めるためにqueryをrefineする ([[2026-09-30 Anthropic Multi-Agent Research System]])
- Lead agentはextended thinkingでtool選択・query複雑さ・subagent数・各役割を計画する

[[Deep Research agent]]一般の効果:

- agentの自律的探索の質を上げる
- 「scouring the web endlessly for nonexistent sources」のような発散を防ぐ
- 評価rubric ([[LLM-as-judge評価rubric]]) で「source quality」「tool efficiency」を改善する

[[生成AIで問いと検索語を作る]]（[[2026-09-30 Helsinki Information Seeking Guide]]）の自動化版に相当。人間が行う「結果を見て検索語を更新する」操作をagent内部に組み込む。

## 関連

- [[生成AIで問いと検索語を作る]]、[[検索語の展開]]、[[Deep Research agent]]
