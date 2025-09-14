#!/usr/bin/env bash
set -euo pipefail

ROOT="docs"
OUT="build/REPORT_TB1.md"
mkdir -p build
: > "$OUT"

SEP=$'\n\n---\n\n'

add_file () {
  local f="$1"
  [ -f "$f" ] && { cat "$f" >> "$OUT"; echo "$SEP" >> "$OUT"; }
}

heading_from_dir () {
  local dir="$1"
  local base="$(basename "$dir")"
  local num="${base%%-*}"
  local title="${base#*-}"
  title="${title//-/ }"
  echo "# ${num^^} ${title^^}"
}

mapfile -t DIRS < <(find "$ROOT" -maxdepth 1 -mindepth 1 -type d | sort -V)

for DIR in "${DIRS[@]}"; do
  base="$(basename "$DIR")"
  PARENT_MD="$DIR/$base.md"

  if [ -f "$PARENT_MD" ]; then
    add_file "$PARENT_MD"
  else
    heading_from_dir "$DIR" >> "$OUT"
    echo "$SEP" >> "$OUT"
  fi

  mapfile -t FILES < <(find "$DIR" -maxdepth 1 -type f -name "*.md" ! -name "$(basename "$PARENT_MD")" | sort -V)
  for f in "${FILES[@]}"; do
    add_file "$f"
  done
done

echo "OK → $OUT"
