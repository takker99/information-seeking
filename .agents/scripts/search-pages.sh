#!/bin/bash

set -euo pipefail

usage() {
  cat <<'EOF'
search-pages.sh - ページタイトル・本文中の[[wikilink]]・index.mdの1行要約からページを検索する

Usage:
  bash .agents/scripts/search-pages.sh [options] <query...>

検索の仕組み:
  既定では以下の対象を検索し、マッチ語数・一致度・被リンク数の降順で出力する。
  1. 実在ページのタイトルと本文中の全[[wikilink]]（未作成のオープンリンクを含む）に対する編集距離付きの曖昧部分一致
     - 1〜2文字の語: 編集距離0（完全部分一致）
     - 3〜5文字の語: 編集距離1まで許容
     - 6文字以上の語: 編集距離2まで許容
  2. wiki/index.md の1行要約に対する部分一致
  既定検索で0件だった場合、または --fulltext 指定時は、wiki/ 配下の本文全文を検索してマッチ行を抜粋する。

Options:
  --fulltext           本文全文を対象に検索し、マッチした行を抜粋する
  --max-distance <N>   タイトル・[[wikilink]]曖昧検索の最大編集距離を固定値Nで上書きする
  --limit <N>          表示件数の上限（既定: 20）
  --wiki-dir <dir>     wikiディレクトリのパス（既定: リポジトリルートの wiki/）
  -h, --help           このヘルプを表示する

search-aliases.tsv:
  WIKI_DIR 直下に search-aliases.tsv（TSV: 1列目=alias、2列目=canonical語）を置くと、
  query内の語がalias列に大小文字無視で一致した場合に canonical語も検索語として追加する。
  追加された語の検索結果には ':alias' 表示が付く。query語数が10を超えた場合は追加を打ち切る。
  ファイルが無い場合は何も変わらない。例:
    ころがり    転がり
    ML          機械学習

Examples:
  bash .agents/scripts/search-pages.sh "動的マイクロバッチ"
  bash .agents/scripts/search-pages.sh "トポロジー認識" "勾配累積"
  bash .agents/scripts/search-pages.sh --fulltext "72%"
EOF
}

FULLTEXT=0
MAX_DIST_OVERRIDE=-1
LIMIT=20
WIKI_DIR="$(cd "$(dirname "$0")/../.." && pwd)/wiki"
QUERIES=()

while [ $# -gt 0 ]; do
  case "$1" in
    --fulltext)
      FULLTEXT=1
      shift
      ;;
    --max-distance)
      MAX_DIST_OVERRIDE="$2"
      shift 2
      ;;
    --limit)
      LIMIT="$2"
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
        QUERIES+=("$1")
        shift
      done
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      QUERIES+=("$1")
      shift
      ;;
  esac
done

