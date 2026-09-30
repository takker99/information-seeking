---
tags: [search-api, reproducibility]
---

# 履歴snapshot取得

Web pageの特定時点の内容を、stored versionから取得する仕組み。live取得を伴わず、再現性のある固定内容を得る。

- Exa `snapshotAsOf`: ISO 8601 date-timeまたはdate-only（midnight UTC解釈）。指定時刻のstored versionを返し、live取得はしない ([[2026-09-30 Exa Search API]])。
- 関連: `maxAgeHours`（cache年齢閾値、`-1`で常にcache）、`subpages`で結果page内のsubpageも辿れる。

用途:

- 研究reproducibility: ある論文・ページが解析時にどう書かれていたかを後追いで再現する
- 引用追跡: [[2026-09-30 Illinois Citation Chasing]]の前方追跡で取得できなかった時代の資料を、archive時点で救う
- 監査: 主張の根拠URLが改変された場合の差分確認

[[引用追跡]]と組み合わせると「ある論文を引用した研究の履歴版を辿る」ようなarchive-thread探索になる。

## 関連

- [[ページ本文の段階取得]]、[[引用追跡]]
