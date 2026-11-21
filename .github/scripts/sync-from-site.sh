#!/usr/bin/env bash
# Pulls every catalog skill (jobspipe-*) that jobspipe.dev publishes in its agent-skills index into
# skills/<name>/SKILL.md, checking each file against the index's sha256 digest. Skills that are not
# in the index (the hand-written ones) are never touched; a catalog skill that left the index is
# reported in $GITHUB_STEP_SUMMARY / stdout, never deleted.
set -euo pipefail

SITE="${SITE:-https://jobspipe.dev}"
INDEX_URL="$SITE/.well-known/agent-skills/index.json"
REPORT="${REPORT:-/dev/stdout}"

index="$(curl -fsS --retry 3 "$INDEX_URL")"
names="$(jq -r '.skills[] | select(.name | startswith("jobspipe-")) | .name' <<<"$index")"
[ -n "$names" ] || { echo "No catalog skills in $INDEX_URL; refusing to sync." >&2; exit 1; }

added=(); updated=()
for name in $names; do
  url="$(jq -r --arg n "$name" '.skills[] | select(.name == $n) | .url' <<<"$index")"
  want="$(jq -r --arg n "$name" '.skills[] | select(.name == $n) | .digest' <<<"$index")"
  tmp="$(mktemp)"
  curl -fsS --retry 3 "$url" -o "$tmp"
  got="sha256:$(sha256sum "$tmp" | cut -d" " -f1)"
  [ "$got" = "$want" ] || { echo "Digest mismatch for $name ($got != $want); refusing to sync." >&2; exit 1; }
  path="skills/$name/SKILL.md"
  if [ ! -f "$path" ]; then
    mkdir -p "skills/$name"; cp "$tmp" "$path"; added+=("$name")
    desc="$(jq -r --arg n "$name" '.skills[] | select(.name == $n) | .description' <<<"$index" | sed 's/ Use when.*//')"
    row="| [$name](skills/$name/SKILL.md) | $desc |"
    awk -v row="$row" '!done && /^\| \[jobspipe-/ { print row; done=1 } { print }' README.md > README.md.new && mv README.md.new README.md
  elif ! cmp -s "$tmp" "$path"; then
    cp "$tmp" "$path"; updated+=("$name")
  fi
  rm -f "$tmp"
done

gone=()
for dir in skills/jobspipe-*/; do
  name="$(basename "$dir")"
  grep -qx "$name" <<<"$names" && continue
  grep -q 'Invoke as `/jobspipe:' "$dir/SKILL.md" 2>/dev/null || continue
  gone+=("$name")
done

{
  echo "## Skills sync from $SITE"
  echo "- Added: ${added[*]:-none}"
  echo "- Updated: ${updated[*]:-none}"
  echo "- Published skills no longer on the site (left in place, review by hand): ${gone[*]:-none}"
} >> "$REPORT"