if [ ${#QUERIES[@]} -eq 0 ]; then
  usage >&2
  exit 2
fi

if [ ! -d "$WIKI_DIR" ]; then
  echo "Error: wiki directory not found: $WIKI_DIR" >&2
  exit 1
fi

QUERY_JOINED="${QUERIES[*]}"

ALIAS_FILE=""
if [ -f "$WIKI_DIR/search-aliases.tsv" ]; then
  ALIAS_FILE="$WIKI_DIR/search-aliases.tsv"
fi

find "$WIKI_DIR" -name "*.md" -print0 | xargs -0 awk \
  -v wiki_dir="$WIKI_DIR" \
  -v query_str="$QUERY_JOINED" \
  -v fulltext_mode="$FULLTEXT" \
  -v max_dist_override="$MAX_DIST_OVERRIDE" \
  -v limit="$LIMIT" \
  -v alias_file="$ALIAS_FILE" '
function trim(s) {
  sub(/^[ \t\r\n]+/, "", s)
  sub(/[ \t\r\n]+$/, "", s)
  return s
}

function url_decode(s,    out, i, c, hex) {
  gsub(/%20/, " ", s)
  return s
}

function allowed_dist(qlen) {
  if (max_dist_override >= 0) return max_dist_override + 0
  if (qlen <= 2) return 0
  if (qlen <= 5) return 1
  return 2
}

# Sellersの動的計画法でpatとtxtの任意の部分文字列との最小編集距離を求める
function sub_edit_dist(pat, txt, max_d,    m, n, p, t, prev, curr, i, j, cost, d1, d2, d3, row_min, min_d) {
  pat = tolower(pat)
  txt = tolower(txt)
  if (index(txt, pat) > 0) return 0
  m = split(pat, p, "")
  if (m == 0) return 0
  if (max_d == 0) return m
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
  # aliases.tsv を読み込む（存在する場合のみ）
  if (alias_file != "") {
    while ((getline _aline < alias_file) > 0) {
      _n = split(_aline, _acols, "\t")
      if (_n >= 2) {
        _a = trim(_acols[1])
        _c = trim(_acols[2])
        if (_a != "" && _c != "") {
          alias_map[tolower(_a)] = _c
        }
      }
    }
    close(alias_file)
  }

  nq = split(query_str, raw_q, /[ \t]+/)
  qcount = 0
  for (i = 1; i <= nq; i++) {
    if (raw_q[i] != "") {
      qcount++
      qwords[qcount] = raw_q[i]
      qlens[qcount] = length(raw_q[i])
      q_is_alias[qcount] = 0
    }
  }

  # alias展開: query内の語がalias列に一致したら canonical語を追加（最大10語）
  _orig_count = qcount
  for (i = 1; i <= _orig_count; i++) {
    if (qcount >= 10) break
    _key = tolower(qwords[i])
    if (_key in alias_map) {
      _canon = alias_map[_key]
      _dup = 0
      for (j = 1; j <= qcount; j++) {
        if (tolower(qwords[j]) == tolower(_canon)) { _dup = 1; break }
      }
      if (!_dup) {
        qcount++
        qwords[qcount] = _canon
        qlens[qcount] = length(_canon)
        q_is_alias[qcount] = 1
      }
    }
  }
}

FNR == 1 {
  inblock = 0
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
        edge_key = base SUBSEP target
        if (!(edge_key in seen_edge) && base != target) {
          seen_edge[edge_key] = 1
          inbound_count[target]++
          if (inbound_sources[target] == "") {
            inbound_sources[target] = "[[" base "]]"
          } else if (inbound_count[target] <= 4) {
            inbound_sources[target] = inbound_sources[target] ", [[" base "]]"
          }
        }
      }
      work = substr(work, RSTART + RLENGTH)
    }
    body_line_count[base]++
    body_lines[base, body_line_count[base]] = FNR ": " line
  }
}

