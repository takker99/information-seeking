---
tags: [api, design]
---

# Dehydrated nested entity

API responseでnestedな関連entityを「ID + display name」だけのstubに置き換える設計。response sizeとpagingの一貫性を保つ。

- OpenAlexのnested entity（works内のauthors、sources等）はdehydratedで返る。詳細が必要なら別途取得 ([[2026-09-30 OpenAlex API]])。
- 効果: list endpointのresponseが常に同サイズ帯で揃い、bulk fetchが速い。nested chainを遡る時は明示的に追加requestが必要。
- 設計の選択: nested entityを全部埋めると便利だがresponse sizeが爆発する。dehydratedはAPI利用者にfetch戦略を委ねる形。

[[検索過程の記録]]（[[2026-09-30 Illinois Library Search Strategies]]）との接続:

- search journalに書く単位は「API call」と「結果」。dehydrated stubを**dryなlink**として記録し、必要なら追加callを明記する
- [[引用追跡]]の前段として、works一覧→authors/sourcesを別callで辿る手順の雛形になる

[[構造化出力schema]]（[[2026-09-30 Exa Search API]]）との対比:

- Exa `outputSchema`はfield groundingでoutput fieldにcitation+confidenceを返す。OpenAlexのdehydratedはcitationというよりreference pointerの単位
- どちらも「response内で全部埋めない」設計だが、用途と評価軸が違う
