#!/bin/bash
# Simple lint script for LLM Wiki.
# Checks for orphan pages, open (unresolved) wikilinks, and index consistency.
# Run with: bash .agents/skills/llm-wiki-lint/scripts/lint.sh

set -euo pipefail
WIKI_DIR="$(cd "$(dirname "$0")/../../../.." && pwd)/wiki"

echo "=== LLM Wiki Lint ==="
echo ""

# Check for orphan pages (no inbound links from other wiki pages)
# sources/ pages: index.md listing does not count (unlinked source = not digested)
echo "--- Orphan pages (no inbound links) ---"
for page in "$WIKI_DIR"/concepts/*.md "$WIKI_DIR"/entities/*.md "$WIKI_DIR"/analyses/*.md "$WIKI_DIR"/sources/*.md; do
  [ -f "$page" ] || continue
  basename="$(basename "$page" .md)"
  # Count how many other wiki pages link to this page
  if [[ "$page" == "$WIKI_DIR"/sources/* ]]; then
    count=$(grep -rl --include="*.md" --exclude="$(basename "$page")" "\[\[${basename}\]\]" "$WIKI_DIR"/concepts "$WIKI_DIR"/entities "$WIKI_DIR"/analyses "$WIKI_DIR"/sources 2>/dev/null | wc -l || true)
  else
    count=$(grep -rl --include="*.md" --exclude="index.md" --exclude="log.md" --exclude="overview.md" --exclude="$(basename "$page")" "\[\[${basename}\]\]" "$WIKI_DIR" 2>/dev/null | wc -l || true)
  fi
  if [ "$count" -eq 0 ]; then
    echo "  ORPHAN: ${page#"$WIKI_DIR"/}"
  fi
done
echo ""

# Check for open links (wikilinks whose target page does not exist yet) in wiki/.
# An open link is not a defect: it marks a place where the graph has no node yet.
# Classification by reference count is our operating rule, not a Cosense term:
#   1 page   = OPEN_LINK (1 page)  — check spelling/path form; leave it if intentional
#   2+ pages = OPEN_LINK (n pages) — virtual page / hub seed; candidate for page creation
# Open links never fail the run.
echo "--- Open links (unresolved wikilinks, classified by ref count) ---"
find "$WIKI_DIR" -name "*.md" ! -name "index.md" ! -name "log.md" -print0 | xargs -0 awk '
  /^```/ { inblock = !inblock; next }
  !inblock {
    line = $0
    gsub(/`[^`]*`/, "", line)
    while (match(line, /\[\[[^]]*\]\]/)) {
      print FILENAME "\t" substr(line, RSTART, RLENGTH)
      line = substr(line, RSTART + RLENGTH)
    }
  }
' \
  | sed 's/\[\[//;s/\]\]//' \
  | awk -F'\t' '{ split($2, a, "|"); print $1 "\t" a[1] }' \
  | sort -u \
  | awk -F'\t' '{ count[$2]++ } END { for (t in count) print count[t] "\t" t }' \
  | sort -rn \
  | while read -r count target; do
    # Skip non-file targets (URLs, external refs, empty)
    [[ "$target" == http* ]] && continue
    [ -z "$target" ] && continue
    found=$(find "$WIKI_DIR" -name "${target}.md" 2>/dev/null | head -1)
    if [ -z "$found" ]; then
      if [ "$count" -ge 2 ]; then
        echo "  OPEN_LINK ($count pages): [[${target}]] — virtual page / hub seed; candidate for page creation"
      else
        echo "  OPEN_LINK (1 page): [[${target}]] — check spelling or path form; leave it if intentional"
      fi
    fi
  done
echo ""

# Check duplicate wikilinks within each page body (claim-granularity
# citations with distinct p.XX pinpointers are exempt)
echo "--- Duplicate wikilinks within pages ---"
find "$WIKI_DIR" -name "*.md" ! -name "index.md" ! -name "log.md" -print0 | xargs -0 awk '
  FNR == 1 {
    infm = 0; inblock = 0
    relpath = FILENAME
    base = relpath; sub(/^.*\//, "", base); sub(/\.md$/, "", base)
    self = base
  }
  {
    line = $0
    if (FNR == 1 && line == "---") { infm = 1; next }
    if (infm == 1 && line == "---") { infm = 2; next }
    if (infm == 1) next
    if (line ~ /^```/) { inblock = !inblock; next }
    if (inblock) next
    clean = line
    gsub(/`[^`]*`/, "", clean)
    work = clean
    while (match(work, /\[\[[^]]+\]\]/)) {
      m_start = RSTART; m_len = RLENGTH
      raw_link = substr(work, m_start + 2, m_len - 4)
      split(raw_link, parts, "|")
      target = parts[1]
      sub(/^[ \t\r\n]+/, "", target); sub(/[ \t\r\n]+$/, "", target)
      if (target != "" && target !~ /^http/ && target != self) {
        key = self SUBSEP target
        n_occ[key]++
        tail = substr(work, m_start + m_len)
        pin = ""
        if (match(tail, /^ *p\.[0-9]+[0-9.-]*/)) pin = substr(tail, RSTART, RLENGTH)
        occ_pin[key, n_occ[key]] = pin
      }
      work = substr(work, m_start + m_len)
    }
  }
  END {
    for (key in n_occ) {
      n = n_occ[key]
      if (n < 2) continue
      split(key, kp, SUBSEP)
      page = kp[1]; tgt = kp[2]
      npinned = 0; npinless = 0; duppin = 0
      for (i = 1; i <= n; i++) {
        pi = occ_pin[key, i]
        if (pi == "") { npinless++; continue }
        npinned++
        for (j = i + 1; j <= n; j++) {
          if (occ_pin[key, j] == pi) duppin++
        }
      }
      if (npinless >= 2 || duppin > 0 || npinned == 0) {
        printf "  DUPLICATE x%d (pinless=%d, dup-pin=%d): [[%s]] in %s\n", n, npinless, duppin, tgt, page
      }
    }
  }
