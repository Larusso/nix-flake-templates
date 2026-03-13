#!/usr/bin/env bash
# Rust binary template: flake check + content tests.
# Run from repo root: ./tests/rust-bin/test.sh
# Optional: SKIP_CONTENT_TESTS=1 to only run flake check (faster).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

echo "==> Rust-bin template: flake check"
nix flake check "path:$REPO_ROOT/templates/rust-bin" "$@"

if [[ "${SKIP_CONTENT_TESTS:-0}" == "1" ]]; then
  echo "==> Skipping content tests (SKIP_CONTENT_TESTS=1)"
  exit 0
fi

echo "==> Rust-bin template: content tests (nix flake new -t + devShell + build)"
TMPDIR="${TMPDIR:-/tmp}"
TEST_DIR=$(mktemp -d "${TMPDIR}/rust-bin-template-test.XXXXXXXX")
trap 'rm -rf "$TEST_DIR"' EXIT

nix flake new "$TEST_DIR" -t "path:$REPO_ROOT#rust-bin"

echo "  -> rustc in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v rustc >/dev/null && rustc --version'

echo "  -> cargo in PATH in devShell"
nix develop "$TEST_DIR" -c bash -c 'command -v cargo >/dev/null && cargo --version'

echo "  -> nightly devShell evaluates (rust-overlay applied correctly)"
nix develop "$TEST_DIR#nightly" -c bash -c 'rustc --version'

echo "  -> nix build produces a binary"
nix build "$TEST_DIR" -o "$TEST_DIR/result"
test -x "$TEST_DIR/result/bin/my-project"

echo "  -> built binary runs"
"$TEST_DIR/result/bin/my-project"

echo "  -> msrv devShell evaluates (custom pinned toolchain via rust-overlay)"
sed -i.bak \
  -e 's|# msrv = |msrv = |' \
  -e 's|# msrvToolchain = |msrvToolchain = |' \
  -e 's|# devShells.msrv = |devShells.msrv = |' \
  "$TEST_DIR/flake.nix"
rm -f "$TEST_DIR/flake.nix.bak"
    # Add rust-version under existing [package] section
sed -i.bak '/^\[package\]/a\
rust-version = "1.80.0"
' "$TEST_DIR/Cargo.toml"
rm -f "$TEST_DIR/Cargo.toml.bak"
nix develop "$TEST_DIR#msrv" -c bash -c 'rustc --version'

echo "  -> generated project has no templates output"
if grep -q "templates" "$TEST_DIR/flake.nix"; then
  echo "ERROR: generated flake.nix must not expose templates output" >&2
  exit 1
fi

echo "==> Rust-bin template: all checks passed"
