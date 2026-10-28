#!/bin/bash
# diagnose-wiki.sh - Phase A診断: 新lint.shの機械検証 + ページ肥大度 + リンク次数統計
# 読み取り専用。一切変更しない。
set -euo pipefail

usage() {
  cat <<'EOF'
diagnose-wiki.sh - wikiの健全性・肥大化・リンク次数を診断する（読み取り専用）

Usage:
  bash .agents/scripts/diagnose-wiki.sh [options] <wiki-repo-root>

Options:
  --wiki-dir <dir>    wikiディレクトリのパスを直接指定する（既定: <repo>/wiki）
  --template-dir <dir> テンプレートリポジトリのパス（lint.sh取得元、既定: このスクリプトのリポジトリ）
  -h, --help          このヘルプを表示する

Examples:
  bash .agents/scripts/diagnose-wiki.sh /home/takker/git/SP1-2026A
  bash .agents/scripts/diagnose-wiki.sh --wiki-dir /home/takker/git/SP1-2026A/wiki
EOF
}

REPO=""
WIKI_DIR_OVERRIDE=""
TEMPLATE_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --wiki-dir)
      WIKI_DIR_OVERRIDE="$2"
      shift 2
      ;;
    --template-dir)
      TEMPLATE_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ $# -gt 0 ]; do
        if [ -z "$REPO" ]; then REPO="$1"; fi
        shift
      done
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      if [ -z "$REPO" ]; then
        REPO="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$TEMPLATE_DIR" ]; then
  TEMPLATE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
fi

if [ -n "$WIKI_DIR_OVERRIDE" ]; then
  WIKI="$WIKI_DIR_OVERRIDE"
  if [ -z "$REPO" ]; then
    REPO="$(cd "$(dirname "$WIKI")" && pwd)"
  fi
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
  echo "Error: no wiki dir at $WIKI" >&2
  exit 1
fi

LINT_SH="$TEMPLATE_DIR/.agents/skills/llm-wiki-lint/scripts/lint.sh"
if [ ! -f "$LINT_SH" ]; then
  echo "Error: lint.sh not found at $LINT_SH" >&2
  exit 1
fi

mkdir -p /tmp/opencode
TMP=$(mktemp -d /tmp/opencode/diag.XXXXXX)
trap 'rm -rf "$TMP"' EXIT

echo "############ 1. lint.sh (template, retargeted) ############"
sed "s|^WIKI_DIR=.*|WIKI_DIR=\"$WIKI\"|" "$LINT_SH" > "$TMP/lint.sh"
bash "$TMP/lint.sh" || true

echo ""
echo "############ 2. 肥大化ページ (top 15 by lines) ############"
find "$WIKI" -name "*.md" ! -name "index.md" ! -name "log.md" -exec wc -l {} + | sort -rn | head -16

echo ""
echo "############ 3. リンク次数統計 ############"
find "$WIKI" -name "*.md" -print0 | xargs -0 awk '
function trim(s) { sub(/^[ \t\r\n]+/, "", s); sub(/[ \t\r\n]+$/, "", s); return s }
FNR == 1 {
  inblock = 0
  infm = 0
  relpath = FILENAME
  base = relpath; sub(/^.*\//, "", base); sub(/\.md$/, "", base)
  is_meta = (relpath ~ /\/index\.md$/ || relpath ~ /\/log\.md$/ || relpath ~ /\/overview\.md$/)
  exists[base] = 1
  self = base
}
{
  line = $0
  if (is_meta) next
  if (FNR == 1 && line == "---") { infm = 1; next }
  if (infm == 1 && line == "---") { infm = 2; next }
  if (infm == 1) next
  if (line ~ /^```/) { inblock = !inblock; next }
  if (inblock) next
  clean = line
  gsub(/`[^`]*`/, "", clean)
  work = clean
  while (match(work, /\[\[[^]]+\]\]/)) {
    raw_link = substr(work, RSTART + 2, RLENGTH - 4)
    split(raw_link, parts, "|")
    target = trim(parts[1])
    if (target != "" && target !~ /^http/ && target != self) {
      n_all[target]++
      n_out[self]++
    }
    work = substr(work, RSTART + RLENGTH)
  }
}
END {
  print "--- [既存ページ] 本文リンクのみの被リンク top 20 (ハブ・ノイズ候補) ---"
  n = 0
  for (t in n_all) if (t in exists) { d[n] = n_all[t]; name[n] = t; n++ }
  for (i = 0; i < n; i++) for (j = i + 1; j < n; j++) if (d[j] > d[i]) { dd=d[i]; d[i]=d[j]; d[j]=dd; nn=name[i]; name[i]=name[j]; name[j]=nn }
  for (i = 0; i < n && i < 20; i++) printf "  %3d  [[%s]]\n", d[i], name[i]

  print ""
  print "--- [既存ページ] 出リンク数 top 15 (リンク撒き散らし候補) ---"
  n = 0
  for (s in n_out) { d[n] = n_out[s]; name[n] = s; n++ }
  for (i = 0; i < n; i++) for (j = i + 1; j < n; j++) if (d[j] > d[i]) { dd=d[i]; d[i]=d[j]; d[j]=dd; nn=name[i]; name[i]=name[j]; name[j]=nn }
  for (i = 0; i < n && i < 15; i++) printf "  %3d  [[%s]]\n", d[i], name[i]

  print ""
  print "--- [オープンリンク(未作成)] 被リンク top 30 (中間概念ハブ化候補: 2+参照はlintがOPEN_LINK表示) ---"
  n = 0
  for (t in n_all) if (!(t in exists)) { d[n] = n_all[t]; name[n] = t; n++ }
  for (i = 0; i < n; i++) for (j = i + 1; j < n; j++) if (d[j] > d[i]) { dd=d[i]; d[i]=d[j]; d[j]=dd; nn=name[i]; name[i]=name[j]; name[j]=nn }
  total_unres = 0
  for (i = 0; i < n; i++) { total_unres++; if (i < 30) printf "  %3d  [[%s]]\n", d[i], name[i] }
  printf "  (オープンリンク総数: %d)\n", total_unres
}
'
echo ""
echo "(診断完了: 変更は一切行っていません)"
