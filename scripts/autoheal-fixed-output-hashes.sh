#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <log-file>" >&2
  exit 2
fi

log_file="$1"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$log_file" ]]; then
  echo "log file not found: $log_file" >&2
  exit 2
fi

mapfile -t mismatches < <(
  awk '
    /specified:[[:space:]]+sha256-/ { specified = $NF }
    /got:[[:space:]]+sha256-/ {
      got = $NF
      if (specified != "" && got != "") {
        print specified "\t" got
      }
      specified = ""
      got = ""
    }
  ' "$log_file" | awk '!seen[$0]++'
)

if [[ ${#mismatches[@]} -eq 0 ]]; then
  echo "No fixed-output hash mismatches found in $log_file" >&2
  exit 1
fi

changed=0
while IFS=$'\t' read -r old_hash new_hash; do
  [[ -n "${old_hash:-}" ]] || continue
  [[ -n "${new_hash:-}" ]] || continue

  if command -v rg >/dev/null 2>&1; then
    mapfile -t files < <(
      rg -l --fixed-strings "$old_hash" "$repo_root" \
        -g '*.nix' \
        -g '!**/.git/**' \
        -g '!**/.direnv/**' \
        2>/dev/null || true
    )
  else
    echo "ripgrep not found; falling back to find+grep for hash lookup"
    mapfile -t files < <(
      find "$repo_root" \
        -path "$repo_root/.git" -prune -o \
        -path "$repo_root/.direnv" -prune -o \
        -type f -name '*.nix' -exec grep -lF "$old_hash" {} + 2>/dev/null || true
    )
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    echo "No .nix file contains $old_hash" >&2
    continue
  fi

  echo "Found $old_hash in:"
  for file in "${files[@]}"; do
    echo "  - $file"
  done

  for file in "${files[@]}"; do
    OLD_HASH="$old_hash" NEW_HASH="$new_hash" \
      perl -0pi -e 's/\Q$ENV{OLD_HASH}\E/$ENV{NEW_HASH}/g' "$file"
    echo "Updated $file: $old_hash -> $new_hash"
    changed=1
  done
done < <(printf '%s\n' "${mismatches[@]}")

if [[ "$changed" -eq 0 ]]; then
  echo "Hash mismatches were found, but no files were updated" >&2
  exit 1
fi