'
echo ""
# Known limitation: wikilinks containing https:// or # (URL/anchor targets)
# cannot be resolved to files by any classification above
echo "  NOTE: wikilinks containing https:// or # are not resolvable here — manual check at review is fine"
echo ""

# Check that all pages in wiki/ appear in index.md
echo "--- Pages missing from index.md ---"
find "$WIKI_DIR" -name "*.md" ! -name "index.md" ! -name "log.md" \
  | while read -r page; do
    basename="$(basename "$page" .md)"
    if ! grep -q "$basename" "$WIKI_DIR/index.md"; then
      echo "  MISSING: $page is not in index.md"
    fi
  done
echo ""

# Check that index.md entries point to existing files (stale entries)
# URL-encoded paths (e.g. %20 for spaces) are decoded before checking
echo "--- Stale index entries (target file missing) ---"
grep -E '^- \[' "$WIKI_DIR/index.md" \
  | grep -oE '\]\([^)]+\.md\)' \
  | sed -e 's/^](//' -e 's/)$//' -e 's/%20/ /g' \
  | sort -u \
  | while read -r rel; do
      [ -f "$WIKI_DIR/$rel" ] || echo "  STALE: $rel"
    done || true
echo ""

# Check that raw/ files referenced from wiki/ actually exist
# Inline code and fenced code blocks are stripped first (quoted design
# examples in analyses pages are not raw references)
echo "--- Missing raw files referenced from wiki/ ---"
find "$WIKI_DIR" -name "*.md" -print0 | xargs -0 awk '
  /^```/ { inblock = !inblock; next }
  !inblock { gsub(/`[^`]*`/, "", $0); print }
' \
  | grep -oE 'raw/[^])"'"'"'`\[,<>。、「」（）、→]+\.md' \
  | sort -u \
  | while read -r ref; do
    if [ ! -f "$(dirname "$WIKI_DIR")/$ref" ]; then
      echo "  MISSING RAW: $ref"
    fi
  done || true
echo ""

# Check that sources/ pages declare a pointer to the source in frontmatter
# (raw: path or source_url: — at least one is required)
echo "--- Sources pages without raw: or source_url: ---"
for page in "$WIKI_DIR"/sources/*.md; do
  [ -f "$page" ] || continue
  if ! grep -qE '^(raw|source_url):' "$page"; then
    echo "  NO POINTER: $page"
  fi
done
echo ""

# Check image links (../assets/...) resolve, and no asset is unused
echo "--- Image links / unused assets ---"
links=$(grep -roh --include='*.md' '(\.\./assets/[^)]*)' "$WIKI_DIR" 2>/dev/null | sed 's/^(//;s/)$//;s|^\.\./||' | sort -u || true)
echo "$links" | while read -r rel; do
  [ -n "$rel" ] || continue
  [ -f "$WIKI_DIR/$rel" ] || echo "  MISSING IMAGE: $rel"
done
if [ -d "$WIKI_DIR/assets" ]; then
  for f in "$WIKI_DIR"/assets/*; do
    [ -f "$f" ] || continue
    if ! grep -qr --include='*.md' "$(basename "$f")" "$WIKI_DIR"; then
      echo "  UNUSED ASSET: ${f#"$WIKI_DIR"/}"
    fi
  done
fi
echo ""

# Count wiki pages
total=$(find "$WIKI_DIR" -name "*.md" ! -name "index.md" ! -name "log.md" | wc -l)
echo "Total wiki pages: $total"
echo "=== Done ==="
