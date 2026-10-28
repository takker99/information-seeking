#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
read-page.sh - ページのメタデータ・本文・1 hopおよび2 hopの関連ページ一覧を出力する

Usage:
  bash .agents/scripts/read-page.sh [options] <title-or-path...>

出力の構成:
  1. メタデータ: タイトル、ファイルパス（未作成なら unresolved）、被リンク数、出リンク数
  2. 本文または逆リンク行抜粋:
     - 実在ページの場合: ページの全文
     - 未作成のオープンリンクの場合: 未作成である旨と、他ページで [[タイトル]] に言及している行の抜粋
  3. -------------------- Related Pages --------------------
     - ## 1 hop link: 正リンク・逆リンク・双方向・未作成オープンリンクの一覧（被リンク数降順、index.mdの1行要約付き）
     - ## 2 hop link: 本文中のリンクを媒介にした2 hop先ページの一覧（被リンク数が閾値以上の巨大ハブは展開を省略）

Options:
  --hub-threshold <N>  2 hop展開から除外するハブの被リンク数閾値（既定: 10）
  --no-2hop            2 hopセクション（## 2 hop link 以降）の出力を丸ごとskipする
  --2hop-limit <N>     2 hop展開するpivotを被リンク数降順の先頭N個に制限する（残りは1行で要約）
  --wiki-dir <dir>     wikiディレクトリのパス（既定: リポジトリルートの wiki/）
  -h, --help           このヘルプを表示する

Examples:
  bash .agents/scripts/read-page.sh "Cosenseのリンク概念"
  bash .agents/scripts/read-page.sh "動的マイクロバッチ制御" "勾配累積"
EOF
}

HUB_THRESHOLD=10
NO_2HOP=0
TWOHOP_LIMIT=""
WIKI_DIR="$(cd "$(dirname "$0")/../.." && pwd)/wiki"
TARGETS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --hub-threshold)
      HUB_THRESHOLD="$2"
      shift 2
      ;;
    --no-2hop)
      NO_2HOP=1
      shift
      ;;
    --2hop-limit)
      TWOHOP_LIMIT="$2"
      shift 2
      ;;
    --wiki-dir)
      WIKI_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        TARGETS+=("$1")
        shift
      done
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      TARGETS+=("$1")
      shift
      ;;
  esac
done

