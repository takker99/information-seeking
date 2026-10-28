#!/bin/bash
# number-dup-check.sh - 本文中の数値トークンのページ横断重複を情報提供する（lintではない）
# 書き込みは一切しない。EXIT 0。
set -uo pipefail

usage() {
  cat <<'EOF'
number-dup-check.sh - 本文中の数値トークンが複数ページに登場するものを報告する（情報提供ツール）

Usage:
  bash .agents/scripts/number-dup-check.sh [options] <wiki-repo-root>

Options:
  --wiki-dir <dir>   wikiディレクトリのパスを直接指定する（既定: <repo>/wiki）
  -h, --help         このヘルプを表示する

Examples:
  bash .agents/scripts/number-dup-check.sh /home/takker/git/txa-xray-ct-wiki
  bash .agents/scripts/number-dup-check.sh --wiki-dir /home/takker/git/txa-xray-ct-wiki/wiki
EOF
}

REPO=""
WIKI_DIR_OVERRIDE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --wiki-dir)
      WIKI_DIR_OVERRIDE="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        [ -z "$REPO" ] && REPO="$1"
        shift
      done
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      [ -z "$REPO" ] && REPO="$1"
      shift
      ;;
  esac
done

if [ -n "$WIKI_DIR_OVERRIDE" ]; then
  WIKI="$WIKI_DIR_OVERRIDE"
else
  if [ -z "$REPO" ]; then
    echo "Error: wiki repo root is required" >&2
    usage >&2
    exit 2
  fi
  REPO="$(cd "$REPO" && pwd)"
  WIKI="$REPO/wiki"
fi

if [ ! -d "$WIKI" ]; then
  echo "Error: wiki directory not found: $WIKI" >&2
  exit 1
fi

export LC_ALL=C.UTF-8

find "$WIKI" -name "*.md" -print0 | xargs -0 gawk -v wiki_dir="$WIKI" '
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
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
  is_meta = (base == "index" || base == "log" || base == "overview")
  skip = is_meta
  page = base
}
{
  if (skip) next
  line = $0
  sub(/\r$/, "", line)
  if (FNR == 1 && line == "---") { infm = 1; next }
  if (infm == 1 && line == "---") { infm = 0; next }
  if (infm == 1) next
  if (line ~ /^```/) { inblock = !inblock; next }
  if (inblock) next

  n = length(line)
  pos = 1
  while (pos <= n) {
    rest = substr(line, pos)
    if (match(rest, /[-−]?[0-9]+(\.[0-9]+)?([–—−-][0-9]+(\.[0-9]+)?%?)?(±[0-9]+(\.[0-9]+)?%?)?%?(µs|ms|ns|us)?/)) {
      rstart = pos + RSTART - 1
      rlen = RLENGTH
      tok = substr(line, rstart, rlen)
      prevch = (rstart > 1) ? substr(line, rstart - 1, 1) : ""
      nextch = (rstart + rlen <= n) ? substr(line, rstart + rlen, 1) : ""
      if (prevch !~ /[A-Za-z0-9]/ && nextch !~ /[A-Za-z0-9]/) {
        key = page SUBSEP tok
        if (!(key in page_seen)) {
          page_seen[key] = 1
          page_count[tok]++
          if (page_count[tok] == 1) {
            distinct_tokens[++dt_n] = tok
          }
          # record page in list
          if (page_list[tok] == "") {
            page_list[tok] = page
          } else {
            page_list[tok] = page_list[tok] "\t" page
          }
        }
        total_count[tok]++
        if (!(key in snippet_set)) {
          snippet_set[key] = 1
          snippet_ln[key] = FNR
          snippet_txt[key] = trim(line)
        }
      }
      pos = rstart + rlen
      if (pos <= rstart) pos = rstart + 1
    } else {
      pos++
    }
  }
}
END {
  # sort distinct tokens by page_count desc, then total_count desc, then token
  for (i = 1; i <= dt_n; i++) {
    for (j = i + 1; j <= dt_n; j++) {
      a = distinct_tokens[i]
      b = distinct_tokens[j]
      swap = 0
      if (page_count[b] > page_count[a]) swap = 1
      else if (page_count[b] == page_count[a]) {
        if (total_count[b] > total_count[a]) swap = 1
        else if (total_count[b] == total_count[a] && b < a) swap = 1
      }
      if (swap) {
        tmp = distinct_tokens[i]
        distinct_tokens[i] = distinct_tokens[j]
        distinct_tokens[j] = tmp
      }
    }
  }

  print "# Numeric token duplicates (informational; not a lint)"
  print "# Bare short integers (e.g. \"2\") are filtered: a token is shown only when its length is >= 3, or when it carries a unit (%), a range dash, or +/- uncertainty"
  print "# token  (pages: N, occurrences: M)"
  print ""
  shown = 0
  for (i = 1; i <= dt_n && shown < 30; i++) {
    tok = distinct_tokens[i]
    if (page_count[tok] < 2) continue
    # display filter: drop bare short integers; keep tokens with a unit,
    # range dash or +/- qualifier even if short
    if (length(tok) < 3 && tok !~ /[%µ±]/ && tok !~ /[–—−]/) continue
    shown++
    printf "%s  (pages: %d, occurrences: %d)\n", tok, page_count[tok], total_count[tok]
    # page list
    np = split(page_list[tok], parr, "\t")
    for (k = 1; k <= np; k++) {
      pg = parr[k]
      key = pg SUBSEP tok
      printf "  - %s:L%d: %s\n", pg, snippet_ln[key], snippet_txt[key]
    }
    print ""
  }
  if (shown == 0) {
    print "(重複する数値トークンはありません)"
  }
}
'
exit 0
