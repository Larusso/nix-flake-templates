#!/usr/bin/env bash
# oh-my-cloudecode helper flake: direct flake builds + root package re-exports.
# Run from repo root: ./tests/oh-my-cloudecode/test.sh
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> oh-my-cloudecode helper flake: flake show"
nix flake show "path:$REPO_ROOT/flakes/oh-my-cloudecode" "$@"

echo "==> oh-my-cloudecode helper flake: direct files-only build"
nix build "path:$REPO_ROOT/flakes/oh-my-cloudecode#oh-my-cloudecode-files" --no-link "$@"

echo "==> oh-my-cloudecode helper flake: direct default build"
nix build "path:$REPO_ROOT/flakes/oh-my-cloudecode#default" --no-link "$@"

echo "==> oh-my-cloudecode helper flake: root package re-exports"
nix build "path:$REPO_ROOT#oh-my-cloudecode" --no-link "$@"
nix build "path:$REPO_ROOT#oh-my-cloudecode-files" --no-link "$@"

echo "==> oh-my-cloudecode helper flake: all checks passed"
