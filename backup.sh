#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/repositories/factorio"
SAVE_DIR="/opt/factorio/saves"
OUT_DIR="$REPO_DIR/savedata"

# Find newest .zip save in /opt/factorio/saves
LATEST_ZIP="$(find "$SAVE_DIR" -maxdepth 1 -type f -name '*.zip' -printf '%T@ %p\n' \
  | sort -n | tail -1 | cut -d' ' -f2-)"

if [[ -z "${LATEST_ZIP:-}" ]] || [[ ! -f "$LATEST_ZIP" ]]; then
  echo "No save .zip found in $SAVE_DIR" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Replace extracted data
rm -rf "$OUT_DIR"/*
unzip -oq "$LATEST_ZIP" -d "$OUT_DIR"

cd "$REPO_DIR"

# Git commit only if there are changes
git add .
if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

git commit -m "Factorio backup: $(date -Is) ($(basename "$LATEST_ZIP"))"
git push