#!/usr/bin/env bash
# Run all repo flake tests, including templates and helper flakes under tests/*/.
# Run from repo root: ./tests/run-all.sh
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

ran_any=0
for dir in tests/*/; do
  name="${dir#tests/}"
  name="${name%/}"
  if [[ -x "$dir/test.sh" ]]; then
    echo "==> Check: $name"
    "./$dir/test.sh" "$@"
    ran_any=1
  fi
done

if [[ "$ran_any" -eq 0 ]]; then
  echo "No test scripts were run" >&2
  exit 1
fi
echo "==> All repo flake tests passed"
