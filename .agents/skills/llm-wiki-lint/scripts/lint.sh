#!/bin/bash
# Simple lint script for LLM Wiki.
# Checks for orphan pages, broken wikilinks, and index consistency.
# Run with: bash .agents/skills/llm-wiki-lint/scripts/lint.sh

set -euo pipefail
WIKI_DIR="$(dirname "$0")/../../../../wiki"

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
    count=$(grep -rl "\[\[${basename}\]\]" "$WIKI_DIR"/concepts "$WIKI_DIR"/entities "$WIKI_DIR"/analyses "$WIKI_DIR"/sources --include="*.md" 2>/dev/null | wc -l || true)
  else
    count=$(grep -rl "\[\[${basename}\]\]" "$WIKI_DIR" --include="*.md" 2>/dev/null | wc -l || true)
  fi
  if [ "$count" -eq 0 ]; then
    echo "  ORPHAN: $page"
  fi
done
echo ""

# Check for broken wikilinks in wiki/ (skipping fenced code blocks and inline code)
# Classification by reference count (pages that link to the target):
#   1 page   = BROKEN       (likely typo / private jargon, or intentional red link)
#   2+ pages = ASPECT_HANDLE (concept hub seed; candidate for page creation)
echo "--- Broken wikilinks (classified by ref count) ---"
find "$WIKI_DIR" -name "*.md" -print0 | xargs -0 awk '
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
        echo "  ASPECT_HANDLE ($count pages): [[${target}]] — page creation candidate"
      else
        echo "  BROKEN (1 page): [[${target}]] — typo or intentional red link"
      fi
    fi
  done
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
    done
echo ""

# Count wiki pages
total=$(find "$WIKI_DIR" -name "*.md" ! -name "index.md" ! -name "log.md" | wc -l)
echo "Total wiki pages: $total"
echo "=== Done ==="
