#!/usr/bin/env bash
# Rust library template: flake check + content tests.
# Run from repo root: ./tests/rust-lib/test.sh
# Optional: SKIP_CONTENT_TESTS=1 to only run flake check (faster).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> Rust-lib template: flake check"
nix flake check "path:$REPO_ROOT/templates/rust-lib" "$@"

if [[ "${SKIP_CONTENT_TESTS:-0}" == "1" ]]; then
  echo "==> Skipping content tests (SKIP_CONTENT_TESTS=1)"
  exit 0
fi

echo "==> Rust-lib template: content tests (nix flake new -t + devShell + build)"
TMPDIR="${TMPDIR:-/tmp}"
TEST_DIR=$(mktemp -d "${TMPDIR}/rust-lib-template-test.XXXXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

nix flake new "$TEST_DIR" -t "path:$REPO_ROOT#rust-lib"

echo "  -> rustc in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v rustc >/dev/null && rustc --version'

echo "  -> cargo in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v cargo >/dev/null && cargo --version'

echo "  -> nightly devShell evaluates (rust-overlay applied correctly)"
nix develop "$TEST_DIR#nightly" -c bash -c 'rustc --version'

echo "  -> nix build produces a library"
nix build "$TEST_DIR" -o "$TEST_DIR/result"
LIB_COUNT=$(find "$TEST_DIR/result/lib/" \( -name "*.so" -o -name "*.dylib" -o -name "*.a" \) | wc -l)
if [[ "$LIB_COUNT" -eq 0 ]]; then
  echo "ERROR: nix build did not produce any library files in result/lib/" >&2
  exit 1
fi
echo "    found $LIB_COUNT library file(s):"
ls "$TEST_DIR/result/lib/"

echo "  -> generated project has no templates output"
if grep -q "templates" "$TEST_DIR/flake.nix"; then
  echo "ERROR: generated flake.nix must not expose templates output" >&2
  exit 1
fi

echo "==> Rust-lib template: all checks passed"
