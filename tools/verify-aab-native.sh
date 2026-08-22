#!/usr/bin/env bash
set -euo pipefail

AAB="${1:-app/build/outputs/bundle/release/app-release.aab}"
READELF="${2:-llvm-readelf}"

if [[ ! -f "$AAB" ]]; then
  echo "AAB not found: $AAB" >&2
  exit 1
fi

if ! command -v "$READELF" >/dev/null 2>&1 && [[ ! -x "$READELF" ]]; then
  echo "llvm-readelf not found: $READELF" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

unzip -q "$AAB" -d "$TMP"

required_abis=(armeabi-v7a arm64-v8a x86 x86_64)
for abi in "${required_abis[@]}"; do
  if ! compgen -G "$TMP/base/lib/$abi/*.so" >/dev/null; then
    echo "Missing native libraries for required ABI: $abi" >&2
    exit 1
  fi
  echo "ABI present: $abi"
done

for abi in arm64-v8a x86_64; do
  for so in "$TMP"/base/lib/"$abi"/*.so; do
    elf_class="$($READELF -h "$so" | awk -F: '/Class:/ {gsub(/[[:space:]]/, "", $2); print $2; exit}')"
    if [[ "$elf_class" != "ELF64" ]]; then
      echo "Expected ELF64 for $so, got: $elf_class" >&2
      exit 1
    fi

    load_count=0
    while read -r align; do
      [[ -z "$align" ]] && continue
      load_count=$((load_count + 1))
      align_value=$((align))
      if (( align_value < 16384 )); then
        echo "16 KB page-size check failed: $so has LOAD alignment $align" >&2
        exit 1
      fi
    done < <("$READELF" -lW "$so" | awk '$1 == "LOAD" {print $NF}')

    if (( load_count == 0 )); then
      echo "No LOAD segments found in $so" >&2
      exit 1
    fi

    echo "16 KB ELF alignment OK: $so"
  done
done

echo "AAB native compatibility checks passed."
