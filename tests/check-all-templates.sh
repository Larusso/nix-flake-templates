#!/usr/bin/env bash
# Run all template checks. Run from repo root: ./tests/check-all-templates.sh
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
./tests/check-openspec-template.sh "$@"
