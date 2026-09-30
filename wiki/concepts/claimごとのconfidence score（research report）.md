---
tags: [research-output, transparency]
---

# claimごとのconfidence score（research report）

Deep Research agentの出力で、各claimに対しreferenceと一緒にconfidence score（low / medium / high等）を付ける設計。end-userがどの主張を信頼するか判断する材料を提供する。

- [[2026-09-30 Scopus AI Deep Research]]: "every report includes references and confidence scores for full transparency"
- 類似: [[2026-09-30 Exa Search API]]の`outputSchema`+`grounding` chunkでfieldごとに`confidence`を返す
- [[2026-09-30 Anthropic Multi-Agent Research System]]の[[LLM-as-judge評価rubric]]でcitation accuracyを評価軸にするのは**開発時**の品質管理。confidence scoreは**end-user向け**の透明性軸

[[Deep Research agent]]の経路設計上の位置:

- [[情報源の評価]]を回答側で機械的に提示する手段。readerは「low confidence = 別途検証必要」と即座に判断できる
- [[マルチソースグラウンディング]]の[[構造化出力schema]]と組み合わせると、field grounding + confidence scoreで「source-aware research output」が作れる
- 個人レベルでは [[2026-09-30 Helsinki Information Seeking Guide]] の "Key Findings" 表示 ([[2026-09-30 Perplexity Advanced Deep Research Help]]) と並ぶ「途中でfindingsを可視化する」手法

制約:

- confidence scoreはmodel自身が出す自己評価。[[2026-09-30 OpenAI ChatGPT Deep Research Help]]の "AI responses may include mistakes" 注意書きと並ぶ**読者の検証義務**は残る
- 透明性を上げても、source collection自体に偏りがあると低confidence claimでも多数出る（[[情報源の評価]]の[[LLM-as-judge評価rubric]]と併用が必要）
