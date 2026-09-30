---
source_url: "https://www.anthropic.com/engineering/multi-agent-research-system"
accessed: 2026-09-30
tags: [deep-research, multi-agent, engineering]
---

# Anthropic Multi-Agent Research System（Engineering blog）

AnthropicがClaude Research機能を構築した経緯と、orchestrator-worker型multi-agent architectureの設計・運用知見を共有した公式engineering blog（2025-06-13）。consumer向けResearch機能だけでなく、研究系agent system構築の参考実装としても有用。

## 要点

### Multi-agent system の利点

- 探索タスクは本質的にpath-dependentで、固定経路をhardcodeできない
- 各subagentが独立したcontext windowで並列探索 → lead agentへ圧縮して渡す
- 「search is compression」という見方: subagentはcontext内のtokenを最も重要なものに圧縮する役割
- internal eval: Claude Opus 4 lead + Sonnet 4 subagents が single-agent Opus 4 を**90.2%上回り**
- BrowseComp（hard-to-find情報のbrowse能力評価）でtoken使用量が性能分散の**80%**を説明

### Architecture overview

```
User query
  ↓
LeadResearcher agent（plan → memory保存）
  ↓ spawn parallel
Subagent × N（それぞれ独自tool/prompt/exploration trajectory）
  ↓ findings
LeadResearcher（synthesis、必要なら追加subagent生成）
  ↓
CitationAgent（出典・引用位置特定）
  ↓
User（citations付き回答）
```

- context windowが200K tokens超でtruncateされるため、**planをMemoryに永続化**
- LeadResearcherはsubagentをspawnする前にextended thinkingでtool選択・query複雑さ・subagent数・各役割を計画
- Subagentはinterleaved thinkingでtool結果を評価しqueryを調整

### Prompting原則（8項目）

1. **Think like your agents** — Console simulationでstep-by-step観察、mental model精度を上げる
2. **Teach the orchestrator how to delegate** — subagentに objective / output format / tools / task境界を明示。曖昧な指示（「半導体を調査して」）では重複作業が起きる
3. **Scale effort to query complexity** — simple fact-finding=1 agent×3-10 tool calls、comparison=2-4 subagents×10-15 calls、complex=10+ subagents
4. **Tool design and selection are critical** — agent-tool interfaceはHCIと同等。tool descriptionの品質で成否が決まる
5. **Let agents improve themselves** — Claude 4にpromptと失敗modeを渡すと自己改善。tool description書き直しで**40%**のtask completion time削減
6. **Start wide, then narrow down** — broad queryから評価、徐々に絞る
7. **Guide the thinking process** — extended thinkingを controllable scratchpadとして使う
8. **Parallel tool calling transforms speed** — lead agent 3-5 subagents並列、subagent内 3+ tools並列 → **~90%**時間削減

### Evaluation

- **Small samples first**: ~20 queriesで十分な変化検出
- **LLM-as-judge rubric**: factual accuracy / citation accuracy / completeness / source quality / tool efficiency を 0.0-1.0 + pass-fail
- **Human eval**: SEO-optimized content farmをacademic PDF等より優先するsource biasを発見・修正

### Production reliability

- Agentsはstateful、errorは複合する。restart不可、resume機構を実装
- **Rainbow deployments**でrolling update中の既存agent disruption回避
- **Synchronous execution**はbottleneck（leadが各subagent完了待ち）。async化はco・state・error propagationの課題あり
- Production tracingで「なぜagentが情報を見つけられなかったか」を診断。**privacyのためindividual conversation contentは監視せず**decision pattern・interaction構造を観測

### Long-horizon conversation管理

- 数百turnの会話: context compression、external memory、subagent fresh-spawn
- Subagentは**filesystemへ直接output**してgame of telephone回避。Lead agentはlightweight referenceを受け取るだけ

### 利用傾向（内部Clio embedding plot）

上位use case: specialized software systems (10%)、professional/technical content (8%)、business strategy (8%)、academic research (7%)、info verification (5%)。

## 設計含意

- Orchestrator-worker型multi-agentは[[Deep Research agent]]の「先行実装」的代表。[[2026-09-30 Gemini Deep Research Agent]]の`Plan→Multi-source search→Iterate→Output`は同型の骨格。[[2026-09-30 OpenAI Deep Research API]]の3-step（clarification / prompt rewriting / research）も、LLM chain によるオーケストレーション
- Subagentへの**filesystem直接output**は[[MCPサーバー経由のsource拡張]]の代替経路。[[マルチソースグラウンディング]]のartifact永続化と接続
- **Token使用量 = 性能の80%** という発見は、deep research agentのcost最適化が「token budget管理」に帰着することを示す
- **CitationAgent** による引用位置特定は、agent経路に固有の[[構造化出力schema]]（[[2026-09-30 Exa Search API]]のfield grounding）に相当
- **8 prompting原則**はconsumer/agent両方のprompt設計に再利用可能。[[生成AIで問いと検索語を作る]]（[[2026-09-30 Helsinki Information Seeking Guide]]）と接続

## 関連

- [[Deep Research agent]]、[[マルチソースグラウンディング]]、[[MCPサーバー経由のsource拡張]]、[[構造化出力schema]]
- [[LeadResearcher_Subagent 役割分担（orchestrator-worker）]]、[[引用位置特定のCitationAgent]]、[[LLM-as-judge評価rubric]]、[[Interleaved thinking]]、[[subagentからfilesystemへ直接output]]
- [[2026-09-30 Gemini Deep Research Agent]]、[[2026-09-30 OpenAI Deep Research API]]
- [[問いに応じた情報探索経路の設計]]
