---
tags: [multi-agent, agent-design]
---

# LeadResearcher / Subagent 役割分担（orchestrator-worker）

複雑な研究タスクを1つのlead agentが計画・統合し、複数のsubagentが並列で部分探索する設計パターン。

- Lead agent: query分析 → 戦略立案 → Memoryへplan保存 → subagent spawn → 結果synthesis → 必要なら追加subagentや戦略修正 ([[2026-09-30 Anthropic Multi-Agent Research System]])
- Subagent: 独自tool/prompt/exploration trajectoryで部分探索、interleaved thinkingでtool結果を評価しqueryを微調整、findingsをlead agentへ返す
- 適用条件: open-endedな研究タスク、breadth-first query、複数独立方向の並列化が必要な領域 ([[2026-09-30 Anthropic Multi-Agent Research System]])

効果（Anthropic内部評価）:

- Claude Opus 4 lead + Sonnet 4 subagents が single-agent Opus 4 を **90.2%** 上回る
- 3-5 subagent並列 + subagent内3+ tools並列 → **~90%時間削減**
- 一方でmulti-agentはchat比 **~15倍** tokenを消費

[[Deep Research agent]]を実装するときの選択肢:

- Gemini Deep Research Agent（[[2026-09-30 Gemini Deep Research Agent]]）: managed SDK/REST内でmulti-tool searchを内部実行
- OpenAI Deep Research API（[[2026-09-30 OpenAI Deep Research API]]）: Responses API + tools、内部のmulti-stepはmodel側に委ねる
- Anthropic Research: orchestrator-workerで明示的にsubagentをspawn
- xAI Grok Multi-agent（[[2026-09-30 xAI Grok Multi-Agent Research]]）: grok-4.20-multi-agentで4 or 16 agents

設計含意:

- subagent数がそのままcost・latencyに効く。task complexityに応じたscaling rulesが要る ([[2026-09-30 Anthropic Multi-Agent Research System]]のprompting原則3)
- subagentの独立context windowは[[マルチソースグラウンディング]]の並列性を支える
- lead agentが同期実行だとbottleneckになるためasync化は将来課題

## 関連

- [[マルチソースグラウンディング]]、[[Deep Research agent]]