END {
  # 大文字小文字違いの未解決リンクを実在ページ名へ寄せる
  for (node in all_nodes) {
    if (!(node in existing_path)) {
      lc = tolower(node)
      if (lc in title_lc_to_canon) {
        canon = title_lc_to_canon[lc]
        inbound_count[canon] += inbound_count[node]
        delete all_nodes[node]
      }
    }
  }

  hit_count = 0
  if (!fulltext_mode) {
    for (node in all_nodes) {
      matched_q = 0
      best_tier = 99
      total_dist = 0
      match_labels = ""
      sum_txt = (node in index_summary) ? index_summary[node] : ""

      for (qi = 1; qi <= qcount; qi++) {
        qw = qwords[qi]
        max_d = allowed_dist(qlens[qi])
        d = sub_edit_dist(qw, node, max_d)
        if (q_is_alias[qi]) {
          _alias_suffix = ":alias"
        } else {
          _alias_suffix = ""
        }
        if (d <= max_d) {
          matched_q++
          tier = (d == 0) ? 1 : 2
          if (tier < best_tier) best_tier = tier
          total_dist += d
          if (_alias_suffix != "") {
            lbl = qw ":alias"
          } else {
            lbl = (d == 0) ? (qw ":exact") : (qw ":dist=" d)
          }
          match_labels = (match_labels == "") ? lbl : (match_labels ", " lbl)
        } else if (sum_txt != "" && index(tolower(sum_txt), tolower(qw)) > 0) {
          matched_q++
          if (3 < best_tier) best_tier = 3
          total_dist += max_d + 1
          if (_alias_suffix != "") {
            lbl = qw ":alias"
          } else {
            lbl = qw ":summary"
          }
          match_labels = (match_labels == "") ? lbl : (match_labels ", " lbl)
        }
      }

      if (matched_q > 0) {
        hit_count++
        hits[hit_count] = node
        hit_mq[node] = matched_q
        hit_tier[node] = best_tier
        hit_dist[node] = total_dist
        hit_label[node] = match_labels
      }
    }
  }

  if (!fulltext_mode && hit_count > 0) {
    # 並び順: マッチ語数降順 -> tier昇順 -> 編集距離昇順 -> 被リンク数降順 -> タイトル昇順
    for (i = 1; i <= hit_count; i++) {
      for (j = i + 1; j <= hit_count; j++) {
        a = hits[i]
        b = hits[j]
        swap = 0
        if (hit_mq[b] > hit_mq[a]) swap = 1
        else if (hit_mq[b] == hit_mq[a]) {
          if (hit_tier[b] < hit_tier[a]) swap = 1
          else if (hit_tier[b] == hit_tier[a]) {
            if (hit_dist[b] < hit_dist[a]) swap = 1
            else if (hit_dist[b] == hit_dist[a]) {
              in_a = inbound_count[a] + 0
              in_b = inbound_count[b] + 0
              if (in_b > in_a) swap = 1
              else if (in_b == in_a && b < a) swap = 1
            }
          }
        }
        if (swap) {
          hits[i] = b
          hits[j] = a
        }
      }
    }

    print "# Search Results (title / wikilink fuzzy + index summary)"
    print "Query: " query_str
    print ""
    out_n = (hit_count < limit) ? hit_count : limit
    for (i = 1; i <= out_n; i++) {
      node = hits[i]
      in_c = inbound_count[node] + 0
      if (node in existing_path) {
        sum_part = (node in index_summary && index_summary[node] != "") ? (" — " index_summary[node]) : ""
        printf "- [existing] [[%s]] (path: %s, linked: %d, match: %s)%s\n", node, existing_path[node], in_c, hit_label[node], sum_part
      } else {
        refs = (node in inbound_sources) ? (" — 参照元: " inbound_sources[node]) : ""
        printf "- [unresolved] [[%s]] (linked: %d, match: %s)%s\n", node, in_c, hit_label[node], refs
      }
    }
    if (hit_count > limit) {
      printf "\n(他 %d 件を省略。--limit で件数を変更できます)\n", hit_count - limit
    }

    # fulltext 共走: タイトル検索で件数>0 でも全文検索を走らせて reference として追加
    _ft_count = 0
    delete _ft_hits
    delete _ft_mq
    delete _ft_lhits
    delete _ft_snippet_count
    for (page in existing_path) {
      _matched_q = 0
      _total_line_hits = 0
      _sc = 0
      for (qi = 1; qi <= qcount; qi++) {
        qw_lc = tolower(qwords[qi])
        _q_hit = 0
        if (index(tolower(page), qw_lc) > 0) {
          _q_hit = 1
        }
        nl = body_line_count[page] + 0
        for (li = 1; li <= nl; li++) {
          bline = body_lines[page, li]
          if (index(tolower(bline), qw_lc) > 0) {
            _q_hit = 1
            _total_line_hits++
            if (_sc < 1 && !( (page SUBSEP li) in seen_snippet )) {
              seen_snippet[page SUBSEP li] = 1
              _sc++
              _ft_snippets[page] = bline
            }
          }
        }
        if (_q_hit) _matched_q++
      }
      if (_matched_q > 0) {
        _ft_count++
        _ft_hits[_ft_count] = page
        _ft_mq[page] = _matched_q
        _ft_lhits[page] = _total_line_hits
        _ft_snippet_count[page] = _sc
      }
    }

    # sort
    for (i = 1; i <= _ft_count; i++) {
      for (j = i + 1; j <= _ft_count; j++) {
        a = _ft_hits[i]
        b = _ft_hits[j]
        swap = 0
        if (_ft_mq[b] > _ft_mq[a]) swap = 1
        else if (_ft_mq[b] == _ft_mq[a]) {
          in_a = inbound_count[a] + 0
          in_b = inbound_count[b] + 0
          if (in_b > in_a) swap = 1
          else if (in_b == in_a && _ft_lhits[b] > _ft_lhits[a]) swap = 1
        }
        if (swap) {
          _ft_hits[i] = b
          _ft_hits[j] = a
        }
      }
    }

    print ""
    print "## Full-Text Search Results (reference)"
    print "Query: " query_str
    print ""
    if (_ft_count == 0) {
      print "(該当するページはありません)"
    } else {
      _ref_limit = (_ft_count < 10) ? _ft_count : 10
      for (i = 1; i <= _ref_limit; i++) {
        page = _ft_hits[i]
        in_c = inbound_count[page] + 0
        sum_part = (page in index_summary && index_summary[page] != "") ? (" — " index_summary[page]) : ""
        printf "- [[%s]] (path: %s, linked: %d, matched_words: %d/%d)%s\n", page, existing_path[page], in_c, _ft_mq[page], qcount, sum_part
        if (_ft_snippet_count[page] > 0) {
          printf "    L%s\n", _ft_snippets[page]
        }
      }
      if (_ft_count > 10) {
        printf "\n(他 %d 件を省略)\n", _ft_count - 10
      }
    }
    exit 0
  }

  # 全文検索モード（または既定検索0件からの自動フォールバック）
  ft_count = 0
  for (page in existing_path) {
    matched_q = 0
    total_line_hits = 0
    snippet_count[page] = 0
    for (qi = 1; qi <= qcount; qi++) {
      qw_lc = tolower(qwords[qi])
      q_hit = 0
      if (index(tolower(page), qw_lc) > 0) {
        q_hit = 1
      }
      nl = body_line_count[page] + 0
      for (li = 1; li <= nl; li++) {
        bline = body_lines[page, li]
        if (index(tolower(bline), qw_lc) > 0) {
          q_hit = 1
          total_line_hits++
          if (snippet_count[page] < 3 && !( (page SUBSEP li) in seen_snippet )) {
            seen_snippet[page SUBSEP li] = 1
            snippet_count[page]++
            snippets[page, snippet_count[page]] = bline
          }
        }
      }
      if (q_hit) matched_q++
    }
    if (matched_q > 0) {
      ft_count++
      ft_hits[ft_count] = page
      ft_mq[page] = matched_q
      ft_lhits[page] = total_line_hits
    }
  }

  for (i = 1; i <= ft_count; i++) {
    for (j = i + 1; j <= ft_count; j++) {
      a = ft_hits[i]
      b = ft_hits[j]
      swap = 0
      if (ft_mq[b] > ft_mq[a]) swap = 1
      else if (ft_mq[b] == ft_mq[a]) {
        in_a = inbound_count[a] + 0
        in_b = inbound_count[b] + 0
        if (in_b > in_a) swap = 1
        else if (in_b == in_a && ft_lhits[b] > ft_lhits[a]) swap = 1
      }
      if (swap) {
        ft_hits[i] = b
        ft_hits[j] = a
      }
    }
  }

  if (!fulltext_mode) {
    print "# Full-Text Search Results (fallback: title / wikilink / summary match was 0)"
  } else {
    print "# Full-Text Search Results"
  }
  print "Query: " query_str
  print ""
  if (ft_count == 0) {
    print "(該当するページはありません)"
    exit 0
  }
  out_n = (ft_count < limit) ? ft_count : limit
  for (i = 1; i <= out_n; i++) {
    page = ft_hits[i]
    in_c = inbound_count[page] + 0
    sum_part = (page in index_summary && index_summary[page] != "") ? (" — " index_summary[page]) : ""
    printf "- [[%s]] (path: %s, linked: %d, matched_words: %d/%d)%s\n", page, existing_path[page], in_c, ft_mq[page], qcount, sum_part
    sc = snippet_count[page] + 0
    for (si = 1; si <= sc; si++) {
      printf "    L%s\n", snippets[page, si]
    }
  }
  if (ft_count > limit) {
    printf "\n(他 %d 件を省略。--limit で件数を変更できます)\n", ft_count - limit
  }
}
'

echo ""
echo "→ 候補ページの本文は bash .agents/scripts/read-page.sh \"<タイトル>\" で読むこと（末尾に1 hop・2 hopの関連ページが付く。パスを直接 read するとhop情報が得られない）"
