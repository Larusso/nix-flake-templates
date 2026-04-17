#!/usr/bin/env bash
# oh-my-codex helper flake: direct flake builds + root package re-exports.
# Run from repo root: ./tests/oh-my-codex/test.sh
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> oh-my-codex helper flake: flake show"
nix flake show "path:$REPO_ROOT/flakes/oh-my-codex"

echo "==> oh-my-codex helper flake: direct files-only build"
nix build "path:$REPO_ROOT/flakes/oh-my-codex#oh-my-codex-files" --no-link "$@"

echo "==> oh-my-codex helper flake: direct default build"
nix build "path:$REPO_ROOT/flakes/oh-my-codex#default" --no-link "$@"

echo "==> oh-my-codex helper flake: root package re-exports"
nix build "path:$REPO_ROOT#oh-my-codex" --no-link "$@"
nix build "path:$REPO_ROOT#oh-my-codex-files" --no-link "$@"

echo "==> oh-my-codex helper flake: all checks passed"
