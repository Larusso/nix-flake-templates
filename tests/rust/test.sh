#!/usr/bin/env bash
# Rust template: flake check + content tests.
# Run from repo root: ./tests/rust/test.sh
# Optional: SKIP_CONTENT_TESTS=1 to only run flake check (faster).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> Rust template: flake check"
nix flake check "path:$REPO_ROOT/templates/rust" "$@"

if [[ "${SKIP_CONTENT_TESTS:-0}" == "1" ]]; then
  echo "==> Skipping content tests (SKIP_CONTENT_TESTS=1)"
  exit 0
fi

echo "==> Rust template: content tests (nix flake new -t + devShell)"
TMPDIR="${TMPDIR:-/tmp}"
TEST_DIR=$(mktemp -d "${TMPDIR}/rust-template-test.XXXXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

nix flake new "$TEST_DIR" -t "path:$REPO_ROOT#rust"

echo "  -> rustc in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v rustc >/dev/null && rustc --version'

echo "  -> cargo in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v cargo >/dev/null && cargo --version'

echo "  -> generated project has no templates output"
if grep -q "templates" "$TEST_DIR/flake.nix"; then
  echo "ERROR: generated flake.nix must not expose templates output" >&2
  exit 1
fi

echo "==> Rust template: all checks passed"
