#!/usr/bin/env bash
# oh-my-claudecode helper flake: direct flake builds + root package re-exports.
# Run from repo root: ./tests/oh-my-claudecode/test.sh
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> oh-my-claudecode helper flake: flake show"
nix flake show "path:$REPO_ROOT/flakes/oh-my-claudecode" "$@"

echo "==> oh-my-claudecode helper flake: direct files-only build"
nix build "path:$REPO_ROOT/flakes/oh-my-claudecode#oh-my-claudecode-files" --no-link "$@"

echo "==> oh-my-claudecode helper flake: direct default build"
nix build "path:$REPO_ROOT/flakes/oh-my-claudecode#default" --no-link "$@"

echo "==> oh-my-claudecode helper flake: root package re-exports"
nix build "path:$REPO_ROOT#oh-my-claudecode" --no-link "$@"
nix build "path:$REPO_ROOT#oh-my-claudecode-files" --no-link "$@"

echo "==> oh-my-claudecode helper flake: all checks passed"
