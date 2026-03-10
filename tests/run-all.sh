#!/usr/bin/env bash
# Run all template tests by iterating over tests/*/test.sh.
# Run from repo root: ./tests/run-all.sh
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

for dir in tests/*/; do
  name="${dir#tests/}"
  name="${name%/}"
  if [[ -x "$dir/test.sh" ]]; then
    echo "==> Template: $name"
    "./$dir/test.sh" "$@"
  fi
done

echo "==> All template tests passed"
