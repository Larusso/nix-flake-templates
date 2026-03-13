#!/usr/bin/env bash
# Rust + OpenSpec template: flake check + content tests.
# Run from repo root: ./tests/rust-openspec/test.sh
# Optional: SKIP_CONTENT_TESTS=1 to only run flake check (faster).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> Rust-OpenSpec template: flake check"
nix flake check "path:$REPO_ROOT/templates/rust-openspec" "$@"

if [[ "${SKIP_CONTENT_TESTS:-0}" == "1" ]]; then
  echo "==> Skipping content tests (SKIP_CONTENT_TESTS=1)"
  exit 0
fi

echo "==> Rust-OpenSpec template: content tests (nix flake new -t + devShell)"
TMPDIR="${TMPDIR:-/tmp}"
TEST_DIR=$(mktemp -d "${TMPDIR}/rust-openspec-template-test.XXXXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

nix flake new "$TEST_DIR" -t "path:$REPO_ROOT#rust-openspec"

echo "  -> rustc in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v rustc >/dev/null && rustc --version'

echo "  -> cargo in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v cargo >/dev/null && cargo --version'

echo "  -> openspec in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v openspec >/dev/null && openspec --version'

echo "  -> nightly devShell evaluates"
nix develop "$TEST_DIR#nightly" -c bash -c 'rustc --version && openspec --version'

echo "  -> generated project has no templates output"
if grep -q "templates" "$TEST_DIR/flake.nix"; then
  echo "ERROR: generated flake.nix must not expose templates output" >&2
  exit 1
fi

echo "==> Rust-OpenSpec template: all checks passed"
