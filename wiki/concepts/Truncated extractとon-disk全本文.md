---
tags: [content-extraction, agent]
---

# Truncated extractとon-disk全本文

長文pageをinline応答に入れる際に、head/tail windowで省略し完全本文をdiskに保存して参照可能にする設計。

- Hermesの`web_extract`は`web.extract_char_limit`（default 15 000、最大500 000）を超えるpageに対し、head+tail window（約75%/25%、markdown行境界で切る）+ `[TRUNCATED]`フッターを返す ([[2026-09-30 Hermes Web Search]])。
- 完全本文は`~/.hermes/cache/web/`に保存され、フッターはfile pathと`read_file`呼び出しを明記。2 MB以上は本文を2 MBにcap。
- `web.extract_timeout`（default 120秒）でwall-clock timeoutも制御。

類似・比較:

- [[2026-09-30 Exa Search API]]の`text.verbosity`/`maxCharacters`/`includeSections`はinline返却の段階で制御する設計。Hermesはinlineは短く保ち、diskで完全保存する分業
- [[ページ本文の段階取得]]は「取得段階」で切る、Hermesは「取得後保存」で切る

経路設計上の含意:

- agent context windowを守りつつ、後段で必要部分を`read_file`で取り出せる
- 大量pageを一度に探索する場合、inline応答が短く保たれるためLLMの認知負荷が下がる一方、disk cache管理が別途必要
- 重要なpageは後から`read_file`で中身を精読する[[引用追跡]]の前段にも使える