if [ ${#TARGETS[@]} -eq 0 ]; then
  usage >&2
  exit 2
fi

if [ ! -d "$WIKI_DIR" ]; then
  echo "Error: wiki directory not found: $WIKI_DIR" >&2
  exit 1
fi

TARGETS_JOINED=""
for t in "${TARGETS[@]}"; do
  if [ -z "$TARGETS_JOINED" ]; then
    TARGETS_JOINED="$t"
  else
    TARGETS_JOINED="${TARGETS_JOINED}"$'\t'"$t"
  fi
done

find "$WIKI_DIR" -name "*.md" -print0 | xargs -0 awk \
  -v wiki_dir="$WIKI_DIR" \
  -v targets_str="$TARGETS_JOINED" \
  -v hub_threshold="$HUB_THRESHOLD" \
  -v no_2hop="$NO_2HOP" \
  -v twohop_limit="$TWOHOP_LIMIT" '
function trim(s) {
  sub(/^[ \t\r\n]+/, "", s)
  sub(/[ \t\r\n]+$/, "", s)
  return s
}

function normalize_arg(s) {
  s = trim(s)
  gsub(/^\[\[|\]\]$/, "", s)
  sub(/^.*\//, "", s)
  sub(/\.md$/, "", s)
  return s
}

# ページが存在せず逆リンクも0件の時に近いタイトル候補を出すためSellersの編集距離を計算する
function sub_edit_dist(pat, txt, max_d,    m, n, p, t, prev, curr, i, j, cost, d1, d2, d3, row_min, min_d) {
  pat = tolower(pat)
  txt = tolower(txt)
  if (index(txt, pat) > 0) return 0
  m = split(pat, p, "")
  if (m == 0) return 0
  n = split(txt, t, "")
  if (n == 0) return m
  for (j = 0; j <= n; j++) prev[j] = 0
  for (i = 1; i <= m; i++) {
    curr[0] = i
    row_min = i
    for (j = 1; j <= n; j++) {
      cost = (p[i] == t[j]) ? 0 : 1
      d1 = prev[j] + 1
      d2 = curr[j - 1] + 1
      d3 = prev[j - 1] + cost
      curr[j] = d1
      if (d2 < curr[j]) curr[j] = d2
      if (d3 < curr[j]) curr[j] = d3
      if (curr[j] < row_min) row_min = curr[j]
    }
    if (row_min > max_d) return max_d + 1
    for (j = 0; j <= n; j++) prev[j] = curr[j]
  }
  min_d = m
  for (j = 0; j <= n; j++) {
    if (prev[j] < min_d) min_d = prev[j]
  }
  return min_d
}

BEGIN {
  nt = split(targets_str, raw_t, "\t")
  tcount = 0
  for (i = 1; i <= nt; i++) {
    norm = normalize_arg(raw_t[i])
    if (norm != "") {
      tcount++
      req_targets[tcount] = norm
    }
  }
}

FNR == 1 {
  inblock = 0
  infm = 0
  relpath = FILENAME
  if (index(relpath, wiki_dir "/") == 1) {
    relpath = substr(relpath, length(wiki_dir) + 2)
  }
  base = relpath
  sub(/^.*\//, "", base)
  sub(/\.md$/, "", base)
  is_meta_file = (relpath == "index.md" || relpath == "log.md" || relpath == "overview.md")
  if (!is_meta_file) {
    existing_path[base] = relpath
    title_lc_to_canon[tolower(base)] = base
    all_nodes[base] = 1
  }
}

relpath == "index.md" {
  line = $0
  sub(/\r$/, "", line)
  if (index(line, "- [") == 1) {
    pos = index(line, "](")
    if (pos > 3) {
      rest = substr(line, pos + 2)
      endpos = index(rest, ".md)")
      if (endpos > 0) {
        entry_title = substr(line, 4, pos - 4)
        entry_base = substr(rest, 1, endpos - 1)
        gsub(/%20/, " ", entry_base)
        sub(/^.*\//, "", entry_base)
        summary = substr(rest, endpos + 4)
        sub(/^[ \t]*([—–-][ \t]*)?/, "", summary)
        index_summary[entry_title] = summary
        index_summary[entry_base] = summary
      }
    }
  }
  next
}

is_meta_file {
  next
}

{
  line = $0
  sub(/\r$/, "", line)
  page_line_count[base]++
  page_lines[base, page_line_count[base]] = line

  if (FNR == 1 && line == "---") {
    infm = 1
    next
  }
  if (infm && line == "---") {
    infm = 0
    next
  }

  if (line ~ /^```/) {
    inblock = !inblock
    next
  }

  if (!inblock) {
    clean = line
    gsub(/`[^`]*`/, "", clean)
    work = clean
    while (match(work, /\[\[[^]]+\]\]/)) {
      raw_link = substr(work, RSTART + 2, RLENGTH - 4)
      split(raw_link, parts, "|")
      target = trim(parts[1])
      if (target != "" && target !~ /^http/) {
        all_nodes[target] = 1
        raw_edges_all[base SUBSEP target] = 1
        if (!infm) {
          raw_edges_body[base SUBSEP target] = 1
        }
        mkey = target SUBSEP base SUBSEP FNR
        if (!(mkey in seen_mention)) {
          seen_mention[mkey] = 1
          mention_count[target]++
          mentions[target, mention_count[target]] = relpath ":L" FNR ": " line
        }
      }
      work = substr(work, RSTART + RLENGTH)
    }
  }
}

END {
  # リンク先タイトルの大文字小文字ゆれを実在ページ名に正規化する
  for (node in all_nodes) {
    lc = tolower(node)
    if (lc in title_lc_to_canon) {
      canon_map[node] = title_lc_to_canon[lc]
    } else {
      canon_map[node] = node
      if (!(lc in title_lc_to_canon)) {
        title_lc_to_canon[lc] = node
      }
    }
  }

  for (ek in raw_edges_all) {
    split(ek, ep, SUBSEP)
    u = canon_map[ep[1]]
    v = canon_map[ep[2]]
    canon_nodes[u] = 1
    canon_nodes[v] = 1
    if (u != v && !((u SUBSEP v) in edges_all)) {
      edges_all[u SUBSEP v] = 1
      out_deg_all[u]++
      out_adj_all[u, out_deg_all[u]] = v
      in_deg_all[v]++
      in_adj_all[v, in_deg_all[v]] = u
    }
  }

  for (ek in raw_edges_body) {
    split(ek, ep, SUBSEP)
    u = canon_map[ep[1]]
    v = canon_map[ep[2]]
    if (u != v && !((u SUBSEP v) in edges_body)) {
      edges_body[u SUBSEP v] = 1
      out_deg_body[u]++
      out_adj_body[u, out_deg_body[u]] = v
      in_deg_body[v]++
      in_adj_body[v, in_deg_body[v]] = u
    }
  }

  for (node in existing_path) {
    canon_nodes[node] = 1
  }

  for (ti = 1; ti <= tcount; ti++) {
    if (ti > 1) {
      print ""
      print "======================================================================"
      print ""
    }
    req = req_targets[ti]
    req_lc = tolower(req)
    T = (req_lc in title_lc_to_canon) ? title_lc_to_canon[req_lc] : req
    is_exist = (T in existing_path)
    in_c = in_deg_all[T] + 0
    in_body_c = in_deg_body[T] + 0
    out_c = out_deg_all[T] + 0

    print "# " T
    print ""
    print "## メタデータ"
    if (is_exist) {
      printf "- status: existing\n"
      printf "- path: %s\n", existing_path[T]
    } else {
      printf "- status: unresolved\n"
    }
    printf "- linked: %d pages (body: %d) / outbound: %d links\n", in_c, in_body_c, out_c
    print ""

    if (!is_exist && in_c == 0) {
      print "(このページはまだ作成されておらず、他ページからの [[wikilink]] 言及もありません)"
      # 編集距離2以内の候補を提示する
      cand_n = 0
      for (cn in canon_nodes) {
        d = sub_edit_dist(req, cn, 2)
        if (d <= 2) {
          cand_n++
          cands[cand_n] = cn
          cand_d[cn] = d
        }
      }
      if (cand_n > 0) {
        print ""
        print "## 近いタイトル・リンク候補"
        for (i = 1; i <= cand_n; i++) {
          for (j = i + 1; j <= cand_n; j++) {
            ca = cands[i]; cb = cands[j]
            if (cand_d[cb] < cand_d[ca] || (cand_d[cb] == cand_d[ca] && (in_deg_all[cb] + 0) > (in_deg_all[ca] + 0))) {
              cands[i] = cb; cands[j] = ca
            }
          }
        }
        max_c = (cand_n < 10) ? cand_n : 10
        for (i = 1; i <= max_c; i++) {
          cn = cands[i]
          st = (cn in existing_path) ? "existing" : "unresolved"
          printf "- [%s] [[%s]] (linked: %d, dist=%d)\n", st, cn, in_deg_all[cn] + 0, cand_d[cn]
        }
      }
      continue
    }

    if (is_exist) {
      print "## 本文"
      print ""
      nl = page_line_count[T] + 0
      for (li = 1; li <= nl; li++) {
        print page_lines[T, li]
      }
    } else {
      print "(このページはまだ作成されていません)"
      print ""
      print "## 言及している箇所（逆リンク抜粋）"
      print ""
      # 大文字小文字ゆれも含めてmentionを集める
      for (orig_node in all_nodes) {
        if (canon_map[orig_node] == T) {
          mc = mention_count[orig_node] + 0
          for (mi = 1; mi <= mc; mi++) {
            printf "- %s\n", mentions[orig_node, mi]
          }
        }
      }
    }

    # 1-hop近傍を集計する（frontmatter + 本文の全リンク対象）
    delete hop1_rel
    delete hop1_list
    h1_count = 0

    for (i = 1; i <= out_c; i++) {
      nb = out_adj_all[T, i]
      if (!(nb in hop1_rel)) {
        h1_count++
        hop1_list[h1_count] = nb
        if ((nb SUBSEP T) in edges_all) {
          hop1_rel[nb] = "bidirectional"
        } else if (nb in existing_path) {
          hop1_rel[nb] = "outgoing"
        } else {
          hop1_rel[nb] = "unresolved"
        }
      }
    }

    for (i = 1; i <= in_c; i++) {
      nb = in_adj_all[T, i]
      if (!(nb in hop1_rel)) {
        h1_count++
        hop1_list[h1_count] = nb
        hop1_rel[nb] = "incoming"
      }
    }

    if (h1_count == 0) {
      continue
    }

    # 1-hopを被リンク数降順・タイトル昇順でソートする
    for (i = 1; i <= h1_count; i++) {
      for (j = i + 1; j <= h1_count; j++) {
        a = hop1_list[i]
        b = hop1_list[j]
        in_a = in_deg_all[a] + 0
        in_b = in_deg_all[b] + 0
        if (in_b > in_a || (in_b == in_a && b < a)) {
          hop1_list[i] = b
          hop1_list[j] = a
        }
      }
    }

    print ""
    print "-------------------- Related Pages --------------------"
    print "（深掘りするページの本文も bash .agents/scripts/read-page.sh \"<タイトル>\" で読む。パスを直接 read するとhop情報が得られない）"
    print "## 1 hop link"
    print ""
    for (i = 1; i <= h1_count; i++) {
      nb = hop1_list[i]
      rel = hop1_rel[nb]
      nb_in = in_deg_all[nb] + 0
      sum_part = (nb in index_summary && index_summary[nb] != "") ? (" — " index_summary[nb]) : ""
      printf "- [%s] [[%s]] (linked: %d)%s\n", rel, nb, nb_in, sum_part
    }

    if (no_2hop == 1) {
      continue
    }

    # 2-hop近傍を集計する（本文中のリンクのみを媒介にし、被リンク数 >= hub_threshold のハブを除外する）
    delete body_hop1_seen
    delete body_hop1_list
    bh1_count = 0

    ob_c = out_deg_body[T] + 0
    for (i = 1; i <= ob_c; i++) {
      nb = out_adj_body[T, i]
      if (!(nb in body_hop1_seen)) {
        body_hop1_seen[nb] = 1
        bh1_count++
        body_hop1_list[bh1_count] = nb
      }
    }
    ib_c = in_deg_body[T] + 0
    for (i = 1; i <= ib_c; i++) {
      nb = in_adj_body[T, i]
      if (!(nb in body_hop1_seen)) {
        body_hop1_seen[nb] = 1
        bh1_count++
        body_hop1_list[bh1_count] = nb
      }
    }

    for (i = 1; i <= bh1_count; i++) {
      for (j = i + 1; j <= bh1_count; j++) {
        a = body_hop1_list[i]
        b = body_hop1_list[j]
        in_a = in_deg_all[a] + 0
        in_b = in_deg_all[b] + 0
        if (in_b > in_a || (in_b == in_a && b < a)) {
          body_hop1_list[i] = b
          body_hop1_list[j] = a
        }
      }
    }

    if (twohop_limit == "") {
      _2hl = 999999
    } else {
      _2hl = twohop_limit + 0
      if (_2hl < 0) _2hl = 0
    }
    print ""
    print "## 2 hop link"
    print ""
    printed_2hop_any = 0
    expanded_2hop = 0
    omitted_pivots = ""
    for (i = 1; i <= bh1_count; i++) {
      pivot = body_hop1_list[i]
      piv_in = in_deg_all[pivot] + 0
      if (piv_in >= hub_threshold) {
        printf "- (hub [[%s]] (linked: %d) は被リンク数が閾値 %d 以上のため2 hop展開を省略)\n", pivot, piv_in, hub_threshold
        printed_2hop_any = 1
        continue
      }
      if (expanded_2hop >= _2hl) {
        if (omitted_pivots == "") {
          omitted_pivots = "[[" pivot "]] (linked: " piv_in ")"
        } else {
          omitted_pivots = omitted_pivots ", [[" pivot "]] (linked: " piv_in ")"
        }
        continue
      }

      expanded_2hop++
      delete p_sec_seen
      delete p_sec_list
      p2_count = 0

      p_ob = out_deg_body[pivot] + 0
      for (k = 1; k <= p_ob; k++) {
        q = out_adj_body[pivot, k]
        if (q != T && !(q in hop1_rel) && !(q in p_sec_seen)) {
          if ((q in existing_path) || (in_deg_all[q] + 0) >= 2) {
            p_sec_seen[q] = 1
            p2_count++
            p_sec_list[p2_count] = q
          }
        }
      }

      p_ib = in_deg_body[pivot] + 0
      for (k = 1; k <= p_ib; k++) {
        q = in_adj_body[pivot, k]
        if (q != T && !(q in hop1_rel) && !(q in p_sec_seen)) {
          if ((q in existing_path) || (in_deg_all[q] + 0) >= 2) {
            p_sec_seen[q] = 1
            p2_count++
            p_sec_list[p2_count] = q
          }
        }
      }

      if (p2_count > 0) {
        for (a_idx = 1; a_idx <= p2_count; a_idx++) {
          for (b_idx = a_idx + 1; b_idx <= p2_count; b_idx++) {
            qa = p_sec_list[a_idx]
            qb = p_sec_list[b_idx]
            ina = in_deg_all[qa] + 0
            inb = in_deg_all[qb] + 0
            if (inb > ina || (inb == ina && qb < qa)) {
              p_sec_list[a_idx] = qb
              p_sec_list[b_idx] = qa
            }
          }
        }
        printf "### via [[%s]] (linked: %d)\n", pivot, piv_in
        for (k = 1; k <= p2_count; k++) {
          q = p_sec_list[k]
          q_in = in_deg_all[q] + 0
          if (q in existing_path) {
            sum_part = (q in index_summary && index_summary[q] != "") ? (" — " index_summary[q]) : ""
            printf "- [[%s]] (linked: %d)%s\n", q, q_in, sum_part
          } else {
            printf "- [unresolved] [[%s]] (linked: %d)\n", q, q_in
          }
        }
        printed_2hop_any = 1
      }
    }
    if (omitted_pivots != "") {
      printf "- (2hop-limit: 以下の pivot の展開を省略: %s)\n", omitted_pivots
      printed_2hop_any = 1
    }
    if (!printed_2hop_any) {
      print "(該当する2 hop linkはありません)"
    }
  }
}
'
